`timescale 1ns / 1ps

module imm_Gen (
    input  logic [31:0] instruction,
    output logic [31:0] imm
);


    always_comb
        case (instruction[6:0])
            7'b0000011:  /*I-type load part*/
                imm = {instruction[31] ? 20'hFFFFF : 20'b0, instruction[31:20]};

            7'b0010011:  /*RI-Type*/
                imm = {instruction[31] ? 20'hFFFFF : 20'b0, instruction[31:20]};

            7'b0100011:  /*S-type*/
                imm = {instruction[31] ? 20'hFFFFF : 20'b0, instruction[31:25], instruction[11:7]};

            7'b1100011:  /*B-type*/
                imm = {
                    instruction[31] ? 19'h7FFFF : 19'b0,
                    instruction[31],
                    instruction[7],
                    instruction[30:25],
                    instruction[11:8],
                    1'b0
                };

            default: imm = {32'b0};

        endcase
        
endmodule
