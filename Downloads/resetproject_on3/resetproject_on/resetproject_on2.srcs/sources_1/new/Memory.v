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
	input 	RESETn, CLK, 
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
   or(branch,zero,jalr_in,jal_in); //zero_in modified to zero hong
   and(PCSrc,Ctl_Branch_in, branch);   
reg [31:0] mem [383:0]; //32bit register 128�� ����
	
	
initial begin
    $readmemh("darksocv.ram.mem",mem);
 end


//DataMemory   
    always @(posedge CLK, negedge RESETn) begin
     if (!RESETn) begin //load = read
        Read_Data <= 0;
     end else  begin    
      if (Ctl_MemWrite_in) mem[ALUresult_in>>2] <= Write_Data;
      else Read_Data <= mem[ALUresult_in>>2];
  end
end
    
	
	// MEM/WB reg 
always @(posedge CLK, negedge RESETn) begin
		if (!RESETn) begin
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
	assign PCimm_out = (jalr_in)? ALUresult_in : PCimm_in;
endmodule

