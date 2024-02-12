`timescale 1ns / 1ps

module Controller (
    //Input
    input  logic [6:0] Opcode  , //! 7-bit opcode field from the instruction
    //Outputs
    output logic       ALUSrc  , //! Signals Src Mux where the second ALU operand will come from
    //0: The operand comes from the ID/EX Register (Read Data 2);
    //1: The operand comes from Imm_Gen (the immediate offset for Load/Store Instructions)
    output logic       MemtoReg, //! Where the Write Back data will come from (Res MUX)
    //0: The value fed to the register Write data input comes from the ALU.
    //1: The value fed to the register Write data input comes from the Data Memory.
    output logic       RegWrite, //! The register on the Write register input is written with the value on the Write data input
    output logic       MemRead , //! Data memory contents designated by the address input are put on the Read data output
    output logic       MemWrite, //! Data memory contents designated by the address input are replaced by the value on the Write data input.
    output logic [1:0] ALUOp   , //! Signals the ALU Controller the type of instruction it will recieve
    //00: Load/Store
    //01: Control Transfer
    //10: Integer Computational
    output logic       Branch    //! Signal to the Branch Unit (Trough ID/EX)
);

    // Integer Computational Instructions
    logic [6:0] OP     = 7'b0110011; //! Integer Register-Register Instructions (R-Type)
    logic [6:0] OP_IMM = 7'b0010011; //! Integer Register-Immediate Instructions (I-Type)
    // Control Transfer Instructions
    logic [6:0] JAL    = 7'b1101111; //! Unconditional Jumps (J-Type)
    logic [6:0] JALR   = 7'b1100111; //! Unconditional Jumps (I-Type)
    logic [6:0] BRANCH = 7'b1100011; //! Conditional Branches (B-Type)
    // Load and Store Instructions
    logic [6:0] LOAD  = 7'b0000011; //! Load Instruction (I-Type)
    logic [6:0] STORE = 7'b0100011; //! Store Instruction (S-Type)

    assign ALUSrc   = (Opcode == LOAD || Opcode == STORE);
    assign MemtoReg = (Opcode == LOAD);
    assign RegWrite = (Opcode == OP || Opcode == LOAD);
    assign MemRead  = (Opcode == LOAD);
    assign MemWrite = (Opcode == STORE);
    assign ALUOp[0] = (Opcode == BRANCH);
    assign ALUOp[1] = (Opcode == OP);
    assign Branch   = (Opcode == BRANCH);

endmodule
