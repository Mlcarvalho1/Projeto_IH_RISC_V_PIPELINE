`timescale 1ns / 1ps

import Pipe_Buf_Reg_PKG::*;

module Datapath #(
        parameter PC_W       = 9,  // Program Counter
        parameter INS_W      = 32, // Instruction Width
        parameter RF_ADDRESS = 5,  // Register File Address
        parameter DATA_W     = 32, // Data WriteData
        parameter DM_ADDRESS = 9,  // Data Memory Address
        parameter ALU_CC_W   = 4   // ALU Control Code Width
    ) (
        input  logic                  clk,
        input  logic                  reset,
        input  logic                  RegWrite,      // Register file writing enable
        input  logic [ 1:0]           MemtoReg,      // Memory or ALU or JAL MUX
        input  logic                  ALUsrc,
        input  logic                  MemWrite,      // Register file or Immediate MUX // Memroy Writing Enable
        input  logic                  MemRead,       // Memroy Reading Enable
        input  logic [ 1:0]           ctrl_transfer,
        input  logic [ 1:0]           ALUOp,
        input  logic [ ALU_CC_W-1:0]  ALU_CC,        // ALU Control Code ( input of the ALU )
        output logic [ 6:0]           opcode,
        output logic [ 6:0]           Funct7,
        output logic [ 2:0]           Funct3,
        output logic [ 1:0]           ALUOp_Current,
        output logic [ DATA_W-1:0]    WB_Data,       //Result After the last MUX
        // Para depuração no tesbench:
        output logic [ 4:0]           reg_num,       //número do registrador que foi escrito
        output logic [ DATA_W-1:0]    reg_data,      //valor que foi escrito no registrador
        output logic                  reg_write_sig, //sinal de escrita no registrador
        output logic                  wr,            // write enable
        output logic                  reade,         // read enable
        output logic [DM_ADDRESS-1:0] addr,          // address
        output logic [ DATA_W-1:0]    wr_data,       // write data
        output logic [ DATA_W-1:0]    rd_data        // read data
    );

    logic [ PC_W-1:0]  PC, PCPlus4, Next_PC;
    logic [ INS_W-1:0] Instr;
    logic [DATA_W-1:0] Reg1, Reg2;
    logic [DATA_W-1:0] ReadData;
    logic [DATA_W-1:0] SrcB, ALUResult;
    logic [DATA_W-1:0] ExtImm, BrImm, Old_PC_Four, BrPC;
    logic [DATA_W-1:0] WrmuxSrc;
    logic              PcSel;                           // mux select / flush signal
    logic [ 1:0]       FAmuxSel;
    logic [ 1:0]       FBmuxSel;
    logic [DATA_W-1:0] FAmux_Result;
    logic [DATA_W-1:0] FBmux_Result;
    logic              Reg_Stall;                       //1: PC fetch same, Register not update

    if_id_reg  A;
    id_ex_reg  B;
    ex_mem_reg C;
    mem_wb_reg D;

    // next PC
    adder #(9) pcadd (
        PC,
        9'b100,
        PCPlus4
    );
    mux2 #(9) pcmux (
        PCPlus4,
        BrPC    [PC_W-1:0],
        PcSel,
        Next_PC
    );
    flopr #(9) pcreg (
        clk,
        reset,
        Next_PC,
        Reg_Stall,
        PC
    );
    instructionmemory instr_mem (
        clk,
        PC,
        Instr
    );

    // IF_ID_Reg A;
    always @(posedge clk) begin
        if ((reset) || (PcSel)) begin // initialization or flush
            A.Curr_Pc    <= 0;
            A.Curr_Instr <= 0;
        end
        else if (!Reg_Stall) begin // stall
            A.Curr_Pc    <= PC;
            A.Curr_Instr <= Instr;
        end
    end

    logic [ 6:0] dc_opcode;
    logic [ 4:0] dc_rd;
    logic [ 4:0] dc_rs1;
    logic [ 4:0] dc_rs2;
    logic [ 2:0] dc_funct3;
    logic [ 6:0] dc_funct7;
    logic [31:0] dc_imm;

    decoder decode (
        A.Curr_Instr,
        dc_opcode,
        dc_rd,
        dc_rs1,
        dc_rs2,
        dc_funct3,
        dc_funct7,
        dc_imm
    );

    assign opcode = dc_opcode;

    //--// The Hazard Detection Unit
    HazardDetection detect (
        dc_rs1,
        dc_rs2,
        B.rd,
        B.MemRead,
        Reg_Stall
    );

    // //Register File
    RegFile rf (
        clk,
        reset,
        D.RegWrite,
        D.rd,
        dc_rs1,
        dc_rs2,
        WrmuxSrc,
        Reg1,
        Reg2
    );

    assign reg_num       = D.rd;
    assign reg_data      = WrmuxSrc;
    assign reg_write_sig = D.RegWrite;

    // ID_EX_Reg B;
    always @(posedge clk) begin
        if ((reset) || (Reg_Stall) || (PcSel)) begin // initialization or flush or generate a NOP if hazard
            B.ALUSrc        <= 0;
            B.MemtoReg      <= 0;
            B.RegWrite      <= 0;
            B.MemRead       <= 0;
            B.MemWrite      <= 0;
            B.ALUOp         <= 0;
            B.ctrl_transfer <= 0;
            B.Curr_Pc       <= 0;
            B.RD_One        <= 0;
            B.RD_Two        <= 0;
            B.RS_One        <= 0;
            B.RS_Two        <= 0;
            B.rd            <= 0;
            B.ImmG          <= 0;
            B.func3         <= 0;
            B.func7         <= 0;
            B.Curr_Instr    <= A.Curr_Instr; //debug tmp
        end
        else begin
            B.ALUSrc        <= ALUsrc;
            B.MemtoReg      <= MemtoReg;
            B.RegWrite      <= RegWrite;
            B.MemRead       <= MemRead;
            B.MemWrite      <= MemWrite;
            B.ALUOp         <= ALUOp;
            B.ctrl_transfer <= ctrl_transfer;
            B.Curr_Pc       <= A.Curr_Pc;
            B.RD_One        <= Reg1;
            B.RD_Two        <= Reg2;
            B.RS_One        <= dc_rs1;
            B.RS_Two        <= dc_rs2;
            B.rd            <= dc_rd;
            B.ImmG          <= dc_imm;
            B.func3         <= dc_funct3;
            B.func7         <= dc_funct7;
            B.Curr_Instr    <= A.Curr_Instr; //debug tmp
        end
    end

    //--// The Forwarding Unit
    ForwardingUnit forunit (
        B.RS_One,
        B.RS_Two,
        C.rd,
        D.rd,
        C.RegWrite,
        D.RegWrite,
        FAmuxSel,
        FBmuxSel
    );

    // // //ALU
    assign Funct7        = B.func7;
    assign Funct3        = B.func3;
    assign ALUOp_Current = B.ALUOp;

    mux4 #(32) FAmux (
        B.RD_One,
        WrmuxSrc,
        C.Alu_Result,
        B.RD_One,
        FAmuxSel,
        FAmux_Result
    );
    mux4 #(32) FBmux (
        B.RD_Two,
        WrmuxSrc,
        C.Alu_Result,
        B.RD_Two,
        FBmuxSel,
        FBmux_Result
    );
    mux2 #(32) srcbmux (
        FBmux_Result,
        B.ImmG,
        B.ALUSrc,
        SrcB
    );
    alu alu_module (
        FAmux_Result,
        SrcB,
        ALU_CC,
        ALUResult
    );

    logic [31:0] br_pc_plus_4;

    BranchUnit #(9) brunit (
        B.Curr_Pc,
        B.ImmG,
        B.ctrl_transfer,
        1'b0, // Halt ainda não implementado
        ALUResult,
        BrPC,
        br_pc_plus_4,
        PcSel
    );

    // EX_MEM_Reg C;
    always @(posedge clk) begin
        if (reset) begin // initialization
            C.RegWrite   <= 0;
            C.MemtoReg   <= 0;
            C.MemRead    <= 0;
            C.MemWrite   <= 0;
            C.pc_plus_4  <= 0;
            C.Alu_Result <= 0;
            C.RD_Two     <= 0;
            C.rd         <= 0;
            C.func3      <= 0;
            C.func7      <= 0;
        end
        else begin
            C.RegWrite   <= B.RegWrite;
            C.MemtoReg   <= B.MemtoReg;
            C.MemRead    <= B.MemRead;
            C.MemWrite   <= B.MemWrite;
            C.pc_plus_4  <= br_pc_plus_4;
            C.Alu_Result <= ALUResult;
            C.RD_Two     <= FBmux_Result;
            C.rd         <= B.rd;
            C.func3      <= B.func3;
            C.func7      <= B.func7;
            C.Curr_Instr <= B.Curr_Instr; // debug tmp
        end
    end

    // // // // Data memory
    datamemory data_mem (
        clk,
        C.MemRead,
        C.MemWrite,
        C.Alu_Result[8:0],
        C.RD_Two,
        C.func3,
        ReadData
    );

    assign wr      = C.MemWrite;
    assign reade   = C.MemRead;
    assign addr    = C.Alu_Result[8:0];
    assign wr_data = C.RD_Two;
    assign rd_data = ReadData;

    // MEM_WB_Reg D;
    always @(posedge clk) begin
        if (reset) begin // initialization
            D.RegWrite    <= 0;
            D.MemtoReg    <= 0;
            D.pc_plus_4   <= 0;
            D.Alu_Result  <= 0;
            D.MemReadData <= 0;
            D.rd          <= 0;
        end
        else begin
            D.RegWrite    <= C.RegWrite;
            D.MemtoReg    <= C.MemtoReg;
            D.pc_plus_4   <= C.pc_plus_4;
            D.Alu_Result  <= C.Alu_Result;
            D.MemReadData <= ReadData;
            D.rd          <= C.rd;
            D.Curr_Instr  <= C.Curr_Instr; //Debug Tmp
        end
    end

    //--// The LAST Block

    mux4 #(32) wbmux (
        D.Alu_Result,
        D.MemReadData,
        D.pc_plus_4,
        32'b0,
        D.MemtoReg,
        WrmuxSrc
    );

    assign WB_Data = WrmuxSrc;

endmodule
