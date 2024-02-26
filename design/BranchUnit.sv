`timescale 1ns / 1ps

module BranchUnit #(
        parameter WIDTH = 9
    ) (
        input  logic [WIDTH-1:0] current_pc ,   //! Current Program Counter
        input  logic [ 31:0]     imm ,          //! Generated immediate from imm_Gen
        input  logic [ 1:0]      ctrl_transfer, //! Signal from the Controller that the current instruction is a branch
        input  logic             halt ,
        input  logic [ 31:0]     ALU_result ,   //! Result from ALU comparison
        output logic [ 31:0]     branch_pc ,    //! pc  depending on control transfer type
        output logic [ 31:0]     pc_plus_4 ,
        output logic             pc_sel         //! Signal to pc Mux wether branch will be taken
    //0: pc = pc+4
    //1: pc = branch_pc
    );


    localparam BRANCH = 2'b01;
    localparam JAL    = 2'b10;
    localparam JALR   = 2'b11;

    logic [31:0] pc_32;
    assign pc_32 = 32'(current_pc);

    always_comb begin
        pc_plus_4 = pc_32 + 32'd4;

        if (halt) begin
            pc_sel    = 1;
            branch_pc = 32'(-1);
            $display("=== HALT ===");
        end
        else begin
            case (ctrl_transfer)
                JAL : begin // JAL
                    pc_sel    = 1;
                    branch_pc = pc_32 + imm;
                end
                JALR : begin // JALR
                    pc_sel    = 1;
                    branch_pc = (ALU_result) & 32'hFFFFFFFE;
                end
                BRANCH : begin // BRANCH
                    pc_sel    = ALU_result[0];
                    branch_pc = pc_32 + imm;
                end
                default : pc_sel = 0;
            endcase
        end
    end

endmodule
