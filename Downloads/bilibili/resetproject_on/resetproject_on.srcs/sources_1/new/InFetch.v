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
    input CLK, RESETn, 
    input PCSrc, //Control Signal
    input [31:0] PCimm_in,// PC+imm
    input PCWrite,
    output [31:0] instruction_out, //instruction from memory
    output reg [31:0] PC_out //Fetch pipeline register
    );
    wire [31:0] PC;
    wire [31:0] PC4 = (PCSrc)? PCimm_in: PC+4;
    wire [31:0] inst_out;
    
    PC B1_PC(
        .CLK(CLK),
        .RESETn(RESETn),
        .PCWrite(PCWrite),
        .PCSrc(PCSrc),
        .PC_in(PC4),
        .PC_out(PC)
    );
    iMEM B2_iMEM(
        .CLK(CLK),
        .RESETn(RESETn),
        .IF_ID_Write(PCWrite),
        .PCSrc(PCSrc),
        .PC_in(PC),
        .instruction_out(instruction_out));
        //IF/ID reg
    always @(posedge CLK, negedge RESETn) begin
        if(!RESETn) begin
            PC_out    <= 32'b0;
        end else begin
            PC_out <= (PCWrite) ? PC4: PC;
        end
    end
endmodule

module PC(
    input CLK, RESETn,
    input PCWrite,
    input PCSrc,
    input [31:0] PC_in,
    output reg [31:0] PC_out
    );
     always @ (posedge CLK, negedge RESETn) begin
     if(!RESETn) begin
        PC_out <= 0;
     end else if (PCWrite) begin
       // PC_out <= (PCSrc)?  PC_in : PC_out;
        PC_out <= PC_in;
     end else begin
        PC_out <=PC_out;
     end
  end
endmodule
 
module iMEM(
    input CLK, RESETn,
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
        if(!RESETn) begin
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
