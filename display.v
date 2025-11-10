// =====================================================
// Module: display_hex
// =====================================================
module display_hex (buy_price, sell_price, spread_now, trade_count, 
    state, halt_signal, match_signal, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR);

    input [7:0] buy_price;      // Buy price in hexadecimal
    input [7:0] sell_price;     // Sell price in hexadecimal
    input [7:0] spread_now;     // Spread in hexadecimal
    input [7:0] trade_count;    // Trade count
    input [1:0] state;          // State (could be for machine or mode)
    input halt_signal;          // Halt signal
    input match_signal;         // Match signal

    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;  // 7-segment displays for showing values
    output [9:0] LEDR;             // LED indicators for status

    // BCD (Binary Coded Decimal) wires
    wire [3:0] buy_lo, buy_hi, sell_lo, sell_hi, spread_lo, spread_hi;
    wire [3:0] buy_dec1, buy_dec2, sell_dec1, sell_dec2, spread_dec1, spread_dec2;

    // Buy Price (low and high hex nibble)
    assign buy_lo = buy_price[3:0];
    assign buy_hi = buy_price[7:4];
    
    // Sell Price (low and high hex nibble)
    assign sell_lo = sell_price[3:0];
    assign sell_hi = sell_price[7:4];
    
    // Spread (low and high hex nibble)
    assign spread_lo = spread_now[3:0];
    assign spread_hi = spread_now[7:4];

    // Convert hexadecimal digits to decimal using hex2dec module
    hex2dec buy1_to_dec (.hex1(buy_lo), .hex2(buy_hi), .dec1(buy_dec1), .dec2(buy_dec2));
    hex2dec sell1_to_dec (.hex1(sell_lo), .hex2(sell_hi), .dec1(sell_dec1), .dec2(sell_dec2));
    hex2dec spread1_to_dec (.hex1(spread_lo), .hex2(spread_hi), .dec1(spread_dec1), .dec2(spread_dec2));

    // Display on HEX (after conversion to decimal)
    seg7 h0 (buy_dec1, HEX0);
    seg7 h1 (buy_dec2, HEX1);
    seg7 h2 (sell_dec1, HEX2);
    seg7 h3 (sell_dec2, HEX3);
    seg7 h4 (spread_dec1, HEX4);
    seg7 h5 (spread_dec2, HEX5);

    // LED Indicators
    assign LEDR[0] = match_signal;
    assign LEDR[1] = halt_signal;  
    assign LEDR[3:2] = state;
    assign LEDR[9:4] = trade_count[5:0];

endmodule

// =====================================================
// Module: hex2dec
// =====================================================

module hex2dec (hex1, hex2, dec1, dec2);
    input [3:0] hex1; 
    input [3:0] hex2;
    output [3:0] dec1;
    output [3:0] dec2;


    wire [7:0] hex_value;   // Combine the two hex digits to form a complete 8-bit value

    // Combine the two 4-bit hex digits into an 8-bit value
    wire c_out;
    assign dec1 = (hex1 <= 9) ? hex1 : (hex1 - 4'd10);
    assign c_out = (hex1 <= 9) ? 0 : 1'b1;
    assign dec2 = hex2 + c_out;
endmodule


// =====================================================
// Module: seg7 (7-segment display decoder)
// =====================================================
module seg7 (hex, seg);
    input [3:0] hex;          // 4-bit input representing a decimal digit
    output reg [6:0] seg;     // 7-segment output

    always @(*) 
    begin
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
            default: seg = 7'b1111111;  // Display nothing for invalid input
        endcase
    end
endmodule
