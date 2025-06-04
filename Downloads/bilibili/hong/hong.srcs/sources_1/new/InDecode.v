`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/14 15:58:34
// Design Name: 
// Module Name: InDecode
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
            7'b0110011 : Ctl_out = 8'b10010010;  // R-type
            
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

            default : Ctl_out = 8'b0;  // control unit 반드시 0으로 예외처리
        endcase
end

endmodule

module InDecode(
    input CLK, RESETn,
    // forwarding
    input stall,
    //control Hazard
    input flush,
    //forwarding
    input Ctl_RegWrite_in,
    // control signal
    output reg Ctl_ALUSrc_out, Ctl_ALUOpcode1_out, Ctl_ALUOpcode0_out,  //Execution
    output reg Ctl_MemWrite_out, Ctl_MemRead_out, Ctl_Branch_out,  //Memory
    output reg  Ctl_MemtoReg_out, Ctl_RegWrite_out, //Writeback
    //
    input [ 4:0] WriteReg, //reg주소 bit = 32개의 주소
    input [31:0] PC_in, instruction_in,WriteData,


    output reg [ 4:0] Rd_out, Rs1_out, Rs2_out,
    output reg [31:0] PC_out, ReadData1_out, ReadData2_out, Immediate_out,
    output reg [ 6:0] funct7_out,  // RISC-V
    output reg [ 2:0] funct3_out,  // RISC-V
    output reg        jalr_out, jal_out,bne_out
);
wire ForwardA_Dec, ForwardB_Dec;
 //Branch unit
 wire [31:0] Branch_read_data1 = ForwardA_Dec ?WriteData: Reg[Rs1];
 
 wire [31:0] Branch_read_data2 = ForwardB_Dec ?WriteData: Reg[Rs2];
 
 Branch_Unit B1(
    .opcode(opcode),
    .funct3(funct3),
    .Read_data1(Branch_read_data1),
    .Read_data2(Branch_read_data2),
    
    .base_pc(PC_in),
    .offset(Immediate),
    .PCSrc(PCSrc_out),
    .PC_imm(PCimm_out)
    );
 `define JAL     7'b11011_11 //jal rd,imm[xxxx]
`define JALR    7'b11001_11  //jalr rd, rs1,imm[11:0]

 wire [6:0] opcode = instruction_in[6:0];
 wire [6:0] funct7 = instruction_in[31:25];
 wire [2:0] funct3 = instruction_in[14:12];
 wire [4:0] Rd     = instruction_in[11:7];
 wire [4:0] Rs1    = instruction_in[19:15];
 wire [4:0] Rs2    = instruction_in[24:20];
 wire       jalr   = (opcode == `JALR)?1:0;
 wire       jal    = (opcode == `JAL)?1:0;
 wire       bne    = (funct3 == 3'b001)? 1:0;
 wire [7:0] Ctl_out;

Control_unit B0 (.opcode(instruction_in[6:0]), .Ctl_out(Ctl_out),.RESETn(RESETn));
reg [7:0] Control;
always @(*) begin
    Control = (stall||flush)? 8'b0:Ctl_out;
end
//Register


parameter reg_size = 32;
reg [31:0] Reg[0: reg_size-1]; //32bit reg
integer i;


always@(posedge CLK, negedge RESETn) begin  
    if (!RESETn) begin
        for (i = 0; i < reg_size; i = i + 1) begin
            Reg[i] <= 32'b0;
            end
    end else if((Ctl_RegWrite_in) && (WriteReg!=0)) begin
        Reg[WriteReg] <= WriteData;
        end
end

reg [31:0] Immediate;
always @(*) begin
    case (opcode)
        7'b00000_11: Immediate = $signed(instruction_in[31:20]); // I-type
        7'b00100_11: Immediate = $signed(instruction_in[31:20]); // I-type
        7'b11001_11: Immediate = $signed(instruction_in[31:20]); // I-type jalr 포함
        7'b01000_11: Immediate = $signed({instruction_in[31:25], instruction_in[11:7]}); // S-type
        7'b11000_11: Immediate = $signed({instruction_in[31], instruction_in[7], instruction_in[30:25], instruction_in[11:8], 1'b0}); // B-type
        7'b11011_11: Immediate = $signed({instruction_in[31], instruction_in[19:12], instruction_in[20], instruction_in[30:21], 1'b0}); // J-type
        
        default:    Immediate = 32'b0;
    endcase
end

// ID/EX reg

always @(posedge CLK, negedge RESETn) begin
    if(!RESETn) begin
        PC_out           <= 0;
        funct7_out       <= 0;
        funct3_out       <= 0;
        Rd_out           <= 0;
        Rs1_out          <= 0;
        Rs2_out          <= 0;
        ReadData1_out    <= 0;
        ReadData2_out    <= 0;
        jalr_out         <= 0;
        jal_out          <= 0;
        Ctl_ALUSrc_out   <= 0;
        Ctl_MemtoReg_out <= 0;
        Ctl_RegWrite_out <= 0;
        Ctl_MemRead_out  <= 0;
        Ctl_MemWrite_out <= 0;
        Ctl_Branch_out   <= 0;
        Ctl_ALUOpcode1_out <= 0;
        Ctl_ALUOpcode0_out <= 0;
        Immediate_out    <= 0;
    end else begin
        PC_out           <= PC_in;
        funct7_out       <= funct7;
        funct3_out       <= funct3;
        Rd_out           <= Rd;
        Rs1_out          <= Rs1;
        Rs2_out          <= Rs2;
        ReadData1_out    <= (Ctl_RegWrite_in && WriteReg==Rs1&&WriteReg!=0)? WriteData: Reg[Rs1]; //forwarding
        ReadData2_out    <= (Ctl_RegWrite_in && WriteReg==Rs2&&WriteReg!=0)? WriteData: Reg[Rs2];
        jalr_out         <= jalr;
        jal_out          <= jal;
        bne_out          <= bne;
        Ctl_ALUSrc_out   <= Control[7];
        Ctl_MemtoReg_out <= Control[6];
        Ctl_RegWrite_out <= Control[5];
        Ctl_MemRead_out  <= Control[4];
        Ctl_MemWrite_out <= Control[3];
        Ctl_Branch_out   <= Control[2];
        Ctl_ALUOpcode1_out <= Control[1];
        Ctl_ALUOpcode0_out <= Control[0];
        Immediate_out       <= Immediate;
        end
     end
 endmodule
