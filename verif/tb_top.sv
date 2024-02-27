`timescale 1ns / 1ps

module tb_top;

    //clock and reset signal declaration
    logic        tb_clk, reset;
    logic [4:0]  reg_num;
    logic [31:0] reg_data;
    logic        reg_write_sig;
    logic        wr;
    logic        rd;
    logic [8:0]  addr;
    logic [31:0] wr_data;
    logic [31:0] rd_data;

    localparam CLKPERIOD  = 10;
    localparam CLKDELAY   = CLKPERIOD / 2;
    localparam NUM_CYCLES = 100;

    riscv riscV (
        .clk(tb_clk),
        .reset(reset),
        .reg_num(reg_num),
        .reg_data(reg_data),
        .reg_write_sig(reg_write_sig),
        .wr(wr),
        .rd(rd),
        .addr(addr),
        .wr_data(wr_data),
        .rd_data(rd_data)
    );

    initial begin
        tb_clk = 0;
        reset  = 1;
        #(CLKPERIOD);
        reset = 0;

        #(CLKPERIOD * NUM_CYCLES);

        $stop;
    end

    always @(posedge tb_clk) begin : REGISTER
        if (reg_write_sig)
            $display($time," REG Write: reg[%d] value[%d] | [%d] | [%b]\n", reg_num, reg_data, $signed(reg_data), reg_data);
    end : REGISTER

    always @(posedge tb_clk) begin : MEMORY
        if (wr && ~rd)
            $display($time," MEM Write: addr[%d] reg value[%d] | [%d] | [%b]\n", addr, wr_data, $signed(wr_data), wr_data);
        // No caso de SB e SH, o testbench só mostra o valor do registrador que escreveu. Dar LW pra testar o valor realmente escrito

        else if (rd && ~wr)
            $display($time," MEM Read: addr[%d] mem value[%d] | [%d] | [%b]\n", addr, rd_data, $signed(rd_data), rd_data);
    end : MEMORY

    //clock generator
    always #(CLKDELAY) tb_clk = ~tb_clk;

endmodule
