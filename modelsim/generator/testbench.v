`timescale 1ns/1ps

module testbench;

  // ===== 仿真参数 (simulation parameters) =====
  parameter CLOCK_PERIOD = 10;  // 100 MHz -> 10ns

  // ===== 驱动信号 (stimulus) =====
  reg clk;
  reg reset;    // 高有效复位 (active-high reset)

  // ===== 观测信号 (observed signals) =====
  wire [7:0] buy_price;
  wire [7:0] sell_price;

  // ===== 被测模块 (UUT: Unit Under Test) =====
  order_generator U1 (
    .clk        (clk),
    .reset      (reset),
    .buy_price  (buy_price),
    .sell_price (sell_price)
  );

  // ===== 时钟产生器 (clock generator) =====
  initial clk = 1'b0;
  always #(CLOCK_PERIOD/2) clk = ~clk;

  // ===== 复位与激励序列 (reset & stimulus) =====
  initial begin
    reset = 1'b1;                    // 上电先复位 (assert reset)
    repeat (5) @(posedge clk);
    reset = 1'b0;                    // 释放复位 (deassert reset)

    // 继续运行一段时间后结束仿真
    repeat (5000) @(posedge clk);    // 可按需增减
    $finish;
  end

  // =====（可选）快速仿真开关 FAST_SIM =====
  // 你的 order_generator 里有一个 21 位分频计数器 div，
  // 若想加速 LFSR 更新频率，可在编译时加宏：+define+FAST_SIM
`ifdef FAST_SIM
  // 思路：在每个负边沿把 div 设为全 1，使下一个正边沿溢出到 0，
  // 触发一次“慢时钟”事件，从而几乎每拍更新价格。
  initial begin
    // 等待离开复位再加速，避免干扰复位过程
    @(negedge reset);
    forever begin
      @(negedge clk);
      force U1.div = {21{1'b1}};
      #1 release U1.div;
    end
  end
`endif

  // ===== 监视打印 (printf monitor) =====
  initial begin
    $display("time(ns)  rst buy  sell");
    $monitor("%8t   %b  %3d  %3d", $time, reset, buy_price, sell_price);
  end

endmodule
