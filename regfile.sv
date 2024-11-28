module regfile(
		data_in,
		writenum,
		write,
		readnum1,
		readnum2,
		clk,
		data_out1,
		data_out2);

	input [15:0] data_in;
	input [2:0] writenum, readnum1, readnum2;
	input write;
	input clk;
 
	output reg [15:0] data_out1, data_out2;

	reg [15:0] R0, R1, R2, R3, R4, R5, R6, R7;

	always_ff @(posedge clk) begin
		if (write) begin
			case(writenum)
				3'd0: R0 <= data_in;
				3'd1: R1 <= data_in;
				3'd2: R2 <= data_in;
				3'd3: R3 <= data_in;
				3'd4: R4 <= data_in;
				3'd5: R5 <= data_in;
				3'd6: R6 <= data_in;
				3'd7: R7 <= data_in;
			endcase
		end
	end

	always_comb begin
		case(readnum1)
			3'd0: data_out1 = R0;
			3'd1: data_out1 = R1;
			3'd2: data_out1 = R2;
			3'd3: data_out1 = R3;
			3'd4: data_out1 = R4;
			3'd5: data_out1 = R5;
			3'd6: data_out1 = R6;
			3'd7: data_out1 = R7;
			default: data_out1 = 16'dx;
		endcase
	end

	always_comb begin
		case(readnum2)
			3'd0: data_out2 = R0;
			3'd1: data_out2 = R1;
			3'd2: data_out2 = R2;
			3'd3: data_out2 = R3;
			3'd4: data_out2 = R4;
			3'd5: data_out2 = R5;
			3'd6: data_out2 = R6;
			3'd7: data_out2 = R7;
			default: data_out2 = 16'dx;
		endcase
	end
endmodule
