module datapath(
		clk,
		readnum1,
		readnum2,
		vsel,
		shift,
		asel,
		bsel,
		ALUop,
		loadc,
		loads,
		loadab,
		writenum,
		write,
		Z_out,
		datapath_out,
		mdata,
		sximm8,
		sximm5,
		pc,
		data_out1);

	input clk;
	input loadab;
	input [2:0] readnum1, readnum2, writenum;
	input [1:0] vsel;
	input loadc, loads;
	input [1:0] shift;
	input asel, bsel;
	input [1:0] ALUop;
	input write;
	input [15:0] mdata;
	input [15:0] sximm8;
	input [15:0] sximm5;
	input [8:0] pc;

	output reg [15:0] datapath_out;
	output reg [2:0] Z_out;
	output reg [15:0] data_out1;

	reg [15:0] data_out2;

	reg [15:0] data_in;
	wire [15:0] sout;
	reg [15:0] aout;
	wire [15:0] Ain, Bin;
	wire [2:0] Z;
	wire [15:0] out;
	wire [15:0] sin;

	regfile REGFILE(
		.data_in(data_in),
		.writenum(writenum),
		.write(write),
		.readnum1(readnum1),
		.readnum2(readnum2),
		.clk(clk),
		.data_out1(data_out1),
		.data_out2(data_out2)
	);

	register #(16) A(
		.clk(clk),
		.data_in(data_out2),
		.data_out(aout),
		.write_enable(loadab));

	register #(16) B(
		.clk(clk),
		.data_in(data_out1),
		.data_out(sin),
		.write_enable(loadab));

	shifter SHIFTER(
		.in(sin),
		.shift(shift),
		.sout(sout)
	);

	ALU alu(
		.Ain(Ain),
		.Bin(Bin),
		.ALUop(ALUop),
		.out(out),
		.Z(Z)
	);

	register #(16) C(
		.clk(clk),
		.data_in(out),
		.data_out(datapath_out),
		.write_enable(loadc)
	);

	register #(3) status(
		.clk(clk),
		.data_in(Z),
		.data_out(Z_out),
		.write_enable(loads)
	);

	always_comb begin
		case(vsel)
			2'b00: data_in = mdata;
			2'b01: data_in = sximm8;
			2'b10: data_in = {8'b0,pc[7:0]};
			2'b11: data_in = datapath_out;
			default: data_in = 16'bx;
		endcase
	end

	assign Ain = (asel) ? 16'd0 : aout;
	assign Bin = (bsel) ? sximm5 : sout;
endmodule
