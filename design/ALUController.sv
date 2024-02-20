`timescale 1ns / 1ps

module ALUController (
    //Inputs
    input  logic [1:0] ALUOp,    // Instruction Code from the Controller
    input  logic [6:0] Funct7,   // bits 25 to 31 of the instruction
    input  logic [2:0] Funct3,   // bits 12 to 14 of the instruction

    //Output
    output reg [3:0] Operation   // Code to the ALU, what operation it will perform
);

    always_comb begin
        case (ALUOp)
            2'b00: // Load/Store
                Operation = 4'b0010; // Representing load/store operation

            2'b01: // Control Transfer (Branches)
                case(Funct3)
                    3'b000: Operation = 4'b1000; // BEQ -> SUB
                    3'b001: Operation = 4'b0011; // BNE
                    3'b100: Operation = 4'b0111; // BLT
                    3'b101: Operation = 4'b0110; // BGE
                    default: begin
                        $display("ALU_CONTROL_NOT_SPECIFIED\n");
                    end
                endcase

            2'b10: // Integer Computational (RType)
                case (Funct3)
                    3'b000:
                        case (Funct7)
                            7'b0000000: Operation = 4'b0010; // ADD
                            7'b0100000: Operation = 4'b0001; // SUB
                            default: Operation = 4'b0010; // ADDI
                        endcase
                    3'b100: Operation = 4'b0101; // XOR
                    3'b110: Operation = 4'b0100; // OR
                    3'b111: Operation = 4'b0000; // AND
                endcase
            default: begin
                Operation = 4'b0000;
                $display("ALU_CONTROL_NOT_SPECIFIED\n");
            end
        endcase
    end
endmodule
