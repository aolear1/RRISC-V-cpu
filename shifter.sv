module shifter(in,shift,sout);
    input [15:0] in;
    input [1:0] shift;
    output reg [15:0] sout;

    always_comb begin
        case(shift)
            2'b00 : sout = in;
            2'b01 : begin
                        sout[15:1] = in[14:0];
                        sout[0] = 1'b0;
                    end
            2'b10 : begin
                        sout[14:0] = in[15:1];
                        sout[15] = 1'b0;
                    end
            2'b11 : begin
                        sout[14:0] = in[15:1];
                        sout[15] = in[15];
                    end
            default : sout = 16'bxxxxxxxxxxxxxxxx;
        endcase
    end

endmodule //shifter
