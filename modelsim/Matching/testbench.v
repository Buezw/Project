`timescale 1ns / 1ps

module testbench ();

    // ==== 仿真参数 (simulation parameter) ====
    parameter CLOCK_PERIOD = 10; // 100MHz -> 10ns

    // ==== 与你示例一致的外设风格 (same style as your example) ====
    // KEY[0] 作为时钟 (clock)
    // SW[0] 作为高有效复位 (active-high reset)
    reg  [0:0] KEY;
    reg  [0:0] SW;

    // ==== 输入到 matching_engine 的价格流 (input price streams) ====
    reg  [7:0] buy_price;   // 买价 (buy price)
    reg  [7:0] sell_price;  // 卖价 (sell price)

    // ==== 输出观测 (observed outputs) ====
    wire [7:0] best_bid;    // 最佳买 (best bid)
    wire [7:0] best_ask;    // 最佳卖 (best ask)
    wire       match_flag;  // 撮合标志 (match flag)
    wire [7:0] trade_price; // 成交价 (trade price)

    // ==== 初始时钟电平 (initial clock level) ====
    initial KEY[0] <= 1'b0;

    // ==== 时钟发生器 (clock generator, same style as your sample) ====
    always @(*) begin : Clock_Generator
        #((CLOCK_PERIOD)/2) KEY[0] <= ~KEY[0];
    end

    // ==== 例化被测模块 (instantiate UUT) ====
    // 如果你的端口名略有差别（例如 .buy_in/.sell_in 或模块名是 matching_engine_8），把下面对应名称改一下即可。
    matching_engine U1 (
        .clk         (KEY[0]),
        .reset       (SW[0]),
        .buy_price   (buy_price),
        .sell_price  (sell_price),
        .best_bid    (best_bid),
        .best_ask    (best_ask),
        .match_flag  (match_flag),
        .trade_price (trade_price)
    );

    // ==== 激励序列 (stimulus) ====
    // 思路：先给一段不成交序列（buy<sell），填满窗口；再给几段 buy>=sell 触发撮合，并改变极值以验证 best_bid/best_ask 的更新。
    initial begin
        // 上电先复位
        SW[0]      <= 1'b1;
        buy_price  <= 8'd0;
        sell_price <= 8'd0;

        // 保持复位 5 个时钟
        repeat (5) @(posedge KEY[0]);
        SW[0] <= 1'b0;

        // -------- 阶段A：填充窗口且不成交（buy<sell）--------
        // 8 个样本：best_bid 应逐步上升、best_ask 逐步下降，但始终 buy<sell，match_flag=0
        send_price(8'd60, 8'd90, 1);
        send_price(8'd62, 8'd88, 1);
        send_price(8'd64, 8'd86, 1);
        send_price(8'd66, 8'd84, 1);
        send_price(8'd68, 8'd82, 1);
        send_price(8'd70, 8'd80, 1);
        send_price(8'd72, 8'd78, 1);
        send_price(8'd74, 8'd76, 2); // 额外多跑 1 拍稳定窗口

        // -------- 阶段B：制造成交（buy>=sell）--------
        // 让 buy≥sell，期望 match_flag=1，trade_price 为中点（mid，具体以你的实现为准）
        send_price(8'd80, 8'd78, 4); // 明显成交
        send_price(8'd82, 8'd75, 4); // 再次成交

        // -------- 阶段C：改变极值以测试 best_* 的滑窗更新 --------
        // 卖价极小，拉低 best_ask；买价极大，抬高 best_bid
        send_price(8'd85, 8'd60, 4);
        send_price(8'd55, 8'd85, 4); // 再给不成交，验证极值随时间滑出窗口后回落

        // 再跑一会儿观察
        repeat (20) @(posedge KEY[0]);
        $finish;
    end

    // ==== 打印观测 (monitor) ====
    initial begin
        $display(" time  rst   buy  sell | best_bid best_ask | match trade");
        forever begin
            @(posedge KEY[0]);
            $display("%5t  %b   %3d  %3d |   %3d      %3d  |   %b     %3d",
                     $time, SW[0], buy_price, sell_price,
                     best_bid, best_ask, match_flag, trade_price);
        end
    end

    // ==== 发送价格的任务 (task to send prices N cycles) ====
    task send_price(input [7:0] b, input [7:0] s, input integer n_cycles);
        integer i;
        begin
            buy_price  <= b;
            sell_price <= s;
            for (i = 0; i < n_cycles; i = i + 1) begin
                @(posedge KEY[0]);
            end
        end
    endtask

endmodule
