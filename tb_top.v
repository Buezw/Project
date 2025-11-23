`timescale 1ns/1ps

module tb_top();

    // 1. 定义输入信号 (用 reg)
    reg CLOCK_50;
    reg [3:0] KEY;

    // 2. 定义输出信号 (用 wire)
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    wire [9:0] LEDR;
    wire [3:0] VGA_R, VGA_G, VGA_B;
    wire VGA_HS, VGA_VS;

    // 3. 实例化你的 Top 模块
    top uut (
        .CLOCK_50(CLOCK_50), 
        .KEY(KEY), 
        .HEX0(HEX0), 
        .HEX1(HEX1), 
        .HEX2(HEX2), 
        .HEX3(HEX3), 
        .HEX4(HEX4), 
        .HEX5(HEX5), 
        .LEDR(LEDR), 
        .VGA_R(VGA_R), 
        .VGA_G(VGA_G), 
        .VGA_B(VGA_B), 
        .VGA_HS(VGA_HS), 
        .VGA_VS(VGA_VS)
    );

    // 4. 生成 50MHz 时钟
    // 周期 20ns (10ns 高, 10ns 低)
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50; 
    end

    // 5. 模拟按键流程
    initial begin
        // 初始化：所有按键未按下 (DE2板子上按键未按下是高电平 1)
        KEY = 4'b1111; 

        // --- 复位阶段 ---
        #100;
        KEY[0] = 0; // 按下复位键 (Reset 是 ~KEY[0], 见 top.v)
        #100;
        KEY[0] = 1; // 释放复位键
        #100;

        // --- 触发生成订单 (KEY4) ---
        // 你的代码中 KEY4 = ~KEY[3]
        // 按下 KEY[3] 来产生新的随机数
        repeat(10) begin
            #2000;         // 等待一段时间
            KEY[3] = 0;    // 按下生成键
            #2000;         // 保持按下
            KEY[3] = 1;    // 松开生成键
        end

        // 运行足够长的时间以观察撮合
        #500000; 
        $stop;
    end

endmodule