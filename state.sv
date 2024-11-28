`define Swait          4'd00
`define Sloadc         4'd03
`define Sloadreg       4'd04
`define SupdatePc      4'd05
`define SloadData      4'd06
`define SupdateIr      4'd07
`define SloadDataAddr  4'd08
`define SupdateDataLdr 4'd09
`define Spassthrough   4'd10
`define Sreset         4'd11
`define SloadPcImm     4'd12
`define Sreturn        4'd13

`define OPmovi   5'b11010
`define OPmovr   5'b11000
`define OPmvn    5'b10111
`define OPadd    5'b10100
`define OPcmp    5'b10101
`define OPand    5'b10110
`define OPldr    5'b01100
`define OPstr    5'b10000
`define OPbl     5'b01011
`define OPbx     5'b01000
`define OPblx    5'b01010
`define OPhalt   3'b111

`define MNONE  2'b00
`define MREAD  2'b01
`define MWRITE 2'b10

module state(
    clk,
    reset,
    opcode,
    ALUop,
    loadc,
    loads,
	loadab,
    write,
    asel,
    bsel,
    vsel,
    nsel1,
    nsel2,
    w,
    addr_sel,
    load_addr,
    reset_pc,
    load_pc,
    mem_cmd,
    load_ir,
    Z_in,
    cond,
    halt,
	strsel);

  output reg loadc;
  output reg loads;
  output reg loadab;
  output reg write;
  output reg asel;
  output reg bsel;
  output reg [1:0] vsel;
  output reg [1:0] nsel1, nsel2;
  output reg w;
  output reg addr_sel;
  output reg load_addr;
  output reg [1:0] reset_pc;
  output reg [1:0] mem_cmd;
  output reg load_pc;
  output reg load_ir;
  output reg halt;

  input clk;
  input reset;

  output reg strsel;

  input [2:0] opcode;
  input [1:0] ALUop;
  input [2:0] Z_in;
  input [2:0] cond;

  reg [3:0] state;

  wire [3:0] present_state;
  assign present_state = state;

  always_ff @(posedge clk) begin
    if (reset) begin
      state <= `Sreset;
    end else begin
      case(state)
        `Sreset: begin
          state <= `SloadData;
        end

        `Swait: begin
          if (opcode !== `OPhalt) begin
            if ({opcode,ALUop} === `OPadd
              | {opcode,ALUop} === `OPand
              | {opcode,ALUop} === `OPcmp
              | {opcode,ALUop} === `OPldr
              | {opcode,ALUop} === `OPstr
			  | {opcode,ALUop} === `OPmovr
			  | {opcode,ALUop} === `OPmvn) begin

			  state <= `Sloadc;
            end else if (opcode === 3'b001) begin
              case(cond)
                3'b000: state <= `SloadPcImm;
                3'b001: state <= Z_in[0] ? `SloadPcImm : `SloadData;
                3'b010: state <= ~Z_in[0] ? `SloadPcImm : `SloadData;
                3'b011: state <= Z_in[1] ^ Z_in[2] ? `SloadPcImm : `SloadData;
                3'b100: state <= Z_in[0] | (Z_in[1] ^ Z_in[2]) ? `SloadPcImm : `SloadData;
                default: state <= 5'dx;
              endcase
            end else if (opcode === 3'b010) begin
              case(ALUop)
                2'b11: state <= `SloadPcImm;
                2'b00: state <= `SloadData;
                2'b10: state <= `Sreturn;
              endcase
            end else if ({opcode,ALUop} === `OPmovi) begin
              state<= `SupdateIr;
            end else begin
              state <= `Sloadreg;
            end
          end
        end

        `Sloadc: begin
          if ({opcode,ALUop} === `OPcmp) begin
            state <= `SupdateIr;
          end else if ({opcode,ALUop} === `OPldr
                     | {opcode,ALUop} === `OPstr) begin

            state <= `SloadDataAddr;
          end else begin
            state <= `Sloadreg;
          end 
        end

        `Spassthrough: begin
          state <= `SupdateDataLdr;
        end

        `Sloadreg: begin
          if ({opcode,ALUop} === `OPbl) begin
            state <= `SloadPcImm;
          end else if ({opcode,ALUop} === `OPblx) begin
            state <= `Sreturn;

          end else if ({opcode,ALUop} === `OPldr) begin
            state <= `SloadData;
          end else begin
            state <= `SupdateIr;
          end
        end
          
        `SloadData: begin
          state <= `SupdateIr;
        end

        `SupdateIr: begin
		  state <= `Swait;
        end

        `SloadDataAddr: begin
          state <=`SupdateDataLdr;
        end

        `SupdateDataLdr: begin
          if ({opcode,ALUop} === `OPstr) begin
            state <= `SloadData;
          end else begin
            state <= `Sloadreg;
          end
        end

        `SloadPcImm: begin
          state <= `SloadData;
        end

        `Sreturn: begin
          state <= `SloadData;
        end

        default: begin
          state <= 3'bxxx;
        end
      endcase
    end
  end

  always_comb begin
    loadc = 1'b0;
    loads = 1'b0;
    write = 1'b0;
    asel = 1'b0;
    bsel = 1'b0;
    vsel = 1'b0;
    nsel1 = 2'b0;
    nsel2 = 2'b0;
    w = 1'b0;
    load_pc = 1'b0;
    reset_pc = 2'b00;
    addr_sel = 1'b0;
    load_ir = 1'b0;
    mem_cmd = `MNONE;
    load_addr = 1'b0;
    halt = 1'b0;
	loadab = 1'b0;
	strsel = 1'b0;

    case(state)
      `Sreset: begin
        load_pc <= 1'b1;
        reset_pc <= 2'b01;
        addr_sel = 1'b1;
        mem_cmd = `MREAD;
      end

      `Swait: begin
        w = 1'b1;
        halt = opcode === `OPhalt;

        nsel2 = 2'd2;
        nsel1 = {opcode,ALUop} === `OPstr ? 2'd1 : 2'd0;
        loadab = 1'b1;

        if ({opcode,ALUop} === `OPmovi) begin
            vsel = 2'b01;
            nsel1 = 2'd2;
            addr_sel = 1'b1;
            mem_cmd = `MREAD;
            write = 1'b1;
        end else if ({opcode, ALUop} === `OPbl
                    || {opcode, ALUop} === `OPblx) begin
            write = 1'b1;
            vsel = 2'd2;
            nsel1 = 2'd2;
        end else if ({opcode, ALUop} === `OPbx) begin
            nsel1 = 3'd1;
            reset_pc = 2'd3;
            load_pc = 1'b1;
        end
      end

      `Sloadc: begin
        case({opcode,ALUop})
          `OPcmp: begin
            loads = 1'b1;
            addr_sel = 1'b1;
            mem_cmd = `MREAD;
          end

          `OPmovr: begin
            asel = 1'b1;
            loadc = 1'b1;
          end

          `OPadd: begin
            loadc = 1'b1;
          end

          `OPand: begin
            loadc = 1'b1;
          end

          `OPmvn: begin
            loadc = 1'b1;
          end

          `OPldr: begin
            loadc = 1'b1;
            bsel = 1'b1;
          end

          `OPstr: begin
            loadc = 1'b1;
            bsel = 1'b1;
          end

          default: begin
            loadc = 1'bx;
          end
        endcase
      end


      `Sloadreg: begin
        write = 1'b1;

        case({opcode,ALUop})
          `OPmovi: begin
            vsel = 2'b01;
            nsel1 = 2'd2;
            addr_sel = 1'b1;
            mem_cmd = `MREAD;
          end

          `OPmovr: begin
            vsel = 2'b11;
            nsel1 = 2'd1;
            addr_sel = 1'b1;
            mem_cmd = `MREAD;
          end

          `OPmvn: begin
            vsel = 2'b11;
            nsel1 = 2'd1;
            addr_sel = 1'b1;
            mem_cmd = `MREAD;
          end

          `OPand: begin
            vsel = 2'b11;
            nsel1 = 2'd1;
            addr_sel = 1'b1;
            mem_cmd = `MREAD;
          end

          `OPadd: begin
            vsel = 2'b11;
            nsel1 = 2'd1;
            addr_sel = 1'b1;
            mem_cmd = `MREAD;
          end

          `OPldr: begin
            vsel = 2'd0;
            nsel1 = 2'd1;
            addr_sel = 1'b0;
            mem_cmd = opcode === 3'b011 ? `MREAD : `MWRITE;
          end

          `OPbl: begin
            nsel1 = 2'd2;
            vsel = 2'd2;
          end

          `OPblx: begin
            nsel1 = 2'd2;
            vsel = 2'd2;
          end

          default: begin
            vsel = 2'bxx;
            nsel1 = 2'd1;
          end
        endcase
      end

      `SupdatePc: begin
        load_pc = 1'b1;
        addr_sel = 1'b1;
        mem_cmd = `MREAD;
      end

      `SloadData: begin
        addr_sel = 1'b1;
        mem_cmd = `MREAD;
      end

      `SupdateIr: begin
	  	load_pc = 1'b1;
        load_ir = 1'b1;
        addr_sel = 1'b1;
        mem_cmd = `MREAD;
      end

      `SloadDataAddr: begin
        load_addr = 1'b1;
        addr_sel = 1'b0;
        mem_cmd = `MREAD;
      end

      `SupdateDataLdr: begin
        addr_sel = 1'b0;
		nsel1 = 3'd1;
		strsel = opcode === 3'b100;
        mem_cmd = opcode === 3'b011 ? `MREAD : `MWRITE;
      end

      `Spassthrough: begin
        bsel = 1'b0;
        asel = 1'b1;
        loadc = 1'b1;
		nsel1 = 3'd1;
      end

      `SloadPcImm: begin
        reset_pc = 2'd2;
        load_pc = 1'b1;
      end

      `Sreturn: begin
        nsel1 = 3'd1;
        reset_pc = 2'd3;
        load_pc = 1'b1;
      end

      default: begin
        loadc = 1'bx;
        loads = 1'bx;
      end
    endcase
  end
endmodule
