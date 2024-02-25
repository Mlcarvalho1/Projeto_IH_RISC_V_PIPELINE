`timescale 1ns / 1ps

module Controller (
        //Input
        input  logic [6:0] opcode ,      //! 7-bit opcode field from the instruction
        //Outputs
        output logic       ALU_src ,     //! Signals Src Mux where the second ALU operand will come from
        //0: The operand comes from the ID/EX Register (Read Data 2);
        //1: The operand comes from Imm_Gen (the immediate offset for Load/Store Instructions)
        output logic [1:0] wb_data_src , //! Where the Write Back data will come from (Res MUX)
        //00: The value comes from the ALU.
        //01: The value comes from the Data Memory.
        //10: The value comes from PC+4
        //11: ----
        output logic       reg_write ,   //! RegFile register at the Write register input will be written with the value on the Write data input
        output logic       mem_read ,    //! Data Memory contents at the Adress input will be put on the Read data output
        output logic       mem_write ,   //! Data Memory contents at the Adress input will be replaced by the value on the Write data input
        output logic [1:0] ALU_op ,      //! Signals the ALU Controller the type of instruction it will recieve
        //00: Load/Store && JALR
        //01: Integer Computational
        //10: Branch
        //11: ----
        output logic [1:0] ctrl_transfer //! Signal to the Branch Unit
    //00: No Control Transfer
    //01: Branch
    //10: JAL
    //11: JALR
    );


    // Integer Computational Instructions
    localparam OP     = 7'b0110011; //! (R-Type) Integer Register-Register Instructions
    localparam OP_IMM = 7'b0010011; //! (I-Type) Integer Register-Immediate Instructions
    // Control Transfer Instructions
    localparam JAL    = 7'b1101111; //! (J-Type) Unconditional Jumps
    localparam JALR   = 7'b1100111; //! (I-Type) Unconditional Jumps
    localparam BRANCH = 7'b1100011; //! (B-Type) Conditional Branches
    // Load and Store Instructions
    localparam LOAD   = 7'b0000011; //! (I-Type) Load Instruction
    localparam LUI    = 7'b0110111; //! (U-Type) Load Upper Immediate
    localparam STORE  = 7'b0100011; //! (S-Type) Store Instruction


    always_comb begin
        ALU_src        = (opcode == LOAD || opcode == STORE || opcode == JALR);
        wb_data_src[0] = (opcode == LOAD);
        wb_data_src[1] = (opcode == JAL || opcode == JALR);
        reg_write      = (opcode == LOAD || opcode == OP || opcode == OP_IMM || opcode == JAL || opcode == JALR);
        mem_read       = (opcode == LOAD);
        mem_write      = (opcode == STORE);
        ALU_op[0]      = (opcode == OP || opcode == OP_IMM);
        ALU_op[1]      = (opcode == BRANCH);

        case (opcode)
            BRANCH  : ctrl_transfer = 2'b01;
            JAL     : ctrl_transfer = 2'b10;
            JALR    : ctrl_transfer = 2'b11;
            default : ctrl_transfer = 2'b00;
        endcase

    end


endmodule
