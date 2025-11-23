// Module: Spread Calculator


module spread (clk, reset, match_signal, enable_count, buy_price, sell_price, spread_now);

    input clk;              
    input reset;            
    input match_signal;        
    input enable_count;
    input [7:0] buy_price;
    input [7:0] sell_price; 
    
    output [7:0] spread_now;    
    reg [7:0] spread;

    wire [7:0] calculated_spread;

    assign calculated_spread = (sell_price == 8'hFF || buy_price == 8'd0) ? 8'd0 :
                               (buy_price >= sell_price) ? (buy_price - sell_price) :
                               (sell_price - buy_price);

    // 2. 时序逻辑：仅在发生撮合（成交）时更新 spread 寄存器
    always @(posedge clk or posedge reset) begin
        if (reset)
            spread <= 8'd0;
        // 只有当 enable_count AND match_signal 均为高时才更新
        else if (enable_count & match_signal) begin 
            spread <= calculated_spread;
        end
        // 否则，保持上一个值不变（这是关键的“捕获”逻辑）
    end
	 
	 assign spread_now = spread;

endmodule

