module apb_master
(
    input               pclk,
    input               presetn,
    output logic [31:0] paddr,
    output logic [31:0] pwdata,
    output logic        psel,
    output logic        penable,
    output logic        pwrite,
    input               pready,
    input               pslverr,
    input        [31:0] prdata
);

    initial begin
        psel    = '0;
        penable = '0;
        pwrite  = '0;
        paddr   = '0;
        pwdata  = '0;
    end

    task apb_write(input [31:0] addr, input [31:0] data);
        wait ((penable == 0) && (pready == 0));
        @(posedge pclk);
        psel         <= 1'b1;
        paddr[31:0]  <= addr[31:0];
        pwdata[31:0] <= data[31:0];
        pwrite       <= 1'b1;
        @(posedge pclk);
        penable      <= 1'b1;
        wait (pready == 1'b1);
        @(posedge pclk);
        psel         <= 1'b0;
        penable      <= 1'b0;
        pwrite       <= 1'b0;
        @(posedge pclk);
    endtask

    task apb_read(input [31:0] addr, output logic [31:0] data);
        wait ((penable == 0) && (pready == 0));
        @(posedge pclk);
        psel        <= 1'b1;
        pwrite      <= 1'b0;
        paddr[31:0] <= addr[31:0];
        @(posedge pclk);
        penable     <= 1'b1;
        wait (pready == 1'b1);
        data[31:0]  = prdata[31:0];
        @(posedge pclk);
        psel        <= 1'b0;
        penable     <= 1'b0;
        @(posedge pclk);
    endtask

endmodule