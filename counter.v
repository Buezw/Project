// Module: Counter (old Verilog style)

module counter (clk, reset, match_signal, enable_count, trade_count, halt_signal);

    input clk;
    input reset;
    input match_signal;
    input enable_count;

    output [7:0] trade_count;
    output halt_signal;

    reg [7:0] trade_count;
    reg halt_signal;

    // Edge detector
    reg match_d;

    always @(posedge clk or posedge reset) begin
        if (reset)
            match_d <= 1'b0;
        else
            match_d <= match_signal;
    end

    wire match_edge;
    assign match_edge = match_signal & ~match_d;

    // Main counter logic
    parameter MAX_TRADES = 8'd100;

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
