`define MNONE  2'b00
`define MREAD  2'b01
`define MWRITE 2'b10

`define SW_ADDR  9'h140
`define LED_ADDR 9'h100

module lab7bonus_top(KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, CLOCK_50);
  input [3:0] KEY;
  input [9:0] SW;
  input CLOCK_50;
  
  output [9:0] LEDR;
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

  wire [1:0] mem_cmd;
  wire [8:0] mem_addr;
  wire [15:0] write_data;
  wire write;
  wire [15:0] din;
  wire [15:0] dout;
  reg [15:0] read_data;
  wire led_enable;

  wire Z, V, N;
  wire w;

  RAM #(16, 8, "data.txt") MEM(
    .clk(CLOCK_50),
    .read_address(mem_addr[7:0]),
    .write_address(mem_addr[7:0]),
    .write(write),
    .din(write_data),
    .dout(dout));

  cpu CPU(
    .clk(CLOCK_50),
    .reset(~KEY[1]),
    .in(read_data),
    .out(write_data),
    .Z(Z),
    .V(V),
    .N(N),
    .w(LEDR[9]),
    .mem_addr(mem_addr),
    .mem_cmd(mem_cmd),
    .halt(LEDR[8]));

  always_comb begin
    if ((mem_addr[8] === 1'b0) & (mem_cmd === `MREAD)) begin
      read_data = dout;
    end else if ((mem_addr === `SW_ADDR) & (mem_cmd === `MREAD)) begin
      read_data = {8'b0,SW[7:0]};
    end else begin
      read_data = 16'bz;
    end
  end

  register #(8) led_register(
    .clk(CLOCK_50),
    .data_in(write_data[7:0]),
    .data_out(LEDR[7:0]),
    .write_enable(led_enable));

  assign led_enable = (mem_addr === `LED_ADDR) & (mem_cmd === `MWRITE);
  assign write = (mem_addr[8] === 1'b0) & (mem_cmd === `MWRITE);
endmodule

module sseg(in, segs);
  input [3:0] in;
  output reg [6:0] segs;

  always_comb begin
    case(in)
      4'h0: segs = 7'b1000000;
      4'h1: segs = 7'b1111001;
      4'h2: segs = 7'b0100100;
      4'h3: segs = 7'b0110000;
      4'h4: segs = 7'b0011001;
      4'h5: segs = 7'b0010010;
      4'h6: segs = 7'b0000010;
      4'h7: segs = 7'b1111000;
      4'h8: segs = 7'b0000000;
      4'h9: segs = 7'b0011000;
      4'hA: segs = 7'b0001000;
      4'hB: segs = 7'b0000011;
      4'hC: segs = 7'b1000110;
      4'hD: segs = 7'b0100001;
      4'hE: segs = 7'b0000110;
      4'hF: segs = 7'b0001110;
      default: segs = 7'bxxxxxxx;
    endcase
  end
endmodule
