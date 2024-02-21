package Pipe_Buf_Reg_PKG;

    // Reg PC
    typedef struct packed{
        logic [8:0] next_PC;
    } PC_reg;

    // Reg A
    typedef struct packed {
        logic [ 8:0] current_PC ;
        logic [31:0] current_instr;
    } if_id_reg;

    // Reg B
    typedef struct packed {
        logic ALU_src ;
        logic [ 1:0] reg_wb_src ;
        logic reg_write ;
        logic mem_read ;
        logic mem_write ;
        logic [ 1:0] ALU_op ;
        logic [ 1:0] branch_op;
        logic [ 8:0] current_PC ;
        logic [31:0] rd1 ;
        logic [31:0] rd2 ;
        logic [ 4:0] rs1 ;
        logic [ 4:0] rs2 ;
        logic [ 4:0] rd ;
        logic [31:0] imm ;
        logic [ 2:0] funct3 ;
        logic [ 6:0] funct7 ;
        logic [31:0] tb_current_instr ;
    } id_ex_reg;

    // Reg C
    typedef struct packed {
        logic reg_write ;
        logic [ 1:0] reg_wb_src ;
        logic mem_read ;
        logic mem_write ;
        logic [31:0] pc_plus_4 ;
        logic [31:0] ALU_result;
        logic [31:0] rd2 ;
        logic [ 4:0] rd ;
        logic [ 2:0] funct3 ;
        logic [ 6:0] funct7 ;
        logic [31:0] tb_current_instr;
    } ex_mem_reg;

    // Reg D
    typedef struct packed {
        logic reg_write ;
        logic [ 1:0] reg_wb_src ;
        logic [31:0] pc_plus_4 ;
        logic [31:0] ALU_result ;
        logic [31:0] mem_read_data;
        logic [ 4:0] rd ;
        logic [31:0] tb_current_instr ;
    } mem_wb_reg;
endpackage
