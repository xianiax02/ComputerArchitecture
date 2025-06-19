`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/27 09:01:57
// Design Name: 
// Module Name: Branch_Unit
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


module Branch_Unit(
    //branch criteria
    input [6:0] opcode,
    input [2:0] funct3,
    input [31:0] Read_data1, Read_data2, //Read_data1 == Rs1

    //target PC
    input [31:0] base_pc,
    input [31:0] offset, 

    //output
    output reg PCSrc,
    output [31:0] PC_imm
    );

    wire JAL = (opcode == 7'b11011_11);
    wire JALR = (opcode == 7'b11001_11);
    wire BRANCH = (opcode == 7'b11000_11);
    wire BEQ = (Read_data1 == Read_data2);
    wire BLT = (Read_data1 < Read_data2);

    always @(*) begin
        case (funct3)
            3'b000 : PCSrc = BEQ;
            3'b001 : PCSrc = !BEQ;
            3'b100 : PCSrc = BLT;
            3'b101 : PCSrc = !BLT;
            default : PCSrc = 0;
        endcase
        PCSrc =  JAL || JALR || (BRANCH && PCSrc);
    end

    assign PC_imm = (JALR)? Read_data1 : (base_pc + (offset<<1));

endmodule
