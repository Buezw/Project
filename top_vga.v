// =====================================================
// Module: Top VGA (old Verilog style)
// Function: Connect trading logic to VGA modules
// =====================================================

module top_vga(clk, reset, HS, VS, R, G, B);

    input clk;        // use 25MHz or divide 50MHz clock
    input reset;
    output HS;
    output VS;
    output [3:0] R;
    output [3:0] G;
    output [3:0] B;

    // internal wires
    wire [7:0] buy_price;
    wire [7:0] sell_price;
    wire match_siganl;
    wire [7:0] spread_now;
    wire [7:0] trade_count;
    wire halt_signal;

    wire video_on;
    wire [9:0] h_cnt;
    wire [9:0] v_cnt;

    // =====================================================
    // connect your existing logic modules
    // =====================================================
    order_generator u_gen(
        .clk(clk),
        .reset(reset),
        .buy_price(buy_price),
        .sell_price(sell_price)
    );

    matching_engine u_match(
        .buy_price(buy_price),
        .sell_price(sell_price),
        .match_siganl(match_siganl),
        .spread(spread_now)
    );

    counter u_count(
        .clk(clk),
        .reset(reset),
        .match_siganl(match_siganl),
        .enable_count(1'b1),
        .trade_count(trade_count),
        .halt_signal(halt_signal)
    );

    // =====================================================
    // VGA modules
    // =====================================================
    vga_controller u_vga_ctrl(
        .clk_25mhz(clk),
        .reset(reset),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .hsync(HS),
        .vsync(VS),
        .video_on(video_on)
    );

    vga_display u_vga_disp(
        .clk_25mhz(clk),
        .video_on(video_on),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .buy_price(buy_price),
        .sell_price(sell_price),
        .trade_count(trade_count),
        .spread(spread_now),
        .halt_signal(halt_signal),
        .R(R),
        .G(G),
        .B(B)
    );

endmodule
