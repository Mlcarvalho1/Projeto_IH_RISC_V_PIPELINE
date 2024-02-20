`timescale 1ns / 1ps

module BranchUnit #(parameter PC_W = 9) (
    input  logic [PC_W-1:0] current_PC   , //! Current Program Counter
    input  logic [    31:0] imm          , //! Generated immediate from imm_Gen
    input  logic [     1:0] ctrl_transfer, //! Signal from the Controller that the current instruction is a branch
    //00: No Control Transfer
    //01: Branch
    //10: JAL
    //11: JALR
    input  logic [    31:0] ALU_result   , //! Result from ALU comparison
    output logic [    31:0] branch_PC    , //! PC  depending on control transfer type
    output logic            PC_sel         //! Signal to PC Mux wether branch will be taken
    //0: PC = PC+4
    //1: PC = branch_PC
);

    logic [31:0] PC_full;

    always_comb begin
        PC_full      = {23'b0, current_PC};
        next_PC_four = PC_full + 32'b100;

        case (ctrl_transfer)
            2'b00 : begin // NO CTRL
                PC_sel = 0;
            end
            2'b01 : begin // BRANCH
                PC_sel    = ALU_result[0];
                branch_PC = PC_full + imm;
            end
            2'b10 : begin // JAL
                PC_sel    = 1;
                branch_PC = PC_full + imm;
            end
            2'b11 : begin // JALR
                PC_sel    = 1;
                branch_PC = PC_full + ALU_result;
            end
        endcase
    end

endmodule
