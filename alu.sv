`define ADD 2'b00
`define SUB 2'b01
`define AND 2'b10
`define NOT 2'b11

module ALU(Ain,Bin,ALUop,out,Z);
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output reg [15:0] out;
    output reg [2:0] Z;

    always_comb begin
        case(ALUop)
			`ADD: begin
				out = Ain + Bin;
				Z[2] = ~(Ain[15] ^ Bin[15]) & (Ain[15] ^ out[15]);
			end
			`SUB: begin
				out = Ain - Bin;
				Z[2] = (Ain[15] ^ Bin[15]) & (Ain[15] ^ out[15]);
			end
			`AND: begin
				out = Ain & Bin;
				Z[2] = 1'b0;
			end
			`NOT: begin
				out = ~Bin;
				Z[2] = 1'b0;
			end
			default : begin
				out = 16'bxxxxxxxxxxxxxxxx;
				Z[2] = 1'b0;
			end
        endcase

		Z[0] = out == 16'd0;
		Z[1] = out[15];
    end
endmodule
