`timescale 1ns / 1ps

module ALUController (
    //Inputs
    input  logic [1:0] ALUOp    , //! Instruction Code from the Controller
    //00: Load/Store
    //01: Control Transfer
    //10: Integer Computational
    input  logic [6:0] Funct7   , //! bits 25 to 31 of the instruction
    input  logic [2:0] Funct3   , //! bits 12 to 14 of the instruction
    //Output
    output logic [3:0] Operation  //! Code to the ALU, what operation it will perform
    // (ADD LOAD STORE) SUB XOR OR AND SLL SRL SRA (SLT BLT) BGE (SLTU BLTU) BGEU BEQ BNE
);

    assign Operation[0] = ((ALUOp == 2'b10) && (Funct3 == 3'b110)) ||  // R\I-or
        ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0000000)) ||  // R\I->>
            ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0100000));  // R\I->>>

    assign Operation[1] = (ALUOp == 2'b00) ||  // LW\SW
        ((ALUOp == 2'b10) && (Funct3 == 3'b000)) ||  // R\I-add
            ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0100000));  // R\I->>>

    assign Operation[2] = ((ALUOp==2'b10) && (Funct3==3'b101) && (Funct7==7'b0000000)) || // R\I->>
        ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0100000)) ||  // R\I->>>
            ((ALUOp == 2'b10) && (Funct3 == 3'b001)) ||  // R\I-<<
                ((ALUOp == 2'b10) && (Funct3 == 3'b010));  // R\I-<

    assign Operation[3] = (ALUOp == 2'b01) ||  // BEQ
        ((ALUOp == 2'b10) && (Funct3 == 3'b010));  // R\I-<
endmodule
