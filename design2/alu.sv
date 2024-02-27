`timescale 1ns / 1ps

module alu #(
        parameter DATA_WIDTH    = 32,
        parameter OPCODE_LENGTH = 4
    ) (
        input  logic [ DATA_WIDTH-1:0]   SrcA ,
        input  logic [ DATA_WIDTH-1:0]   SrcB ,
        input  logic [OPCODE_LENGTH-1:0] Operation,
        output logic [ DATA_WIDTH-1:0]   ALUResult
    );
    always_comb begin
        case(Operation)
            4'd01 : // ADD / LOAD / STORE
                ALUResult = signed'(SrcA) + signed'(SrcB);
            4'd02 : // SUB
                ALUResult = signed'(SrcA) - signed'(SrcB);
            4'd03: // XOR
                ALUResult = SrcA ^ SrcB;
            4'd04: // OR
                ALUResult = SrcA | SrcB;
            4'd05 : // AND
                ALUResult = SrcA & SrcB;
            4'd06 : // SLL
                ALUResult = SrcA << SrcB;
            4'd07 : // SRL
                ALUResult = SrcA >> SrcB;
            4'd08 : // SRA
                ALUResult = signed'(SrcA) >>> signed'(SrcB);
            4'd9 : // BEQ
                ALUResult = 32'(signed'(SrcA) == signed'(SrcB));
            4'd10: // BNE
                ALUResult = 32'(signed'(SrcA) != signed'(SrcB));
            4'd11: // BLT / SLT
                ALUResult = 32'(signed'(SrcA) < signed'(SrcB));
            4'd12: // BGE
                ALUResult = 32'(signed'(SrcA) >= signed'(SrcB));
	    4'd13: // LUI
		ALUResult = 20'(SrcB);
            default :
                ALUResult = 32'b0;
        endcase
    end
endmodule

