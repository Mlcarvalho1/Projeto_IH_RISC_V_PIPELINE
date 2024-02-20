`timescale 1ns / 1ps

module comparator #(parameter WIDTH    = 32) (
    input  logic [WIDTH-1:0] srcA     ,
    input  logic [WIDTH-1:0] srcB     ,
    input  logic [      7:0] operation,
    output logic             result
);

    always_comb
        begin
            case(operation)
                4'h0    : result = (srcA == srcB); // EQ
                4'h1    : result = ~(srcA == srcB); // NEQ
                4'h4    : result = (signed'(srcA) < signed'(srcB)); // LT
                4'h5    : result = ~(signed'(srcA) < signed'(srcB)); // GE
                4'h6    : result = (srcA < srcB); // LTU
                4'h7    : result = ~(srcA < srcB); // GEU
                default : result = 0;
            endcase
        end
endmodule