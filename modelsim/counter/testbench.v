`timescale 1ns / 1ps

module testbench ();

    // ==== 仿真参数 (simulation parameter) ====
    parameter CLOCK_PERIOD = 10; // 100MHz -> 10ns

    // ==== 与你示例一致的外设风格 (same style as your example) ====
    reg  [2:0] SW;   // SW[0]=reset(高有效, active-high), SW[1]=enable_count, SW[2]=match_siganl
    reg  [0:0] KEY;  // KEY[0]=clk (clock)

    // ==== 被测模块输出 (UUT outputs) ====
    wire [7:0] trade_count; // 成交计数 (trade count)
    wire       halt_signal; // 停机信号 (halt)

    // ==== 初始时钟电平 (initial clock level) ====
    initial begin
        KEY[0] <= 1'b0;
    end

    // ==== 时钟发生器 (clock generator) ====
    always @(*) begin : Clock_Generator
        #((CLOCK_PERIOD)/2) KEY[0] <= ~KEY[0];
    end

    // ==== 激励序列 (stimulus) ====
    initial begin
        // 上电：先复位、关闭计数与撮合 (assert reset, disable counting/matching)
        SW[0] <= 1'b1; // reset
        SW[1] <= 1'b0; // enable_count
        SW[2] <= 1'b0; // match_siganl (保持低)

        // 释放复位 (deassert reset)
        #30 SW[0] <= 1'b0;

        // 允许计数 (enable counting)
        #30 SW[1] <= 1'b1;

        // 开始持续“撮合”为高电平 (set match_siganl high so it counts every clk)
        #30 SW[2] <= 1'b1;

        // 运行一段时间，足够达到 MAX_TRADES=100 并触发 halt_signal
        #3000;

        // 关掉撮合再开，观察停机后是否还能计数（应当不能）
        SW[2] <= 1'b0;
        #100;
        SW[2] <= 1'b1;

        // 再跑一会儿结束仿真
        #1000 $finish;
    end

    // ==== 例化被测模块 (instantiate UUT) ====
    // counter 的端口: (clk, reset, match_siganl, enable_count, trade_count, halt_signal)
    counter U1 (
        .clk          (KEY[0]),
        .reset        (SW[0]),
        .match_siganl (SW[2]),   // 注意：按照你文件里的拼写 match_siganl
        .enable_count (SW[1]),
        .trade_count  (trade_count),
        .halt_signal  (halt_signal)
    );

    // ==== 打印观测 (monitor) ====
    initial begin
        $display(" time  rst en match  count halt");
        $monitor("%5t  %b   %b   %b    %3d   %b",
                 $time, SW[0], SW[1], SW[2], trade_count, halt_signal);
    end

endmodule
