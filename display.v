// Display_hex

module display_hex (buy_price, sell_price, spread_now, trade_count, state, halt_signal, match_signal, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR);

    input [7:0] buy_price;
    input [7:0] sell_price;
    input [7:0] spread_now;
    input [7:0] trade_count;
    input [1:0] state;
    input halt_signal;
    input match_signal;

    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    output [9:0] LEDR;

    wire [3:0] buy_lo, buy_hi, sell_lo, sell_hi, spread_lo, spread_hi;
    wire [3:0] buy_dec1, buy_dec2, sell_dec1, sell_dec2, spread_dec1, spread_dec2;

    assign buy_lo = buy_price[3:0];
    assign buy_hi = buy_price[7:4];
    assign sell_lo = sell_price[3:0];
    assign sell_hi = sell_price[7:4];
    assign spread_lo = spread_now[3:0];
    assign spread_hi = spread_now[7:4];

    hex2dec buy1_to_dec (.hex1(buy_lo), .hex2(buy_hi), .dec1(buy_dec1), .dec2(buy_dec2));
    hex2dec sell1_to_dec (.hex1(sell_lo), .hex2(sell_hi), .dec1(sell_dec1), .dec2(sell_dec2));
    hex2dec spread1_to_dec (.hex1(spread_lo), .hex2(spread_hi), .dec1(spread_dec1), .dec2(spread_dec2));

    seg7 h0 (buy_dec1, HEX0);
    seg7 h1 (buy_dec2, HEX1);
    seg7 h2 (sell_dec1, HEX2);
    seg7 h3 (sell_dec2, HEX3);
    seg7 h4 (spread_dec1, HEX4);
    seg7 h5 (spread_dec2, HEX5);

    assign LEDR[0] = match_signal;
    assign LEDR[1] = halt_signal;
    assign LEDR[3:2] = state;
    assign LEDR[9:4] = trade_count[5:0];

endmodule


module hex2dec (hex1, hex2, dec1, dec2);

    input  [3:0] hex1;
    input  [3:0] hex2;
    output [3:0] dec1;
    output [3:0] dec2;

    wire [7:0] bin_value = {hex2, hex1};

    assign dec2 = bin_value / 10;
    assign dec1 = bin_value % 10;

endmodule


module seg7 (hex, seg);

    input [3:0] hex;
    output reg [6:0] seg;

    always @(*) begin
        case (hex)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end

endmodule
