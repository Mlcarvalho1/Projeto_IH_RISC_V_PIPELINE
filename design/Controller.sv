`timescale 1ns / 1ps

module Controller (
    //Input
    input  logic [6:0] opcode     , //! 7-bit opcode field from the instruction
    //Outputs
    output logic       ALU_src    , //! Signals Src Mux where the second ALU operand will come from
    //0: The operand comes from the ID/EX Register (Read Data 2);
    //1: The operand comes from Imm_Gen (the immediate offset for Load/Store Instructions)
    output logic       WB_data_src, //! Where the Write Back data will come from (Res MUX)
    //0: The value comes from the ALU.
    //1: The value comes from the Data Memory.
    output logic       reg_write  , //! RegFile register at the Write register input will be written with the value on the Write data input
    output logic       mem_read   , //! Data Memory contents at the Adress input will be put on the Read data output
    output logic       mem_write  , //! Data Memory contents at the Adress input will be replaced by the value on the Write data input
    output logic [1:0] ALU_op     , //! Signals the ALU Controller the type of instruction it will recieve
    //00: Load/Store
    //01: Control Transfer
    //10: Integer Computational
    output logic       branch       //! Signal to the branch Unit (Trough ID/EX) the current instruction is a branch
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

    assign ALU_src     = (opcode == LOAD || opcode == STORE);
    assign WB_data_src = (opcode == LOAD);
    assign reg_write   = (opcode == OP || opcode == LOAD);
    assign mem_read    = (opcode == LOAD);
    assign mem_write   = (opcode == STORE);
    assign ALU_op[0]   = (opcode == BRANCH);
    assign ALU_op[1]   = (opcode == OP);
    assign branch      = (opcode == BRANCH);

endmodule
