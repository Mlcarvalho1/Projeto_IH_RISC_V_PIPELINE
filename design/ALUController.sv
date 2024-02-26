`timescale 1ns / 1ps

module ALUController (
        //Inputs
        input logic [1:0] ALUOp,  // Instruction Code from the Controller
        input logic [6:0] Funct7, // bits 25 to 31 of the instruction
        input logic [2:0] Funct3, // bits 12 to 14 of the instruction

        //Output
        output reg [3:0] Operation // Code to the ALU, what operation it will perform
    );

    always_comb begin
        case (ALUOp)
            2'b00: Operation = 4'd01; // Load/Store -> ADD

            2'b10: begin // Integer Computational
                case (Funct3)
                    3'h0: begin
                        case (Funct7)
                            7'h00 : Operation = 4'd01; // ADD
                            7'h20 : Operation = 4'd02; // SUB
                        endcase
                    end
                    3'h4: Operation = 4'd03; // XOR
                    3'h6: Operation = 4'd04; // OR
                    3'h7: Operation = 4'd05; // AND
                    3'h1: Operation = 4'd06; // SLL
                    3'h5: begin
                        case (Funct7)
                            7'h00: Operation = 4'd07; // SRL
                            7'h20: Operation = 4'd08; // SRA
                        endcase
                    end
                    3'h2: Operation = 4'd11; // SLT
                endcase
            end
            2'b01: begin // Control Transfer
                case (Funct3)
                    3'h0 : Operation = 4'd09; // BEQ
                    3'h1 : Operation = 4'd10; // BNE
                    3'h4 : Operation = 4'd11; // BLT
                    3'h5 : Operation = 4'd12; // BGE
                endcase
            end
            default: begin
                Operation = 4'd0;
                $display("ALU_CONTROL_NOT_SPECIFIED\n");
            end
        endcase
    end
endmodule
