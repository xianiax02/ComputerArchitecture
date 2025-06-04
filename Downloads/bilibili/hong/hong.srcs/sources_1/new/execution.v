
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/14 13:05:48
// Design Name: 
// Module Name: execution
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


module Execution(
	input 	clk,RESETn,
	input flush, // control hazard
	//contol signal
	input 		Ctl_ALUSrc_in, Ctl_MemtoReg_in, Ctl_ALUOpcode1_in, Ctl_ALUOpcode0_in,
	            Ctl_MemRead_in, Ctl_RegWrite_in, Ctl_MemWrite_in, Ctl_Branch_in, 
	output reg	Ctl_MemtoReg_out, Ctl_RegWrite_out, Ctl_MemRead_out,Ctl_MemWrite_out,	Ctl_Branch_out,
	// pass to MEM stage
	input 		[ 4:0] Rd_in,
	output reg 	[ 4:0] Rd_out,
	input        jal_in, jalr_in, bne_in,
	output reg  jal_out, jalr_out, bne_out,
	
	input 		[31:0] Immediate_in, ReadData1_in, ReadData2_in, PC_in,
	input       [31:0] mem_data, wb_data, 
	input 		[ 6:0] funct7_in, 
	input 		[ 2:0] funct3_in,
	//forwarding
	input        [ 1:0] ForwardA_in, ForwardB_in, 
	output reg			 Zero_out,
	
	output reg 	[31:0] ALUresult_out, PCimm_out, ReadData2_out,
	//used in jal/jalr instruction
	output reg [31:0] PC_out
	);
	
	//RISC-V
	wire [3:0] ALU_ctl;
	wire [31:0] ALUresult;
	wire zero;
	
	wire [31:0] ALU_input1 = (ForwardA_in==2'b0)? ReadData1_in:
	                         (ForwardA_in==2'b10)? mem_data:(ForwardA_in==2'b01)?wb_data:2'b0; 
	wire [31:0] ForwardB_input = (ForwardB_in==2'b0)? ReadData2_in:
	                             (ForwardB_in==2'b10)? mem_data:(ForwardB_in==2'b01)?wb_data:2'b0;
	wire [31:0] ALU_input2 =  (Ctl_ALUSrc_in)? Immediate_in:ForwardB_input;
		
	ALU_control B0 ({Ctl_ALUOpcode1_in, Ctl_ALUOpcode0_in},funct7_in,funct3_in,ALU_ctl);
	ALU B1 (ALU_ctl,ALU_input1,ALU_input2,ALUresult,zero);
	
	always@(posedge clk) begin
		Ctl_MemtoReg_out	<= Ctl_MemtoReg_in;
		Ctl_RegWrite_out	<= Ctl_RegWrite_in;
		Ctl_MemRead_out	    <= Ctl_MemRead_in; 
		Ctl_MemWrite_out	<= Ctl_MemWrite_in;
		Ctl_Branch_out		<= Ctl_Branch_in;
		PC_out              <= PC_in;
		jalr_out            <= jalr_in;
		jal_out             <= jal_in;
		bne_out             <= bne_in;
		
		Rd_out				<= Rd_in;
		PCimm_out			<= PC_in + (Immediate_in<<1);
		ReadData2_out		<=ReadData2_in;
		ALUresult_out		<= ALUresult;
		Zero_out			<=zero;
		
	end
endmodule
//////////////////////////////////////////////////////////////////////////////////
module ALU_control(
	input [1:0] ALUop,
	input [6:0] funct7,
	input [2:0] funct3,
	output reg [3:0] ALU_ctl
	);
	
	//ALU_ctl	:	OPERATION
	//4'b0000	:	and	==>ReadData1&ReadData2
	//4'b0001	:	or		==>ReadData1|ReadData2
	//4'b0010	:	add	==>ReadData1+ReadData2(Immediate_in)
	//4'b0110	:	sub	==>ReadData1-ReadData2
	//4'b0111 	:	blt (branch if less than)
	//4'b1000 	:	bge (branch if greater equal)     // blt,bge�� zero=1�� ����� ���ؼ� out=0���� ���� 
	//4'b1100 	:	nor	==> ~(ReadData1|ReadData2)
	//4'b1001 	:	shift left
	//4'b1010 	:	shift right
	
	  always @(*) begin
      casex ({ALUop,funct3,funct7})
         12'b00_xxx_xxxxxxx :   ALU_ctl   =   4'b0010;   // lb, lh, lw, sb, sh, sw    => ADDITION
         12'b01_00x_xxxxxxx :   ALU_ctl   =   4'b0110;     // beq, bne                => SUBTRACT (funct3==3'b000)   ||   (funct3==3'b001)
         12'b01_100_xxxxxxx :   ALU_ctl   =   4'b0111;   // blt                     => BLT(branch if less than) (funct3==3'b100)
         12'b01_101_xxxxxxx :   ALU_ctl   =   4'b1000;   // bge                     => BGE(branch if greater than) (funct3==3'b101)
         12'b10_000_0000000 :   ALU_ctl   =   4'b0010;   // add                     => ADDITION (funct3==3'b000 && funct7==7'b0000000)
         12'b10_000_0100000 :   ALU_ctl   =   4'b0110;   // sub                     => SUBTRACT (funct3==3'b000 && funct7==7'b0100000)
         12'b10_111_0000000 :   ALU_ctl   =   4'b0000;   // and                     => AND (funct3==3'b111 && funct7==7'b0000000)
         12'b10_110_0000000 :   ALU_ctl   =   4'b0001;   // or                        => OR (funct3==3'b110 && funct7==7'b0000000)
         12'b10_001_0000000 :   ALU_ctl   =   4'b1001;   // sll                     => SHIFT_LEFT (funct3==3'b001)
         12'b10_101_0000000 :   ALU_ctl   =   4'b1010;   // srl                     => SHIFT_RIGHT (funct3==3'b101)
         12'b11_000_xxxxxxx :   ALU_ctl   =   4'b0010;   // addi, jalr               => ADDITION (funct3==3'b000)
         12'b11_111_xxxxxxx :   ALU_ctl   =   4'b0000;   // andi                     => AND (funct3==3'b111)   
         12'b11_001_0000000 :   ALU_ctl   =   4'b1001;   // slli                     => SHIFT_LEFT (funct3==3'b001)
         12'b11_101_0000000 :   ALU_ctl   =   4'b1010;   // srli                     => SHIFT_RIGHT (funct3==3'b101)
         default : ALU_ctl = 4'bx;
      endcase
   end
									
endmodule

//////////////////////////////////////////////////////////////////////////////////
module ALU(
	input [3:0] ALU_ctl,
	input signed [31:0] in1, in2,
	output reg [31:0] out,
	output zero
	);
	
	always @(*) begin
		case (ALU_ctl)
			4'b0000 :	out = in1 & in2;				// and
			4'b0001 :   out = in1 | in2;				// or
			4'b0010 :   out = in1 + in2 ;				// add
			4'b0110 :   out = in1 - in2;				// sub
			4'b0111 :   out = (in1-in2 < 0)?0:1 ;	                 // blt (branch if less than)
			4'b1000 :   out = (in1-in2 >= 0)?0:1 ; 	            // bge (branch if greater equal) 
			// blt,bge�� zero=1�� ����� ���ؼ� out=0���� ���� 
			4'b1100 :   out = ~in1 | ~in2;			// nor
			4'b1001 :   out = in1 << in2[4:0];				// shift left
			4'b1010 :   out = in1 >> in2[4:0];				// shift right
			default :	out = 32'b0;
		endcase
	end
						
	assign zero = 	~|out;	//(ALU_ctl == 4'b0110) 			/ zero�� beq,bne Ȯ�� ����
									//(ALU_ctl == 4'b0111&1000) 	/blt,bge ==> mem stage���� zero�� branch signal�� branch ���� ������.
endmodule
