module cpu(clk,reset,in,out,N,V,Z,w,mem_addr,mem_cmd,halt);
  input clk, reset;
  input [15:0] in;
  
  output [15:0] out;
  output N, V, Z, w;
  output [8:0] mem_addr;
  output [1:0] mem_cmd;
  output halt;

  wire [15:0] current_instruction;
  wire [2:0] opcode;
  wire [1:0] ALUop;
  wire [1:0] nsel1, nsel2;
  wire [15:0] sximm8, sximm5;
  wire [1:0] shift;
  wire [2:0] readnum1, readnum2, writenum;
  wire write;
  wire loada, loadb, loadc, loads;
  wire [1:0] vsel;
  wire asel, bsel;
  wire [2:0] Z_out;
  wire [15:0] mdata;
  wire [8:0] PC;
  reg [8:0] next_pc;
  wire load_pc;
  wire load;
  wire load_addr;
  wire [8:0] address_out;
  wire [1:0] reset_pc;
  wire addr_sel;
  wire [15:0] data_out1, data_out2;
  wire [2:0] cond;
  wire loadab;
  wire strsel;
  wire [15:0] datapath_out;

  assign N = Z_out[1];
  assign Z = Z_out[0];
  assign V = Z_out[2];

  assign out = strsel ? data_out1 : datapath_out;

  register #(9) pc(
    .clk(clk),
    .data_in(next_pc),
    .data_out(PC),
    .write_enable(load_pc));

  register #(9) data_address(
    .clk(clk),
    .data_in(datapath_out[8:0]),
    .data_out(address_out),
    .write_enable(load_addr));

  register #(16) INSTRUCTION(
    .clk(clk),
    .data_in(in),
    .data_out(current_instruction),
    .write_enable(load));

  instruction_decoder DECODER(
    .decoder_in(current_instruction),
    .nsel1(nsel1),
    .nsel2(nsel2),
    .opcode(opcode),
    .ALUop(ALUop),
    .readnum1(readnum1),
    .readnum2(readnum2),
    .writenum(writenum),
    .shift(shift),
    .sximm8(sximm8),
    .sximm5(sximm5),
    .cond(cond));

  datapath DP(
    .clk(clk),
    .readnum1(readnum1),
    .readnum2(readnum2),
    .vsel(vsel),
    .shift(shift),
    .asel(asel),
    .bsel(bsel),
    .ALUop(ALUop),
    .loadc(loadc),
    .loads(loads),
    .writenum(writenum),
    .write(write),
    .Z_out(Z_out),
    .datapath_out(datapath_out),
    .mdata(in),
    .sximm8(sximm8),
    .sximm5(sximm5),
    .pc(PC),
    .data_out1(data_out1),
	.loadab(loadab));

  state FSM(
    .clk(clk),
    .reset(reset),
    .opcode(opcode),
    .ALUop(ALUop),
    .loadc(loadc),
    .loads(loads),
    .write(write),
    .asel(asel),
    .bsel(bsel),
    .vsel(vsel),
    .nsel1(nsel1),
    .nsel2(nsel2),
    .w(w),
    .load_ir(load),
    .load_addr(load_addr),
    .reset_pc(reset_pc),
    .addr_sel(addr_sel),
    .load_pc(load_pc),
    .mem_cmd(mem_cmd),
    .Z_in(Z_out),
    .cond(cond),
    .halt(halt),
	.loadab(loadab),
	.strsel(strsel));

  always_comb begin
      case(reset_pc)
        2'b00: next_pc = PC + 1;
        2'b01: next_pc = 9'd0;
        2'b10: next_pc = PC + sximm8[8:0];
        2'b11: next_pc = data_out1[8:0];
      endcase
  end

  assign mem_addr = addr_sel ? PC : address_out;
endmodule

module register(clk, data_in, data_out, write_enable);
  parameter n = 1;

  input clk;
  input write_enable;
  input [n-1:0] data_in;

  output reg [n-1:0] data_out;

  always_ff @(posedge clk) begin
    if (write_enable) begin
      data_out <= data_in;
    end
  end
endmodule
