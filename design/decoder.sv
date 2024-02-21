module decoder (
    input  logic [31:0] instr ,
    output logic [ 2:0] opcode,
    output logic [ 4:0] rd    ,
    output logic [ 4:0] rs1   ,
    output logic [ 4:0] rs2   ,
    output logic [ 2:0] funct3,
    output logic [ 6:0] funct7,
    output logic [31:0] imm
);

    localparam OP     = 7'b0110011; //! (R-Type) Integer Register-Register Instructions
    localparam OP_IMM = 7'b0010011; //! (I-Type) Integer Register-Immediate Instructions
    localparam JALR   = 7'b1100111; //! (I-Type) Unconditional Jumps
    localparam LOAD   = 7'b0000011; //! (I-Type) Load Instruction
    localparam STORE  = 7'b0100011; //! (S-Type) Store Instruction
    localparam BRANCH = 7'b1100011; //! (B-Type) Conditional Branches
    localparam LUI    = 7'b0110111; //! (U-Type) Load Upper Immediate
    localparam JAL    = 7'b1101111; //! (J-Type) Unconditional Jumps


    always_comb begin
        opcode = instr[6:0];
        rd     = (OP || OP_IMM || JALR || LOAD || LUI || JAL) ? instr[11:7] : 0;
        rs1    = (OP || OP_IMM || JALR || LOAD || STORE || BRANCH) ? instr[19:15] : 0;
        rs2    = (OP || STORE || BRANCH) ? instr[24:20] : 0;
        funct3 = (OP || OP_IMM || JALR || LOAD || STORE || BRANCH) ? instr[14:12] : 0;
        funct7 = (OP) ? instr[31:25] : 0;

        case(opcode)
            OP      : imm = 32'b0;
            OP_IMM  : imm = 32'(signed'({instr[31:20]}));
            JALR    : imm = 32'(signed'({instr[31:20]}));
            LOAD    : imm = 32'(signed'({instr[31:20]}));
            STORE   : imm = 32'(signed'({instr[31:25], instr[11:7]}));
            BRANCH  : imm = 32'(signed'({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}));
            LUI     : imm = {instr[31:12], 12'b0};
            JAL     : imm = 32'(signed'({instr[31],instr[19:12],instr[20],instr[30:21], 1'b0}));
            default : imm = 32'b0;
        endcase
    end
endmodule