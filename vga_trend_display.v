// ============================================================================
// 文件名: vga_trend_display.v
// 修改内容: 
// 1. [核心] 价格曲线 Y 轴放大 8 倍 (让波动充满屏幕)
// 2. [视觉] 绿色走势线加粗到 7 像素
// 3. 底部蓝色交易计数条保持不变
// ============================================================================

module vga_trend_display(
    input clk,              // 50MHz
    input reset,
    input video_on,         // VGA 显示有效区域
    input [9:0] h_cnt,      // X 坐标 (0-639)
    input [9:0] v_cnt,      // Y 坐标 (0-479)
    input [7:0] trade_price,// 最新成交价
    input match_signal,     // 触发更新信号
    input [7:0] spread,     // 价差
    input [7:0] trade_count,// 交易计数
    output [3:0] R, G, B    // VGA 颜色输出
);

    // ============================================================
    // 1. 历史价格存储 (移位寄存器)
    // ============================================================
    reg [7:0] price_history [0:639];
    integer i;
    reg match_prev;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            match_prev <= 0;
            for (i = 0; i < 640; i = i + 1) price_history[i] <= 8'd0;
        end
        else begin
            match_prev <= match_signal;
            // 撮合成功(上升沿) -> 历史记录左移
            if (match_signal && !match_prev) begin
                for (i = 0; i < 639; i = i + 1) begin
                    price_history[i] <= price_history[i+1];
                end
                price_history[639] <= trade_price; // 新价格入队
            end
        end
    end

    // ============================================================
    // 2. 图形区域划分
    // ============================================================
    
    // --- 区域 A: 左侧红色价差条 (Vertical Spread Bar) ---
    // 位置: X < 20
    // 高度: spread * 4
    wire [10:0] spread_height = {3'b0, spread} << 2; 
    wire is_spread_bar;
    assign is_spread_bar = (h_cnt < 20) && (v_cnt >= (11'd480 - spread_height));

    // --- 区域 B: 底部蓝色交易计数条 (Trade Count Bar) ---
    // 位置: 底部 10 像素 (Y >= 470)
    // 长度: trade_count * 6 (最大 100 * 6 = 600 像素)
    wire [9:0] trade_bar_width = {2'b0, trade_count} * 6;
    wire is_trade_bar;
    assign is_trade_bar = (v_cnt >= 470) && (h_cnt < trade_bar_width);

    // --- 区域 C: 刻度线 (Scale Lines) ---
    wire is_scale;
    // 1. 价差刻度: 在红色条右边 (X=20~25) 每隔 50 像素画一个小横杠
    wire is_spread_tick = (h_cnt >= 20 && h_cnt < 25) && (v_cnt % 50 == 0);
    // 2. 价格网格: 在走势区 (X > 40) 每隔 50 像素画一条水平虚线
    wire is_price_grid = (h_cnt > 40) && (v_cnt % 50 == 0) && (h_cnt[2] == 1'b0);
    
    assign is_scale = is_spread_tick || is_price_grid;

    // --- 区域 D: 绿色走势线 (Trend Line) ---
    wire is_trend_line;
    wire [7:0] current_x_price;
    wire [10:0] y_pos; 

    assign current_x_price = price_history[h_cnt]; 
    
    // [核心修改 1] Y轴映射放大 8 倍 (<< 3)
    // 之前是 4倍 (450 - price*4)。现在为了防溢出和居中，调整基准线为 800。
    // 计算逻辑: Y = 800 - (price * 8)
    // 举例: 
    //   价格 50 -> Y = 800 - 400 = 400 (屏幕下方)
    //   价格 90 -> Y = 800 - 720 = 80  (屏幕上方)
    //   范围从 80 到 400，占据了屏幕 2/3 的高度，非常明显。
    assign y_pos = 11'd800 - ({3'b0, current_x_price} << 3); 

    // [核心修改 2] 画线加粗 (从 +/- 2 改为 +/- 3，总宽 7 像素)
    assign is_trend_line = (h_cnt > 40 && v_cnt < 470) && 
                           (v_cnt >= y_pos - 3 && v_cnt <= y_pos + 3);

    // ============================================================
    // 3. 颜色输出逻辑
    // ============================================================
    
    assign R = !video_on ? 4'h0 : 
               (is_scale      ? 4'h7 :  // 刻度: 灰
                is_spread_bar ? 4'hF :  // 价差: 红
                4'h0);

    assign G = !video_on ? 4'h0 : 
               (is_scale      ? 4'h7 :  // 刻度: 灰
                is_trend_line ? 4'hF :  // 走势: 绿
                4'h0);

    assign B = !video_on ? 4'h0 : 
               (is_trade_bar  ? 4'hF :  // 交易数: 蓝
                is_scale      ? 4'h7 :  // 刻度: 灰
                4'h0);

endmodule