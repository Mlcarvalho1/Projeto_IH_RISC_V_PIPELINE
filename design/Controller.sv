`timescale 1ns / 1ps

module Controller (
    //Input
    input  logic [6:0] opcode       , //! 7-bit opcode field from the instruction
    //Outputs
    output logic       ALU_src      , //! Signals Src Mux where the second ALU operand will come from
    //0: The operand comes from the ID/EX Register (Read Data 2);
    //1: The operand comes from Imm_Gen (the immediate offset for Load/Store Instructions)
    output logic       WB_data_src  , //! Where the Write Back data will come from (Res MUX) // #todo will need to become a 4MUX
    //0: The value comes from the ALU.
    //1: The value comes from the Data Memory.
    //10: The value comes from PC+4
    //11: ----
    output logic       reg_write    , //! RegFile register at the Write register input will be written with the value on the Write data input
    output logic       mem_read     , //! Data Memory contents at the Adress input will be put on the Read data output
    output logic       mem_write    , //! Data Memory contents at the Adress input will be replaced by the value on the Write data input
    output logic [1:0] ALU_op       , //! Signals the ALU Controller the type of instruction it will recieve
    //00: Load/Store && JALR
    //01: Integer Computational
    //10: Branch
    //11: ----
    output logic [1:0] ctrl_transfer  //! Signal to the Branch Unit
    //00: No Control Transfer
    //01: Branch
    //10: JAL
    //11: JALR
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


    always_comb begin
        ALU_src     = (opcode == LOAD || opcode == STORE || opcode == JALR);
        WB_data_src = (opcode == LOAD);
        reg_write   = (opcode == LOAD || opcode == OP || opcode == OP_IMM || opcode == JALR);
        mem_read    = (opcode == LOAD);
        mem_write   = (opcode == STORE);

        ALU_op[0] = (opcode == OP || opcode == OP_IMM || opcode == JALR);
        ALU_op[1] = (opcode == BRANCH);

        case (opcode)
            JALR    : ctrl_transfer = 2'b11;
            JAL     : ctrl_transfer = 2'b10;
            BRANCH  : ctrl_transfer = 2'b01;
            default : ctrl_transfer = 2'b00;
        endcase

    end


endmodule
