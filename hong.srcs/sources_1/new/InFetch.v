`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/14 16:00:17
// Design Name: 
// Module Name: InFetch
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

module InFetch(
    input CLK, reset, PCSrc,
    input [31:0] PCimm_in,
    input PCWrite,
    output [31:0] instruction_out,
    output reg [31:0] PC_out
    );
    wire [31:0] PC;
    wire [31:0] PC4 = (PCSrc)? PCimm_in: PC+4;
    wire [31:0] inst_out;
    
    PC B1_PC(
        .CLK(CLK),
        .reset(reset),
        .PCWrite(PCWrite),
        .PCSrc(PCSrc),
        .PC_in(PC4),
        .PC_out(PC)
    );
    iMEM B2_iMEM(
        .CLK(CLK),
        .reset(reset),
        .IF_ID_Write(PCWrite),
        .PCSrc(PCSrc),
        .PC_in(PC),
        .instruction_out(instruction_out));
    always @(posedge CLK, negedge reset) begin
        if(!reset) begin
            PC_out    <= 0;
        end else begin
            PC_out <= (PCWrite) ? PC4: PC;
        end
    end
endmodule

module PC(
    input CLK, reset,
    input PCWrite,
    input PCSrc,
    input [31:0] PC_in,
    output reg [31:0] PC_out
    );
     always @ (posedge CLK, negedge reset) begin
     if(!reset) begin
        PC_out <= 0;
     end else if (PCWrite) begin
        PC_out <= (PCSrc)?  PC_in : PC_out;
     end else begin
        PC_out <= PC_in;
     end
  end
endmodule
 
module iMEM(
    input CLK, reset,
    input IF_ID_Write, PCSrc,
    input [31:0] PC_in,
    output reg [31:0] instruction_out
    );
    parameter ROM_size = 128;
    (* ram_style = "block" *) reg [31:0] ROM [0:ROM_size-1];
    
    initial begin
        $readmemh("darksocv.rom.mem",ROM);
    end
 
    always @(posedge CLK) begin
        if(!reset) begin
            instruction_out <= 32'b0;
        end else begin
            if(IF_ID_Write) begin
                if(PCSrc)
                instruction_out <= 32'b0;
                 else
                instruction_out <= ROM[PC_in[31:2]];
             end
         end  
     end
endmodule
