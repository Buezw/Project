// =====================================================
// Module: Spread Calculator
// =====================================================

module spread_calculator (clk, reset, match_flag, enable_count, buy_price, sell_price, spread);

    input clk;               // system clock
    input reset;             // async reset
    input match_flag;        // from Matching Engine
    input enable_count;      // from FSM Controller
    input [7:0] buy_price;   // from Order Generator
    input [7:0] sell_price;  // from Order Generator
    
    output [7:0] spread;     // current spread output
    reg [7:0] spread;        // register for display stability

    // -------------------------------------------------
    // Sequential logic: update spread when match happens
    // -------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset)
            spread <= 8'd0;
        else if (enable_count && match_flag)
            spread <= buy_price - sell_price;  // current spread
    end

endmodule
