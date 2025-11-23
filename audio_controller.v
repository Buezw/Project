// =============================================================
// 文件名: audio_controller.v
// 说明: 独立版音频控制器，无需外部 Altera IP
// =============================================================
module audio_controller (
    // Inputs
    CLOCK_50,
    reset,
    clear_audio_in_memory,
    clear_audio_out_memory,
    left_channel_audio_out,
    right_channel_audio_out,
    write_audio_out,
    read_audio_in,
    
    // Outputs
    audio_in_available,
    left_channel_audio_in,
    right_channel_audio_in,
    audio_out_allowed,
    
    // Audio CODEC Ports
    AUD_ADCDAT,
    AUD_DACDAT,
    AUD_BCLK,
    AUD_ADCLRCK,
    AUD_DACLRCK,
    AUD_XCK,
    
    // I2C Ports (为了兼容 top.v 连接，声明但不使用)
    I2C_SCLK,
    I2C_SDAT
);

    parameter AUDIO_DATA_WIDTH = 32;
    parameter BIT_COUNTER_INIT = 5'd31;

    // --- 端口定义 ---
    input CLOCK_50;
    input reset;
    input clear_audio_in_memory;
    input clear_audio_out_memory;
    input [AUDIO_DATA_WIDTH-1:0] left_channel_audio_out;
    input [AUDIO_DATA_WIDTH-1:0] right_channel_audio_out;
    input write_audio_out;
    input read_audio_in;

    output audio_in_available;
    output [AUDIO_DATA_WIDTH-1:0] left_channel_audio_in;
    output [AUDIO_DATA_WIDTH-1:0] right_channel_audio_in;
    output audio_out_allowed;

    input AUD_ADCDAT;
    inout AUD_DACDAT;
    inout AUD_BCLK;
    inout AUD_ADCLRCK;
    inout AUD_DACLRCK;
    output AUD_XCK;
    
    // I2C 端口悬空 (avconf 模块会处理 I2C)
    output I2C_SCLK;
    inout  I2C_SDAT;
    assign I2C_SCLK = 1'bz;
    assign I2C_SDAT = 1'bz;

    // --- 内部逻辑 ---
    
    reg [AUDIO_DATA_WIDTH-1:0] left_channel_fifo_out;
    reg [AUDIO_DATA_WIDTH-1:0] right_channel_fifo_out;

    reg audio_out_allowed_reg;
    assign audio_out_allowed = audio_out_allowed_reg;
    
    reg AUD_DACDAT_reg;
    assign AUD_DACDAT = AUD_DACDAT_reg;

    assign audio_in_available = 1'b0; // 暂时简化输入
    assign left_channel_audio_in = 32'd0;
    assign right_channel_audio_in = 32'd0;

    // 1. 生成 MCLK (AUD_XCK)
    // WM8731 需要 MCLK。简单做法是将 50MHz 输出，或使用计数器分频。
    // 为了最简单的兼容性，我们直接输出 CLOCK_50。
    // 注意：完美的实现应该使用 PLL 生成 18.432MHz。
    assign AUD_XCK = CLOCK_50; 

    // 2. 简单的并行转串行 (Serializer) 逻辑
    // 我们假设 CODEC 是主模式 (Master Mode)，它提供 BCLK 和 DACLRCK。
    
    reg [AUDIO_DATA_WIDTH-1:0] shift_left;
    reg [AUDIO_DATA_WIDTH-1:0] shift_right;
    reg lrck_prev;
    reg bclk_prev;

    always @(posedge CLOCK_50 or posedge reset) begin
        if (reset) begin
            audio_out_allowed_reg <= 0;
            AUD_DACDAT_reg <= 0;
            shift_left <= 0;
            shift_right <= 0;
            lrck_prev <= 0;
            bclk_prev <= 0;
        end else begin
            lrck_prev <= AUD_DACLRCK;
            bclk_prev <= AUD_BCLK;
            
            // 检测 LRCK 边沿：意味着新的一帧开始 (Left/Right channel switch)
            if (lrck_prev != AUD_DACLRCK) begin
                if (AUD_DACLRCK) begin 
                    // LRCK 上升沿 (变高) -> 准备加载右声道，或结束左声道
                    // 具体的对齐取决于 I2S/Left-Justified 模式。
                    // 简单起见，我们在 LRCK 变化时请求新数据
                end else begin
                    // LRCK 下降沿
                end
            end

            // 简化逻辑：只要 write_audio_out 信号来了，我们就锁存数据
            // 并设置 allowed 标志位
            if (write_audio_out) begin
                shift_left <= left_channel_audio_out;
                shift_right <= right_channel_audio_out;
                audio_out_allowed_reg <= 0; // 忙
            end 
            
            // 在 LRCK 变化时重置 allowed，请求下一次数据
            // 这里做一个简单的计数器模拟以产生"允许写入"信号
            // 实际上应该配合 FIFO，但为了最简代码：
            if (lrck_prev != AUD_DACLRCK) begin
                audio_out_allowed_reg <= 1; 
            end

            // BCLK 下降沿发送数据
            if (bclk_prev && !AUD_BCLK) begin 
                if (!AUD_DACLRCK) begin
                    // 左声道发送
                    AUD_DACDAT_reg <= shift_left[AUDIO_DATA_WIDTH-1];
                    shift_left <= {shift_left[AUDIO_DATA_WIDTH-2:0], 1'b0};
                end else begin
                    // 右声道发送
                    AUD_DACDAT_reg <= shift_right[AUDIO_DATA_WIDTH-1];
                    shift_right <= {shift_right[AUDIO_DATA_WIDTH-2:0], 1'b0};
                end
            end
        end
    end

endmodule