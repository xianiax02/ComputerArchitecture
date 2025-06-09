`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/04 14:40:41
// Design Name: 
// Module Name: Control_Unit
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

module Control_unit(
    input [6:0] opcode,
    input RESETn,
    output reg [7:0] Ctl_out
);

always @(*) begin
    if (!RESETn) // control unit 반드시 0으로 reset
        Ctl_out = 8'b0;
    else
        case (opcode)
            // add, sub, ... (ALU 사용)
          /*  7'b0110011 : Ctl_out = 8'b00100010;  // R-type
            
            // addi, slli : shift left logical immediate rd = rs1 << imm (ALU 사용)
            7'b0010011 : Ctl_out = 8'b10010011;  // I-type MCC xxxi rd, rs1, imm[11:0]

            // lw (ALU 사용)
            7'b0000011 : Ctl_out = 8'b11000100;  // I-type LCC lxx rd, rs1, imm[11:0]

            // sw (ALU 사용)
            7'b0100011 : Ctl_out = 8'b10001000;  // S-type SCC sxx rs1, rs2, imm[11:0]

            // beq : branch equal (ALU 사용), go to PC+imm<<1
            7'b1100011 : Ctl_out = 8'b00000101;  // SB-type BCC bcc rs1, rs2, imm[12:1]

            // jal : jump and link           rd = PC+4,    go to PC+imm<<1
            7'b1101111 : Ctl_out = 8'b00000100;  // UJ-type JAL jal rd, imm[20:1]

            // jalr : jump and link register rd = PC+4,    go to rs1+imm (ALU 사용)
            7'b1100111 : Ctl_out = 8'b10010011;  // I-type JALR jalr rd, rs1, imm[11:0]

            default : Ctl_out = 8'b0;  // control unit 반드시 0으로 예외처리*/
            7'b0110011:	Ctl_out = 8'b00100010;
			7'b0010011:	Ctl_out = 8'b10100011;
			7'b0000011:	Ctl_out = 8'b11110000;
			7'b0100011:	Ctl_out = 8'b10001000;
			7'b1100011:	Ctl_out = 8'b00000101;
			7'b1101111:	Ctl_out = 8'b00100100;
			7'b1100111:	Ctl_out = 8'b10100111;
			7'b0010111:	Ctl_out = 8'b10100000;
			default:	Ctl_out = 8'b0;
        endcase
end

endmodule
