// =====================================================
// Module: Counter (fixed)
// =====================================================

module counter (
    input clk,
    input reset,
    input match_signal,
    input enable_count,
    output reg [7:0] trade_count,
    output reg halt_signal
);
    parameter MAX_TRADES = 8'd100;

    reg match_d;
    always @(posedge clk or posedge reset) begin
        if (reset)
            match_d <= 1'b0;
        else
            match_d <= match_signal;
    end
    wire match_edge = match_signal & ~match_d;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            trade_count <= 8'd0;
            halt_signal <= 1'b0;
        end else begin
            if (enable_count && match_edge && !halt_signal)
                trade_count <= trade_count + 8'd1;

            if (trade_count >= MAX_TRADES)
                halt_signal <= 1'b1;
        end
    end
endmodule
