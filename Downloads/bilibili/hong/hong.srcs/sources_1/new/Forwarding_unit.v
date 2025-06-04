`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/21 13:47:41
// Design Name: 
// Module Name: Forwarding_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Forwarding_unit(
	input mem_Ctl_RegWrite_in, wb_Ctl_RegWrite_in,
	input [4:0] Rs1_in, Rs2_in, mem_Rd_in, wb_Rd_in,
	output [1:0] ForwardA_out, ForwardB_out,
    //EXE/MEM to EF/DE forwarding
    output ForwardA_Dec_out, ForwardB_Dec_out
	);
	assign ForwardA_out = (mem_Rd_in == Rs1_in && mem_Ctl_RegWrite_in && Rs1_in != 0) ? 2'b10 : 	
						  (wb_Rd_in  == Rs1_in && wb_Ctl_RegWrite_in && Rs1_in != 0 )? 2'b01 : 2'b00; 
	
	assign ForwardB_out = (mem_Rd_in == Rs2_in && mem_Ctl_RegWrite_in && Rs2_in != 0) ? 2'b10 : 	
						  (wb_Rd_in  == Rs2_in && wb_Ctl_RegWrite_in && Rs2_in != 0 )? 2'b01 : 2'b00;
			
    assign ForwardA_Dec_out = ( mem_Rd_in == Rs1_in && mem_Ctl_RegWrite_in&& Rs1_in != 0) ? 1:0;
    assign ForwardB_Dec_out = ( mem_Rd_in == Rs2_in && mem_Ctl_RegWrite_in&& Rs2_in != 0) ? 1:0;
endmodule
