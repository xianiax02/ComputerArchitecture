`timescale 1ns / 1ps

//`define FPGA_MOD

module RISCVpipeline(
/// for FPGA
    input 	key,
	input [15:0] DIP_SW,
	output 	[ 7:0] digit,
	output 	[ 7:0] fnd,
	output 	[15:0] LED,

	input CLK, RESETn
	);

`ifdef FPGA_MOD
	wire clk_out;
	wire clk_inter = clk_out;
`else
	wire clk_inter = CLK;
`endif



	wire ind_ctl_0, ind_ctl_1, ind_ctl_2, ind_ctl_3, ind_ctl_4, ind_ctl_5, ind_ctl_6, ind_ctl_7;
	wire exe_ctl_0, exe_ctl_1, exe_ctl_2, exe_ctl_3, exe_ctl_4, exe_ctl_5, exe_ctl_6, exe_ctl_7;
	wire mem_ctl_0, mem_ctl_1, mem_ctl_2, mem_ctl_3, mem_ctl_4, mem_ctl_5, mem_ctl_6, mem_ctl_7;
	wire wb_ctl_0,  wb_ctl_1,  wb_ctl_2,  wb_ctl_3,  wb_ctl_4,  wb_ctl_5,  wb_ctl_6,  wb_ctl_7;
	
	wire hzd_stall;
	wire [ 1:0]  fwd_A, fwd_B;
	
	wire [31:0]  ind_pc, ind_data1, ind_data2, ind_imm;
    wire [31:0]	 exe_pc, exe_data2, exe_addr, exe_result;
    wire [31:0]  mem_pc, mem_addr, mem_result, mem_data;		
    wire [31:0]  wb_data;
	wire [4:0]	 ind_rd, ind_rs1, ind_rs2;	
	wire [4:0]   exe_rd;	
	wire [4:0]   mem_rd;	
	wire [4:0]   wb_rd;
	wire [6:0]	 ind_funct7;
	wire [2:0]	 ind_funct3;
	wire 		 ind_jal, ind_jalr, ind_bne;		
	wire         exe_jalr, exe_jal, exe_bne, exe_zero;	
	wire         mem_jalr, mem_jal, mem_PCSrc;

	wire [31:0] pc;
	wire [31:0] ins;

//for FPGA
	reg [31:0] cycle_counter; // counter for test program

	reg 	r_stop_counter;
	wire	stop_counter = (pc == 32'ha4) & (ind_data1 == 1); //c8
	wire	[31:0] clk_count;
	wire 	[31:0] RAM_address = exe_result;
	wire [31:0] led_out = key ? ins : cycle_counter;
	assign 	LED = r_stop_counter ? 16'hffff : 16'h0000;

	always @(posedge clk_inter, negedge RESETn) begin
		if(!RESETn) begin
			r_stop_counter <= 0;
		end else begin
			r_stop_counter <= stop_counter ? 1 : r_stop_counter;
		end
	end
	
	always @(posedge clk_inter, negedge RESETn) begin
		if(!RESETn) begin
			cycle_counter <=0;
		end else begin
			cycle_counter <= (pc >= 32'he8) ? cycle_counter + 1 : cycle_counter; //10c
		end
	end

`ifdef FPGA_MOD
	wire [2:0] LED_clk;
//////////////////////////////////////////////////////////////////////////////////////
	LED_channel LED0(
		.data(led_out),							.digit(digit),
		.LED_clk(LED_clk),					.fnd(fnd)
		);
//////////////////////////////////////////////////////////////////////////////////////

	counter A0_counter(
		.key1(key),
		.sw(DIP_SW),
		// .stop_counter(stop_counter),
		.clk(CLK),								.LED_clk(LED_clk),
		.rst(RESETn),								.clk_out(clk_out),
		.pc_in(ind_pc)						// .clk_count_out(clk_count)
		);
//////////////////////////////////////////////////////////////////////////////////////	
`endif


	InFetch A1_InFetch(		
	   .PCSrc(mem_PCSrc),
		.PCimm_in(mem_addr),
		.PC_out(pc),
		.instruction_out(ins),
		.reset(RESETn),
		.CLK(clk_inter)	

	);

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
    .reset(RESETn),
    .CLK(clk_iner)							
	);

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
    .mem_data(mem_result),           // forwarding (ALUresult)
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
    .reset(reset),
    .clk(clk_inter)
	);

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
    .reset(reset),
    .clk(clk)
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
