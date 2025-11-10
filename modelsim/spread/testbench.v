`timescale 1ns / 1ps

module testbench ();

    // ==== 仿真参数 (simulation parameter) ====
    parameter CLOCK_PERIOD = 10; // 100MHz -> 10ns

    // ==== 与你示例一致的外设风格 (same style as your example) ====
    // KEY[0]=clk
    // SW[0]=reset(高有效, active-high)
    // SW[1]=enable_count
    // SW[2]=match_siganl   // 按工程里一致的拼写
    // SW[3]=halt_signal
    reg  [3:0] SW;
    reg  [0:0] KEY;

    // ==== 输入价格 (price inputs) ====
    reg  [7:0] buy_price;
    reg  [7:0] sell_price;

    // ==== 输出 (output) ====
    wire [7:0] spread_now;

    // ==== 初始时钟电平 (initial clock) ====
    initial KEY[0] <= 1'b0;

    // ==== 时钟发生器 (clock generator) ====
    always @(*) begin : Clock_Generator
        #((CLOCK_PERIOD)/2) KEY[0] <= ~KEY[0];
    end

    // ==== 例化被测模块 (instantiate UUT) ====
    // 若你的模块名或端口名不同（例如 spread_calc / reset_n），在这里改即可
    spread U1 (
        .clk          (KEY[0]),
        .reset        (SW[0]),
        .buy_price    (buy_price),
        .sell_price   (sell_price),
        .match_siganl (SW[2]),
        .enable_count (SW[1]),
        .halt_signal  (SW[3]),
        .spread_now   (spread_now)
    );

    // ==== 激励序列 (stimulus) ====
    // 目标：
    //  A) 未使能/未撮合/已停机 都不应更新 spread_now（保持不变/保持复位值）
    //  B) 仅在 enable=1 且 match=1 且 halt=0 时更新为 buy-sell
    //  C) 触发 halt 后即使 match=1 也不更新
    initial begin
        // 上电：复位，高电平
        SW <= 4'b0000;
        SW[0] <= 1'b1;            // reset=1
        buy_price  <= 8'd0;
        sell_price <= 8'd0;

        // 保持复位 5 个时钟
        repeat (5) @(posedge KEY[0]);
        SW[0] <= 1'b0;            // 释放复位

        // ------- 阶段A：未使能 -> 不更新 -------
        SW[1] <= 1'b0; SW[2] <= 1'b1; SW[3] <= 1'b0; // enable=0, match=1, halt=0
        send_price(8'd80, 8'd70, 3);   // 应不更新

        // ------- 阶段B：仅使能，无撮合 -> 不更新 -------
        SW[1] <= 1'b1; SW[2] <= 1'b0; SW[3] <= 1'b0; // enable=1, match=0
        send_price(8'd75, 8'd74, 3);   // 应不更新

        // ------- 阶段C：满足条件 (enable=1 & match=1 & !halt) -> 更新 -------
        SW[1] <= 1'b1; SW[2] <= 1'b1; SW[3] <= 1'b0; // 允许更新
        send_price(8'd82, 8'd78, 2);   // 期望 spread_now=4
        send_price(8'd70, 8'd65, 2);   // 期望 spread_now=5
        send_price(8'd60, 8'd72, 2);   // 若模块是有符号/无符号按实现观察结果

        // ------- 阶段D：停机 -> 不再更新 -------
        SW[3] <= 1'b1;                 // halt=1
        send_price(8'd90, 8'd10, 3);   // 应保持停机前的值

        // ------- 阶段E：解除停机但关掉撮合 -> 仍不更新 -------
        SW[3] <= 1'b0;                 // halt=0
        SW[2] <= 1'b0;                 // match=0
        send_price(8'd88, 8'd11, 3);   // 不更新

        // 再次满足条件 -> 再次更新
        SW[2] <= 1'b1;                 // match=1
        send_price(8'd81, 8'd55, 3);   // 应更新为 26

        // 结束
        repeat (10) @(posedge KEY[0]);
        $finish;
    end

    // ==== 打印观测 (monitor) ====
    initial begin
        $display(" time  rst en match halt | buy  sell | spread");
        forever begin
            @(posedge KEY[0]);
            $display("%5t  %b   %b   %b    %b  | %3d  %3d | %3d",
                     $time, SW[0], SW[1], SW[2], SW[3],
                     buy_price, sell_price, spread_now);
        end
    end

    // ==== 发送价格任务 (task) ====
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
