`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:41:04 05/12/2022 
// Design Name: 
// Module Name:    RISCVpipeline 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module RISCVpipeline(
	
	output [31:0] current_pc,
	output [31:0] instruction,

	input clk, RESETn
	);
	wire c;
	wire [1:0] LED_clk;
	wire [31:0] pc, ins;
	wire ind_ctl_0, ind_ctl_1, ind_ctl_2, ind_ctl_3, ind_ctl_4, ind_ctl_5, ind_ctl_6, ind_ctl_7;
	wire exe_ctl_0, exe_ctl_1, exe_ctl_2, exe_ctl_3, exe_ctl_4, exe_ctl_5, exe_ctl_6, exe_ctl_7;
	wire mem_ctl_0, mem_ctl_1, mem_ctl_2, mem_ctl_3, mem_ctl_4, mem_ctl_5, mem_ctl_6, mem_ctl_7;
	wire wb_ctl_0,  wb_ctl_1,  wb_ctl_2,  wb_ctl_3,  wb_ctl_4,  wb_ctl_5,  wb_ctl_6,  wb_ctl_7;
	
	wire [31:0]  ind_pc,exe_pc,mem_pc;
   wire [31:0]	 ind_data1, ind_data2, ind_imm,			exe_data2, exe_addr, exe_result,		mem_addr, mem_result, mem_data,		wb_data;
	wire [4:0]	 ind_rd,	exe_rd,	mem_rd,	wb_rd, ind_rs1, ind_rs2;
	wire [6:0]	 ind_funct7;
	wire [2:0]	 ind_funct3;
	wire 	     ind_jal, ind_jalr,ind_bne;
	wire exe_jal, exe_jalr, exe_bne, exe_zero;
	wire mem_jalr, mem_jal,mem_PCSrc;
	wire hzd_stall;
	wire [1:0] fwd_A, fwd_B;
	wire flush;
	wire [31:0] forwarded_from_mem; 
	
	assign current_pc = pc;
	assign instruction = ins;
	assign flush = mem_PCSrc | mem_jal | mem_jalr;
	assign forwarded_from_mem = (exe_ctl_1) ? mem_data : mem_result; //added to select whether load inst or operation inst data hong
////////////////////////
	InFetch A1_InFetch(		
		.PCSrc(mem_PCSrc),
		.PCimm_in(mem_addr),
		.PC_out(pc),
		.instruction_out(ins),
		.PCWrite(~hzd_stall),
		.RESETn(RESETn),
		.CLK(clk));					
////////////////////////
	InDecode A3_InDecode(

                                     .Ctl_ALUSrc_out(ind_ctl_0),
                                     .Ctl_MemtoReg_out(ind_ctl_1),
  .Ctl_RegWrite_in(wb_ctl_2),        .Ctl_RegWrite_out(ind_ctl_2),
                                    .Ctl_MemRead_out(ind_ctl_3),
                                    .Ctl_MemWrite_out(ind_ctl_4),
                                     .Ctl_Branch_out(ind_ctl_5),
                                     .Ctl_ALUOpcode1_out(ind_ctl_6),
                                     .Ctl_ALUOpcode0_out(ind_ctl_7),  // data Hazard
                                     
    .stall(hzd_stall),
    .flush(flush),                   // control Hazard

    .Rs1_out(ind_rs1),               // forwarding
    .Rs2_out(ind_rs2),               // forwarding

    .PC_in(pc),                      .PC_out(ind_pc),
                                     .jalr_out(ind_jalr),
                                     .jal_out(ind_jal),
                                     .bne_out(ind_bne),

    .instruction_in(ins),
                                    .ReadData1_out(ind_data1),
                                    .ReadData2_out(ind_data2),
                                    .Immediate_out(ind_imm),
                                    .Rd_out(ind_rd),
                                    .funct7_out(ind_funct7),
                                    .funct3_out(ind_funct3),

    .WriteReg(wb_rd),
    .WriteData(wb_data),
    .RESETn(RESETn),
    .CLK(clk)
);
////////////////////////
Hazard_detection_unit A3_Hazard (
    .exe_Ctl_MemRead_in(ind_ctl_3),
    .Rd_in(ind_rd),
    .instruction_in(ins[24:15]), // Rs1, Rs2
    .stall_out(hzd_stall)
);

Execution A4_Execution(
    .Ctl_ALUSrc_in(ind_ctl_0),        //.Ctl_ALUSrc_out(exe_ctl[0]),
    .Ctl_MemtoReg_in(ind_ctl_1),      .Ctl_MemtoReg_out(exe_ctl_1),
    .Ctl_RegWrite_in(ind_ctl_2),      .Ctl_RegWrite_out(exe_ctl_2),
    .Ctl_MemRead_in(ind_ctl_3),       .Ctl_MemRead_out(exe_ctl_3),
    .Ctl_MemWrite_in(ind_ctl_4),      .Ctl_MemWrite_out(exe_ctl_4),
    .Ctl_Branch_in(ind_ctl_5),        .Ctl_Branch_out(exe_ctl_5),
    .Ctl_ALUOpcode1_in(ind_ctl_6),    //.Ctl_ALUopcoded_out(exe_ctl_6),
    .Ctl_ALUOpcode0_in(ind_ctl_7),     //.Ctl_ALUopcode_out(exe_ctl_7),
                                      //.Ctl_BranchNEQ_out(exe_ctl_6),

    .ForwardA_in(fwd_A),              // forwarding
    .ForwardB_in(fwd_B),              // forwarding
    .mem_data(forwarded_from_mem),           // forwarding (ALUresult)
    .wb_data(wb_data),               // forwarding (ALUresult or Memdata=lw)
    .flush(flush),                   // control Hazard

                                       .PCimm_out(exe_addr),
                                       .Zero_out(exe_zero),
                                       .ALUresult_out(exe_result),

    .PC_in(ind_pc),                   .PC_out(exe_pc),
    .jalr_in(ind_jalr),               .jalr_out(exe_jalr),
    .jal_in(ind_jal),                 .jal_out(exe_jal),
    .bne_in(ind_bne),                 .bne_out(exe_bne),

    .ReadData1_in(ind_data1),
    .ReadData2_in(ind_data2),         .ReadData2_out(exe_data2),
    .Immediate_in(ind_imm),
    .Rd_in(ind_rd),                   .Rd_out(exe_rd),
    .funct7_in(ind_funct7),
    .funct3_in(ind_funct3),
    .RESETn(RESETn),
    .CLK(clk)
);
////////////////////////			
Forwarding_unit A5_Forwarding (
    .mem_Ctl_RegWrite_in(exe_ctl_2),
    .wb_Ctl_RegWrite_in(mem_ctl_2),

    .Rs1_in(ind_rs1),                .ForwardA_out(fwd_A),
    .Rs2_in(ind_rs2),                .ForwardB_out(fwd_B),
    .mem_Rd_in(exe_rd),
    .wb_Rd_in(mem_rd)
);

Memory A6_Memory(
    .Ctl_MemtoReg_in(exe_ctl_1),     .Ctl_MemtoReg_out(mem_ctl_1),
    .Ctl_RegWrite_in(exe_ctl_2),     .Ctl_RegWrite_out(mem_ctl_2),
    .Ctl_MemRead_in(exe_ctl_3),
    .Ctl_MemWrite_in(exe_ctl_4),
    .Ctl_Branch_in(exe_ctl_5),

// =========================================
    .PC_in(exe_pc),                  .PC_out(mem_pc),
    .jalr_in(exe_jalr),              .jalr_out(mem_jalr),
    .jal_in(exe_jal),                .jal_out(mem_jal),
    .bne_in(exe_bne),

    .PCimm_in(exe_addr),             .PCimm_out(mem_addr),
    .Zero_in(exe_zero),              .PCSrc(mem_PCSrc),
    .ALUresult_in(exe_result),       .ALUresult_out(mem_result),
    .Write_Data(exe_data2),          .Read_Data(mem_data),
    .Rd_in(exe_rd),                  .Rd_out(mem_rd),
    .RESETn(RESETn),
    .CLK(clk)
// =========================================
);

WB A7_WB(
    .Ctl_MemtoReg_in(mem_ctl_1),
    .Ctl_RegWrite_in(mem_ctl_2),     .Ctl_RegWrite_out(wb_ctl_2),

    .PC_in(mem_pc),
    .jalr_in(mem_jalr),
    .jal_in(mem_jal),

    .ReadDatafromMem_in(mem_data),   .WriteDatatoReg_out(wb_data),
    .ALUresult_in(mem_result),
    .Rd_in(mem_rd),                  .Rd_out(wb_rd)
    );

endmodule


