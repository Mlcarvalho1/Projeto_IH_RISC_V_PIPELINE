`timescale 1ns / 1ps

module BranchUnit #(parameter PC_W = 9) (
    input  logic [PC_W-1:0] current_PC  , //! Current Program Counter
    input  logic [    31:0] imm         , //! Generated immediate from imm_Gen
    input  logic            branch      , //! Signal from the Controller that the current instruction is a branch
    input  logic [    31:0] ALU_result  , //! Result from ALU comparison
    output logic [    31:0] next_PC_imm , //! PC+immediate
    output logic [    31:0] next_PC_four, //! PC+4
    output logic [    31:0] branch_PC   , //! PC+immediate if branch is taken, otherwise 0
    output logic            PC_sel        //! Signal to PC Mux wether branch will be taken
    //0: PC = PC+4
    //1: PC = branch_PC
);

    logic [31:0] PC_full;
    assign PC_full      = {23'b0, current_PC};
    assign next_PC_imm  = PC_full + imm;
    assign next_PC_four = PC_full + 32'b100;

    logic branch_result;
    assign branch_result = branch && ALU_result[0];
    assign branch_PC     = (branch_result) ? next_PC_imm : 32'b0;
    assign PC_sel        = branch_result;

endmodule
