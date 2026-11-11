module apb_slave
(
    input               pclk,     // синхросигнал
    input               presetn,  // сигнал сброса (инверсный)
    input        [31:0] paddr,    // адрес обращения
    input        [31:0] pwdata,   // данные для записи
    input               psel,     // признак выбора устройства
    input               penable,  // признак активной транзакции
    input               pwrite,   // признак операции записи
    output logic        pready,   // признак готовности от устройства
    output logic        pslverr,  // признак ошибки при обращении
    output logic [31:0] prdata    // прочитанные данные
);

    logic [31:0] register_with_some_name;
    logic [31:0] reg_group_num; // 0x00: Номер в списке группы (14)
    logic [31:0] reg_date;      // 0x04: Дата (11.11.2026)
    logic [31:0] reg_surname;   // 0x08: Первые 4 буквы фамилии ("KHAL")
    logic [31:0] reg_name;      // 0x0C: Первые 4 буквы имени ("ANNU")

    // Конечный автомат APB (APB FSM)
    enum logic [1:0] {
        APB_SETUP,
        APB_W_ENABLE,
        APB_R_ENABLE
    } apb_st;

    always @(posedge pclk) begin
        if (!presetn) begin
            prdata                  <= '0;
            pslverr                 <= 1'b0;
            pready                  <= 1'b0;
            register_with_some_name <= 32'h0;
            reg_group_num           <= 32'h0;
            reg_date                <= 32'h0;
            reg_surname             <= 32'h0;
            reg_name                <= 32'h0;
            apb_st                  <= APB_SETUP;
        end
        else begin
            case (apb_st)
                APB_SETUP: begin: apb_setup_st
                    prdata  <= '0;
                    pready  <= 1'b0;
                    pslverr <= 1'b0;

                    if (psel && !penable) begin
                        if (pwrite == 1'b1) begin
                            apb_st <= APB_W_ENABLE;
                        end
                        else begin
                            apb_st <= APB_R_ENABLE;
                        end
                    end
                end: apb_setup_st

                APB_W_ENABLE: begin: apb_w_en_st
                    if (psel && penable && pwrite) begin
                        pready <= 1'b1;
                        case (paddr[7:0])
                            8'h00: begin
                                reg_group_num <= pwdata;
                                if (pwdata[0] == 1'b0) begin
                                    register_with_some_name <= 32'hAAAA_AAAA;
                                end
                                else begin
                                    register_with_some_name <= 32'h5555_5555;
                                end
                                $display("[APB_SLAVE] WRITE to 0x00: value = 0x%08h (%0d), register_with_some_name set to %s",
                                         pwdata, pwdata, (pwdata[0] == 1'b0) ? "0xAAAA_AAAA" : "0x5555_5555");
                            end
                            8'h04: begin
                                reg_date <= pwdata;
                                $display("[APB_SLAVE] WRITE to 0x04 (Date): value = 0x%08h", pwdata);
                            end
                            8'h08: begin
                                reg_surname <= pwdata;
                                $display("[APB_SLAVE] WRITE to 0x08 (Surname): value = 0x%08h (ASCII: %s)", pwdata, pwdata);
                            end
                            8'h0C: begin
                                reg_name <= pwdata;
                                $display("[APB_SLAVE] WRITE to 0x0C (Name): value = 0x%08h (ASCII: %s)", pwdata, pwdata);
                            end
                            default: begin
                                pslverr <= 1'b1;
                                $display("[APB_SLAVE] WRITE ERROR: unsupported address 0x%08h", paddr);
                            end
                        endcase
                        apb_st <= APB_SETUP;
                    end
                end: apb_w_en_st

                APB_R_ENABLE: begin: apb_r_en_st
                    if (psel && penable && !pwrite) begin
                        pready <= 1'b1;
                        case (paddr[7:0])
                            8'h00: begin
                                prdata[31:0] <= register_with_some_name[31:0];
                                $display("[APB_SLAVE] READ from 0x00: prdata = 0x%08h (stored group_num = %0d)",
                                         register_with_some_name, reg_group_num);
                            end
                            8'h04: begin
                                prdata[31:0] <= reg_date[31:0];
                                $display("[APB_SLAVE] READ from 0x04 (Date): prdata = 0x%08h", reg_date);
                            end
                            8'h08: begin
                                prdata[31:0] <= reg_surname[31:0];
                                $display("[APB_SLAVE] READ from 0x08 (Surname): prdata = 0x%08h (ASCII: %s)", reg_surname, reg_surname);
                            end
                            8'h0C: begin
                                prdata[31:0] <= reg_name[31:0];
                                $display("[APB_SLAVE] READ from 0x0C (Name): prdata = 0x%08h (ASCII: %s)", reg_name, reg_name);
                            end
                            default: begin
                                pslverr <= 1'b1;
                                $display("[APB_SLAVE] READ ERROR: unsupported address 0x%08h", paddr);
                            end
                        endcase
                        apb_st <= APB_SETUP;
                    end
                end: apb_r_en_st

                default: begin
                    pslverr <= 1'b1;
                end
            endcase
        end
    end

endmodule