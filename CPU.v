module processor( input         clk, reset,
                  output [31:0] PC,
                  input  [31:0] instruction,
                  output        WE,
                  output [31:0] address_to_mem,
                  output [31:0] data_to_mem,
                  input  [31:0] data_from_mem
                );
    //... write your code here ...
	

	wire reg_write, alu_src_a, alu_src_b, mem_to_reg, branch_beq, branch_jal, branch_jalr, zero;
	wire [2:0] alu_control, imm_control;
	wire [31:0]	rs1, rs2, imm_out, mux0_out, mux1_out, mux2_out, mux3_out, alu0_out, alu1_out, alu2_out, mux_2_0_out, mux_2_1_out;
	wire xxx; 
	wire [1:0] mux_2_1_control;
	
	
	reg [31:0] my_PC;
	
			controller ctr(	instruction[6:0], 
						instruction[14:12],
						instruction[31:25],
						reg_write,
						alu_control,
						WE,
						imm_control,
						alu_src_a,
						alu_src_b,
						mem_to_reg,
						branch_beq,
						branch_jal,
						branch_jalr,
						mux_2_1_control);
	
		gpr_set gpr(	instruction[19:15],
						instruction[24:20],
						instruction[11:7],
						reg_write,
						mux1_out,
						clk,
						rs1, 
						rs2,
						reset);
		
		imm_decoder imm(instruction[31:7],
						imm_control,
						imm_out);
		
		mux mux0(mux_2_1_out, alu2_out, branch_jal | branch_jalr, mux0_out);
		mux mux1(mux0_out, data_from_mem, mem_to_reg, mux1_out);
		mux mux2(rs1, my_PC, alu_src_a, mux2_out);
		mux mux3(rs2, imm_out, alu_src_b, mux3_out);
		
		alu alu0(	mux2_out,
					mux3_out,
					alu_control,
					alu0_out,
					zero);
		
		alu alu1(	imm_out,
					my_PC,
					3'b000,
					alu1_out,
					xxx);
					
		alu alu2(	{{29{1'b0}},3'b100},
					my_PC,
					3'b000,
					alu2_out,
					xxx);
					
					
		mux2 mux_2_0(	alu2_out,
						alu0_out,
						alu1_out,
						my_PC,
						{(zero & branch_beq) | branch_jal, branch_jalr},
						mux_2_0_out);
						
		mux2 mux_2_1(	alu0_out,
						imm_out,
						alu1_out,
						{32{1'b0}},
						mux_2_1_control,
						mux_2_1_out);				
	
	
	always @(posedge clk)
	begin
		if (reset)
		begin
			//my_PC <= {{32{1'b0}}};
			//mux_2_0_out <= {{32{1'b0}}};
			my_PC <= 0;
		end
		else
		begin
			my_PC <= mux_2_0_out;
		end
	end
	
	assign PC = my_PC;
	assign address_to_mem = mux_2_1_out;
	assign data_to_mem = rs2;
	


endmodule



module alu(	input	signed	[31:0]	src_a,
			input	signed	[31:0]	src_b,
			input			[2:0]	alu_control,
			output	reg		[31:0]	alu_out,
			output	reg				zero); 
	
	always @(*)
	begin
		case (alu_control)
			3'b000: // +
				alu_out <= src_a + src_b;
			3'b001: // &
				alu_out <= src_a & src_b;
			3'b010: // -
				alu_out <= src_a - src_b;
			3'b011: // <
				alu_out <= src_a < src_b;
			3'b100: // +qb
				alu_out <= {src_a[31:24] + src_b[31:24], src_a[23:16] + src_b[23:16], src_a[15:8] + src_b[15:8], src_a[7:0] + src_b[7:0]};
			3'b101: // <<
				alu_out <= src_a << src_b;
			3'b110: // >>
				alu_out <= src_a >> src_b;
			3'b111: // >>> 
				alu_out <= src_a >>> src_b;
		endcase
		zero <= alu_out == {32{1'b0}} ? 1 : 0;
	end
endmodule

module mux(	input		[31:0]	in1,
			input		[31:0]	in2,
			input				control,
			output	reg	[31:0]	out);
	
	always @(*)
		if (control)
			out <= in2;
		else
			out <= in1;
endmodule

module mux2(input		[31:0]	in1,
			input		[31:0]	in2,
			input		[31:0]	in3,
			input		[31:0]	in4,
			input		[1:0]	control,
			output	reg	[31:0]	out);
	
	always @(*)
		case (control)
			0: out <= in1;
			1: out <= in2;
			2: out <= in3;
			3: out <= in4;
			default: out <= in1;
		endcase
endmodule



module gpr_set(	input		[4:0]	a1,
				input		[4:0]	a2,
				input		[4:0]	a3,
				input				we3,
				input		[31:0]	wd3,
				input				clk,
				output		[31:0]	rd1,
				output		[31:0]	rd2,
				input				reset);
	
	reg[31:0] regs [31:0];

	always @(posedge clk)
	begin
		if (reset)
		begin
			regs[0] <= {32{1'b0}};
			regs[1] <= {32{1'b0}};
			regs[2] <= {32{1'b0}};
			regs[3] <= {32{1'b0}};
			regs[4] <= {32{1'b0}};
			regs[5] <= {32{1'b0}};
			regs[6] <= {32{1'b0}};
			regs[7] <= {32{1'b0}};
			regs[8] <= {32{1'b0}};
			regs[9] <= {32{1'b0}};
			regs[10] <= {32{1'b0}};
			regs[11] <= {32{1'b0}};
			regs[12] <= {32{1'b0}};
			regs[13] <= {32{1'b0}};
			regs[14] <= {32{1'b0}};
			regs[15] <= {32{1'b0}};
			regs[16] <= {32{1'b0}};
			regs[17] <= {32{1'b0}};
			regs[18] <= {32{1'b0}};
			regs[19] <= {32{1'b0}};
			regs[20] <= {32{1'b0}};
			regs[21] <= {32{1'b0}};
			regs[22] <= {32{1'b0}};
			regs[23] <= {32{1'b0}};
			regs[24] <= {32{1'b0}};
			regs[25] <= {32{1'b0}};
			regs[26] <= {32{1'b0}};
			regs[27] <= {32{1'b0}};
			regs[28] <= {32{1'b0}};
			regs[29] <= {32{1'b0}};
			regs[30] <= {32{1'b0}};
			regs[31] <= {32{1'b0}};
		end
		else
		begin
			//$display ("a1: read from %d data %x", a1, regs[a1]);
			//$display ("a2: read from %d data %x", a2, regs[a2]);
			//$display ("write to %d data %x | instead of %x | yes = %d", a3, wd3, regs[a3], we3);
			if (a3 != 5'b00000)
			begin
				if (we3)
				begin
					regs[a3] <= wd3;
				end
			end
			

		end
	end

	assign rd1 = regs[a1];
	assign rd2 = regs[a2];

endmodule

module imm_decoder(	input		[24:0]	imm_in,
					input		[2:0]	imm_control,
					output	reg	[31:0]	imm_out);

	always @(*)
		case (imm_control)
			3'b000: // I-type - inst[31](21) inst[30:25](6) inst[24:21](4) inst[20](1)
				imm_out <= {{21{imm_in[24]}}, imm_in[23:18], imm_in[17:14], imm_in[13]};
			3'b001: // S-type - inst[31](21) inst[30:25](6) inst[11:8](4) inst[7](1)
				imm_out <= {{21{imm_in[24]}}, imm_in[23:18], imm_in[4:1], imm_in[0]};
			3'b010: // R-type - 0(32)
				imm_out <= {32{1'b0}};
			3'b011: // B-type - inst[31](20) inst[7](1) inst[30:25](6) inst[11:8](4) 0(1)
				imm_out <= {{20{imm_in[24]}}, imm_in[0], imm_in[23:18], imm_in[4:1], 1'b0};
			3'b100: // J-type - inst[31](12) inst[19:12](8) inst[20](1) inst[30:25](6) inst[24:21](4) 0(1)
				imm_out <= {{12{imm_in[24]}}, imm_in[12:5], imm_in[13], imm_in[23:18], imm_in[17:14], 1'b0};
			3'b101: // U-type - inst[31](1) inst[30:20](11) inst[19:12](8) 0(12)
				imm_out <= {imm_in[24], imm_in[23:13], imm_in[12:5], {12{1'b0}}};
			default:
				imm_out <= {32{1'b0}};
		endcase
endmodule

module controller(	input 		[6:0] 	opcode, 
					input		[2:0]	funct3,
					input		[6:0]	funct7,
					output reg			reg_write,
					output reg	[2:0]	alu_control,
					output reg			mem_write,
					output reg	[2:0]	imm_control,
					output reg			alu_src_a,
					output reg			alu_src_b,
					output reg			mem_to_reg,
					output reg			branch_beq,
					output reg			branch_jal,
					output reg			branch_jalr,
					output reg	[1:0]	mux_2_1_control);
					
	always @(*)
		case (opcode)
			7'b0110011:	// add, and, sub, slt, sll, srl, sra
			begin
				case (funct7)
					7'b0000000: // add, and, slt, sll, srl
					begin
						case (funct3)
							3'b000: // add
								alu_control <= 000;
							3'b111: // and
								alu_control <= 001;
							3'b010: // slt
								alu_control <= 011;
							3'b001: // sll
								alu_control <= 101;
							3'b101: // srl
								alu_control <= 110;
							default: // default
								alu_control <= 000;
						endcase
					end
					7'b0100000: // sub, sra
					begin
						case (funct3)
							3'b000: // sub
								alu_control <= 010;
							3'b101: // sra
								alu_control <= 111;
							default: // default
								alu_control <= 010;
						endcase
					end
					default: // default
						alu_control <= 000;
				endcase
				{reg_write, mem_write, imm_control, alu_src_a, alu_src_b, mem_to_reg, branch_beq, branch_jal, branch_jalr, mux_2_1_control} <= {1'b1, 1'b0, 3'b000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00};
			end
			7'b0010011: // addi
				{reg_write, alu_control, mem_write, imm_control, alu_src_a, alu_src_b, mem_to_reg, branch_beq, branch_jal, branch_jalr, mux_2_1_control} <= {1'b1, 3'b000, 1'b0, 3'b000, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00};
			7'b0001011: // addu.qb
				{reg_write, alu_control, mem_write, imm_control, alu_src_a, alu_src_b, mem_to_reg, branch_beq, branch_jal, branch_jalr, mux_2_1_control} <= {1'b1, 3'b100, 1'b0, 3'b010, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00};
			7'b0000011: // lw
				{reg_write, alu_control, mem_write, imm_control, alu_src_a, alu_src_b, mem_to_reg, branch_beq, branch_jal, branch_jalr, mux_2_1_control} <= {1'b1, 3'b000, 1'b0, 3'b000, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00};
			7'b0100011: // sw
				{reg_write, alu_control, mem_write, imm_control, alu_src_a, alu_src_b, mem_to_reg, branch_beq, branch_jal, branch_jalr, mux_2_1_control} <= {1'b0, 3'b000, 1'b1, 3'b001, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00};
			7'b1100011: // beq
				{reg_write, alu_control, mem_write, imm_control, alu_src_a, alu_src_b, mem_to_reg, branch_beq, branch_jal, branch_jalr, mux_2_1_control} <= {1'b0, 3'b010, 1'b0, 3'b011, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00};
			7'b1101111: // jal
				{reg_write, alu_control, mem_write, imm_control, alu_src_a, alu_src_b, mem_to_reg, branch_beq, branch_jal, branch_jalr, mux_2_1_control} <= {1'b1, 3'b000, 1'b0, 3'b100, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 2'b00};
			7'b1100111: // jalr
				{reg_write, alu_control, mem_write, imm_control, alu_src_a, alu_src_b, mem_to_reg, branch_beq, branch_jal, branch_jalr, mux_2_1_control} <= {1'b1, 3'b000, 1'b0, 3'b000, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00};
			7'b0010111: // auipc
				{reg_write, alu_control, mem_write, imm_control, alu_src_a, alu_src_b, mem_to_reg, branch_beq, branch_jal, branch_jalr, mux_2_1_control} <= {1'b1, 3'b000, 1'b0, 3'b101, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'b10};
			7'b0110111: // lui
				{reg_write, alu_control, mem_write, imm_control, alu_src_a, alu_src_b, mem_to_reg, branch_beq, branch_jal, branch_jalr, mux_2_1_control} <= {1'b1, 3'b000, 1'b0, 3'b101, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'b01};
			default: // default
				{reg_write, alu_control, mem_write, imm_control, alu_src_a, alu_src_b, mem_to_reg, branch_beq, branch_jal, branch_jalr, mux_2_1_control} <= {1'b0, 3'b000, 1'b0, 3'b000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 2'b00};
		endcase			
endmodule