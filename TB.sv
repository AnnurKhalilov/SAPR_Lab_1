`timescale 1ns/1ps

module TB;
    logic        pclk;
    logic        presetn;
    logic        psel;
    logic        penable;
    logic        pwrite;
    logic [31:0] paddr;
    logic [31:0] pwdata;
    wire  [31:0] prdata;
    wire         pready;
    wire         pslverr;

    parameter p_device_offset = 32'h7000_0000;

    logic [31:0] address;
    logic [31:0] data_to_device;
    logic [31:0] data_from_device;

    // Подключение модуля APB Master
    apb_master MASTER
    (
        .pclk    (pclk),
        .presetn (presetn),
        .paddr   (paddr),
        .pwdata  (pwdata),
        .psel    (psel),
        .penable (penable),
        .pwrite  (pwrite),
        .pready  (pready),
        .pslverr (pslverr),
        .prdata  (prdata)
    );

    // Подключение тестируемого модуля APB Slave (DUT)
    apb_slave DUT
    (
        .pclk    (pclk),
        .presetn (presetn),
        .paddr   (paddr),
        .pwdata  (pwdata),
        .psel    (psel),
        .penable (penable),
        .pwrite  (pwrite),
        .pready  (pready),
        .pslverr (pslverr),
        .prdata  (prdata)
    );

    // Генератор синхросигнала (период 20 нс)
    always #10ns pclk = ~pclk;

    initial begin
        pclk    = 0;
        presetn = 1'b1;
        repeat (5) @(posedge pclk);
        presetn = 1'b0;
        repeat (5) @(posedge pclk);
        presetn = 1'b1;
        repeat (5) @(posedge pclk);

        $display("==========================================================");
        $display("=== PART 1: BASE TEMPLATE TEST (STEP 8) ===");
        $display("==========================================================");

        // Запись четного числа (младший бит 0) -> ожидаем 0xAAAA_AAAA
        address        = p_device_offset + 32'h0;
        data_to_device = 32'h12345678;
        MASTER.apb_write(address, data_to_device);
        MASTER.apb_read(address, data_from_device);
        $display("Addr= 0x%h, write data 0x%h, read data 0x%h", address, data_to_device, data_from_device);

        // Запись нечетного числа (младший бит 1) -> ожидаем 0x5555_5555
        data_to_device = 32'h1;
        MASTER.apb_write(address, data_to_device);
        MASTER.apb_read(address, data_from_device);
        $display("Addr= 0x%h, write data 0x%h, read data 0x%h", address, data_to_device, data_from_device);

        $display("==========================================================");
        $display("=== PART 2: INDIVIDUAL TASK (STEP 9) ===");
        $display("==========================================================");

        // 1. Запись по адресу 0x0: номер в списке группы (14)
        address        = p_device_offset + 32'h0;
        data_to_device = 32'd14;
        MASTER.apb_write(address, data_to_device);
        MASTER.apb_read(address, data_from_device);
        $display("Addr= 0x%h, write data 0x%h (Group Num = %0d), read data 0x%h",
                 address, data_to_device, data_to_device, data_from_device);

        // 2. Запись по адресу 0x4: дата 11.11.2026 (0x1111_2026)
        address        = p_device_offset + 32'h4;
        data_to_device = 32'h1111_2026;
        MASTER.apb_write(address, data_to_device);
        MASTER.apb_read(address, data_from_device);
        $display("Addr= 0x%h, write data 0x%h (Date 11.11.2026), read data 0x%h",
                 address, data_to_device, data_from_device);

        // 3. Запись по адресу 0x8: первые 4 буквы фамилии Халилов ("KHAL")
        address        = p_device_offset + 32'h8;
        data_to_device = "KHAL";
        MASTER.apb_write(address, data_to_device);
        MASTER.apb_read(address, data_from_device);
        $display("Addr= 0x%h, write data 0x%h (ASCII: %s), read data 0x%h (ASCII: %s)",
                 address, data_to_device, data_to_device, data_from_device, data_from_device);

        // 4. Запись по адресу 0xC: первые 4 буквы имени Аннур ("ANNU")
        address        = p_device_offset + 32'hC;
        data_to_device = "ANNU";
        MASTER.apb_write(address, data_to_device);
        MASTER.apb_read(address, data_from_device);
        $display("Addr= 0x%h, write data 0x%h (ASCII: %s), read data 0x%h (ASCII: %s)",
                 address, data_to_device, data_to_device, data_from_device, data_from_device);

        repeat (10) @(posedge pclk);
        $stop();
    end

    initial begin
        $monitor("APB IF state: PENABLE=%b PREADY=%b PADDR=0x%h PWDATA=0x%h PRDATA=0x%h",
                 penable, pready, paddr, pwdata, prdata);
    end

endmodule