`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:17:08 03/26/2022 
// Design Name: 
// Module Name:    Memory 
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
module Memory( 
	input 	reset, clk, 
	// control signal
	input 		Ctl_MemtoReg_in, 	Ctl_RegWrite_in, 	Ctl_MemRead_in, 	Ctl_MemWrite_in, 	Ctl_Branch_in,
	output reg	Ctl_MemtoReg_out, Ctl_RegWrite_out,
	// bypass
	input 		[ 4:0] Rd_in,
	output reg 	[ 4:0] Rd_out,
	//
	input       jal_in, jalr_in, bne_in,
	input 				 Zero_in,
	output 		PCSrc,
    output reg  jal_out, jalr_out,
    
    input 		[31:0] Write_Data, ALUresult_in, PCimm_in,PC_in,
	output reg	[31:0] Read_Data, ALUresult_out, PC_out,
	output 		[31:0] PCimm_out
   );
   wire branch;
   wire zero = bne_in^Zero_in;
   or(branch,jal_in,jalr_in,Zero_in);
   and(PCSrc,Ctl_Branch_in,branch);
   
	reg [31:0] mem [127:0]; //32bit register 128�� ����
	
	//Branch:[4]
	and(PCSrc,Ctl_Branch_in,Zero_in);
	
initial begin
    $readmemh("darksocv.ram.mem",mem);
 end

wire [29:0] mem_addr = ALUresult_in>>2;
//DataMemory   
    always @(posedge clk, negedge reset) begin
     if (!reset) begin //load = read
        Read_Data <= 0;
     end else  begin    
      if (Ctl_MemWrite_in) mem[mem_addr] <= Write_Data;
      else Read_Data <= mem[mem_addr];
  end
end
    
	
	// MEM/WB reg 
always @(posedge clk, negedge reset) begin
		if (!reset) begin
			Ctl_MemtoReg_out	<= 0;
			Ctl_RegWrite_out	<= 0;
			
			jalr_out            <= 0;
			jal_out             <= 0;
			PC_out              <= 0;
			
			ALUresult_out		<= 0;
			Rd_out				<= 0;
		end else begin
			Ctl_MemtoReg_out	<= Ctl_MemtoReg_in;
			Ctl_RegWrite_out	<= Ctl_RegWrite_in;
			
			jalr_out            <= jalr_in;
			jal_out             <= jal_in;
			PC_out              <= PC_in;
			
			ALUresult_out		<= ALUresult_in;
			Rd_out				<= Rd_in;
		end
	end
	assign PCimm_out = (jalr_in)? ALUresult_in: PCimm_in;
endmodule

