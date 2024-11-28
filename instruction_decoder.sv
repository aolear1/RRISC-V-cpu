module instruction_decoder(
		decoder_in,
		nsel1,
		opcode,
		ALUop,
		readnum1,
		readnum2,
		writenum,
		shift,
		sximm8,
		sximm5,
		cond,
		nsel2);

    input [15:0] decoder_in;
    input [1:0] nsel1, nsel2;

    output [1:0] ALUop, shift;
    output [15:0] sximm8, sximm5;
    output [2:0] cond;
    output reg [2:0] readnum1, readnum2, writenum, opcode;

    wire [2:0] Rn, Rd, Rm;
    wire [4:0] imm5;
    wire [7:0] imm8;
    reg [2:0] register;

    assign Rn = decoder_in[10:8];
    assign Rd = decoder_in[7:5];
    assign Rm = decoder_in[2:0];

    assign cond = decoder_in[10:8];

    always_comb begin
        case(nsel1)
            2'b00 : register = Rm;
            2'b01 : register = Rd;
            2'b10 : register = Rn;
            default: register = 2'bxx;
        endcase
    end

    always_comb begin
        case(nsel2)
            2'b00 : readnum2 = Rm;
            2'b01 : readnum2 = Rd;
            2'b10 : readnum2 = Rn;
            default: readnum2 = 2'bxx;
        endcase
    end

    assign readnum1 = register;
    assign writenum  = register;//= opcode === 3'b010 ? 3'd7 : register;

    assign opcode = decoder_in[15:13];
    assign ALUop = decoder_in[12:11];
    assign shift = decoder_in[15:13] === 3'b100 ? 2'b00 : decoder_in[4:3];
    assign imm8 = decoder_in[7:0];
    assign imm5 = decoder_in[4:0];

    sign_extend #(5) imm5_assign(
        .imm_in(imm5),
        .sximm_out(sximm5)
    );

    sign_extend #(8) imm8_assign(
        .imm_in(imm8),
        .sximm_out(sximm8)
    );
endmodule

module sign_extend(imm_in, sximm_out);
    parameter n = 1;

    input [n-1:0] imm_in;
    output [15:0] sximm_out;

    assign sximm_out = {{(16-n){imm_in[n-1]}}, imm_in};
endmodule

module sxtest();
    reg [7:0] imm_in;
    reg [15:0] imm_out;

    sign_extend #(8) DUT(imm_in, imm_out);

    initial begin
        imm_in = 8'd120;
        #10;
        $display("Expected 120, got %d.", imm_out);

        imm_in = 8'd130;
        #10;
        $display("Expected 65410, got %d.", imm_out);
    end
endmodule
