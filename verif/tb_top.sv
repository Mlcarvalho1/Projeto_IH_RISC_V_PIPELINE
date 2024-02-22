`timescale 1ns / 1ps

module tb_top;

    localparam CLKPERIOD  = 10;
    localparam CLKDELAY   = CLKPERIOD / 2;
    localparam NUM_CYCLES = 50;

    logic        clk;
    logic        reset;
    logic [8:0]  PC;
    logic [4:0]  reg_addr;
    logic [31:0] reg_write_data;
    logic        reg_write;
    logic        mem_write;
    logic        mem_read;
    logic [8:0]  mem_addr;
    logic [31:0] mem_write_data;
    logic [31:0] mem_read_data;

    riscv tb_riscv (
        .clk (clk),
        .reset (reset),
        .tb_PC (PC),
        .tb_reg_addr (reg_addr),
        .tb_reg_write_data (reg_write_data),
        .tb_reg_write (reg_write),
        .tb_mem_write (mem_write),
        .tb_mem_read (mem_read),
        .tb_mem_addr (mem_addr),
        .tb_mem_write_data(mem_write_data),
        .tb_mem_read_data (mem_read_data)
    );

    initial begin
        clk = 0;
        reset = 1;
        #(CLKPERIOD);
        reset = 0;

        #(CLKPERIOD * NUM_CYCLES);

        $stop;
    end

    always @(posedge clk) begin : REGISTER
        if (reg_write)
            $display($time, ": Register [%d] written with value: [%X] | [%d]\n", reg_addr, reg_write_data, $signed(reg_write_data));
    end : REGISTER

    always @(posedge clk) begin : MEMORY
        if (mem_write && ~mem_read)
            $display($time, ": Memory [%d] written with value: [%X] | [%d]\n", mem_addr, mem_write_data, $signed(mem_write_data));

        else if (mem_read && ~mem_write)
            $display($time, ": Memory [%d] read with value: [%X] | [%d]\n", mem_addr, mem_read_data, $signed(mem_read_data));
    end : MEMORY

    //clock generator
    always #(CLKDELAY) clk = ~clk;

endmodule
