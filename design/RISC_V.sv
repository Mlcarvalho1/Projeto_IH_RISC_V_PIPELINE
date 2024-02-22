`timescale 1ns / 1ps

import Pipe_Buf_Reg_PKG::*;

module riscv #(
        parameter PC_W       = 9 , // Program Counter
        parameter INS_W      = 32, // Instruction Width
        parameter DATA_W     = 32, // Data WriteData
        parameter DM_ADDRESS = 9   // Data Memory Address
    ) (
        input  logic                  clk ,
        input  logic                  reset ,
        // Para depuração no tesbench:
        output logic [PC_W-1:0]       tb_PC,
        output logic [4:0]            tb_reg_addr ,       //número do registrador que foi escrito
        output logic [DATA_W-1:0]     tb_reg_write_data , //valor que foi escrito no registrador
        output logic                  tb_reg_write,       //sinal de escrita no registrador
        output logic                  tb_mem_write ,      // write enable
        output logic                  tb_mem_read ,       // read enable
        output logic [DM_ADDRESS-1:0] tb_mem_addr ,       // address
        output logic [DATA_W-1:0]     tb_mem_write_data , // write data
        output logic [DATA_W-1:0]     tb_mem_read_data    // read data
    );


    logic [PC_W-1:0] pcadd_PC_plus_4;

    assign tb_PC = PC.next_PC;

    // next PC
    adder #(9) pcadd (
        PC.next_PC,
        9'b100,
        pcadd_PC_plus_4
    );

    logic [31:0]     bru_PC_result;
    logic            bru_pc_src ;  // mux select / flush signal
    logic [PC_W-1:0] pcmux_next_PC;

    mux2 #(9) pcmux (
        pcadd_PC_plus_4,
        PC_W'(bru_PC_result),
        bru_pc_src,
        pcmux_next_PC
    );

    logic hdu_stall ; //1: PC fetch same, Register not update

    PC_reg PC;
    always_ff @(posedge clk) begin
        if (reset) PC.next_PC           <= 0;
        else if (!hdu_stall) PC.next_PC <= pcmux_next_PC;
    end

    logic [INS_W-1:0] i_mem_instr;

    instructionmemory i_mem (
        clk,
        PC.next_PC,
        i_mem_instr
    );

    if_id_reg A;
    always @(posedge clk) begin
        if ((reset) || (bru_pc_src)) begin // initialization or flush
            A.current_PC    <= 0;
            A.current_instr <= 0;
        end
        else if (!hdu_stall) begin // stall
            A.current_PC    <= PC.next_PC;
            A.current_instr <= i_mem_instr;
        end
    end

    logic [6:0]  dc_opcode;
    logic [4:0]  dc_rd ;
    logic [4:0]  dc_rs1 ;
    logic [4:0]  dc_rs2 ;
    logic [2:0]  dc_funct3;
    logic [6:0]  dc_funct7;
    logic [31:0] dc_imm ;

    decoder dc (
        A.current_instr,
        dc_opcode,
        dc_rd ,
        dc_rs1 ,
        dc_rs2 ,
        dc_funct3,
        dc_funct7,
        dc_imm
    );

    HazardDetection detect (
        dc_rs1,
        dc_rs2,
        B.rd,
        B.mem_read,
        hdu_stall
    );

    logic [DATA_W-1:0] wbmux_reg_wb_data ;
    logic [DATA_W-1:0] rf_rs1, rf_rs2;


    RegFile rf (
        clk,
        reset,
        D.reg_write,
        D.rd,
        dc_rs1,
        dc_rs2,
        wbmux_reg_wb_data,
        rf_rs1,
        rf_rs2
    );

    assign tb_reg_addr = D.rd;
    assign tb_reg_write_data = wbmux_reg_wb_data;
    assign tb_reg_write = D.reg_write;

    logic [1:0] ctrl_ALU_op_type;
    logic       ctrl_ALU_src;
    logic       ctrl_mem_read;
    logic       ctrl_mem_write;
    logic [1:0] ctrl_branch_op;
    logic [1:0] ctrl_reg_write_src;
    logic       ctrl_reg_write;


    Controller ctrl (
        dc_opcode,
        ctrl_reg_write_src,
        ctrl_reg_write,
        ctrl_mem_read,
        ctrl_mem_write,
        ctrl_ALU_src,
        ctrl_ALU_op_type,
        ctrl_branch_op
    );


    id_ex_reg B;
    always @(posedge clk) begin
        if ((reset) || (hdu_stall) || (bru_pc_src)) begin // initialization or flush or generate a NOP if hazard
            B.ALU_src          <= 0;
            B.reg_wb_src       <= 0;
            B.reg_write        <= 0;
            B.mem_read         <= 0;
            B.mem_write        <= 0;
            B.ALU_op_type      <= 0;
            B.branch_op        <= 0;
            B.current_PC       <= 0;
            B.rd1              <= 0;
            B.rd2              <= 0;
            B.rs1              <= 0;
            B.rs2              <= 0;
            B.rd               <= 0;
            B.imm              <= 0;
            B.funct3           <= 0;
            B.funct7           <= 0;
            B.tb_current_instr <= A.current_instr; //debug tmp
        end
        else begin
            B.ALU_src          <= ctrl_ALU_src;
            B.reg_wb_src       <= ctrl_reg_write_src;
            B.reg_write        <= ctrl_reg_write;
            B.mem_read         <= ctrl_mem_read;
            B.mem_write        <= ctrl_mem_write;
            B.ALU_op_type      <= ctrl_ALU_op_type;
            B.branch_op        <= ctrl_branch_op;
            B.current_PC       <= A.current_PC;
            B.rd1              <= rf_rs1;
            B.rd2              <= rf_rs2;
            B.rs1              <= dc_rs1;
            B.rs2              <= dc_rs2;
            B.rd               <= dc_rd;
            B.imm              <= dc_imm;
            B.funct3           <= dc_funct3;
            B.funct7           <= dc_funct7;
            B.tb_current_instr <= A.current_instr; //debug tmp
        end
    end

    logic [1:0] fwu_mux_A_src ;
    logic [1:0] fwu_mux_B_src ;

    ForwardingUnit fwu (
        B.rs1,
        B.rs2,
        C.rd,
        D.rd,
        C.reg_write,
        D.reg_write,
        fwu_mux_A_src,
        fwu_mux_B_src
    );

    // // //ALU
    logic [DATA_W-1:0] fwu_mux_A_val;
    logic [DATA_W-1:0] fwu_mux_B_val;

    mux4 #(32) fwu_mux_A (
        B.rd1,
        wbmux_reg_wb_data,
        C.ALU_result,
        B.rd1,
        fwu_mux_A_src,
        fwu_mux_A_val
    );

    mux4 #(32) fwu_mux_B (
        B.rd2,
        wbmux_reg_wb_data,
        C.ALU_result,
        B.rd2,
        fwu_mux_B_src,
        fwu_mux_B_val
    );

    logic [DATA_W-1:0] ALUsrcmux_B_val;

    mux2 #(32) ALUsrcmux (
        fwu_mux_B_val,
        B.imm,
        B.ALU_src,
        ALUsrcmux_B_val
    );

    logic [3:0] ALU_ctrl_op;

    ALUController ALU_ctrl (
        B.ALU_op_type,
        B.funct7,
        B.funct3,
        ALU_ctrl_op
    );

    logic [DATA_W-1:0] ALU_result;

    alu ALU (
        fwu_mux_A_val,
        ALUsrcmux_B_val,
        ALU_ctrl_op,
        ALU_result
    );

    logic [31:0] bru_PC_plus_4;

    BranchUnit #(9) bru (
        B.current_PC,
        B.imm,
        B.branch_op,
        1'b0, // Halt ainda não implementado
        ALU_result,
        bru_PC_result,
        bru_PC_plus_4,
        bru_pc_src
    );


    ex_mem_reg C;
    always @(posedge clk) begin
        if (reset) begin // initialization
            C.reg_write  <= 0;
            C.reg_wb_src <= 0;
            C.mem_read   <= 0;
            C.mem_write  <= 0;
            C.pc_plus_4  <= 0;
            C.ALU_result <= 0;
            C.rd2        <= 0;
            C.rd         <= 0;
            C.funct3     <= 0;
            C.funct7     <= 0;
        end
        else begin
            C.reg_write        <= B.reg_write;
            C.reg_wb_src       <= B.reg_wb_src;
            C.mem_read         <= B.mem_read;
            C.mem_write        <= B.mem_write;
            C.pc_plus_4        <= bru_PC_plus_4;
            C.ALU_result       <= ALU_result;
            C.rd2              <= fwu_mux_B_val;
            C.rd               <= B.rd;
            C.funct3           <= B.funct3;
            C.funct7           <= B.funct7;
            C.tb_current_instr <= B.tb_current_instr; // debug tmp
        end
    end

    logic [DATA_W-1:0] mem_read_data;
    logic [8:0]        RW_address    = C.ALU_result[8:0];

    // // // // Data memory
    datamemory data_mem (
        clk,
        C.mem_read,
        C.mem_write,
        RW_address,
        C.rd2,
        C.funct3,
        mem_read_data
    );

    assign tb_mem_write = C.mem_write;
    assign tb_mem_read = C.mem_read;
    assign tb_mem_addr = C.ALU_result[8:0];
    assign tb_mem_write_data = C.rd2;
    assign tb_mem_read_data = mem_read_data;

    mem_wb_reg D;
    // MEM_WB_Reg D;
    always @(posedge clk) begin
        if (reset) begin // initialization
            D.reg_write     <= 0;
            D.reg_wb_src    <= 0;
            D.pc_plus_4     <= 0;
            D.ALU_result    <= 0;
            D.mem_read_data <= 0;
            D.rd            <= 0;
        end
        else begin
            D.reg_write        <= C.reg_write;
            D.reg_wb_src       <= C.reg_wb_src;
            D.pc_plus_4        <= C.pc_plus_4;
            D.ALU_result       <= C.ALU_result;
            D.mem_read_data    <= mem_read_data;
            D.rd               <= C.rd;
            D.tb_current_instr <= C.tb_current_instr; //Debug Tmp
        end
    end

    //--// The LAST Block

    mux4 #(32) wbmux (
        D.ALU_result,
        D.mem_read_data,
        D.pc_plus_4,
        32'b0,
        D.reg_wb_src,
        wbmux_reg_wb_data
    );


endmodule
