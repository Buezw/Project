module top (
    input CLOCK_50,
    input [3:0] KEY,

    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5,

    output [9:0] LEDR,

    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS,

    // --- Audio Interface Ports (音频接口) ---
    input  AUD_ADCDAT,
    inout  AUD_ADCLRCK,
    inout  AUD_BCLK,
    output AUD_DACDAT,
    inout  AUD_DACLRCK,
    output AUD_XCK,

    // --- I2C Configuration Ports (I2C 配置接口) ---
    output FPGA_I2C_SCLK,
    inout  FPGA_I2C_SDAT
);
    
    wire clk_50;
    wire reset;

    assign clk_50 = CLOCK_50;
    assign reset = ~KEY[0];

    wire clk_25;
    wire slow_clk;
    clk_div2 div25(clk_50, reset, clk_25);

    wire [7:0] buy_price;
    wire [7:0] sell_price;
    wire [7:0] best_bid;
    wire [7:0] best_ask;
    wire [7:0] trade_price;
    wire [7:0] spread_now;
    wire [7:0] trade_count;

    wire [1:0] state;

    wire match_signal;
    wire halt_signal;
    wire enable_count;

    order_generator generator(clk_50, reset, buy_price, sell_price, KEY, slow_clk);

    matching_engine engine(clk_50, reset, buy_price, sell_price, match_signal, trade_price, best_bid, best_ask);

    controller_fsm controller(clk_50, reset, match_signal, halt_signal, state, enable_count);

    counter trade_counter(slow_clk, reset, match_signal, enable_count, trade_count, halt_signal);

    spread spread_calc(clk_50, reset, match_signal, enable_count, buy_price, sell_price, spread_now);

    display_hex display_unit(buy_price, sell_price, spread_now, trade_count, state, halt_signal, match_signal,
                             HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR);

wire [31:0] left_channel_audio;
    wire [31:0] right_channel_audio;
    wire audio_trigger;

    // 触发逻辑：当 match_signal 和 enable_count 都为高时
    assign audio_trigger = match_signal & enable_count;

    // 1. 音频生成模块 (Tone Generator)
    audio_tone_generator tone_gen (
        .clk(clk_50),
        .reset(reset),
        .trigger_signal(audio_trigger),
        .left_channel(left_channel_audio),
        .right_channel(right_channel_audio)
    );

    // 2. 音频时钟 (Audio Clock)
    // 直接使用 50MHz 作为 WM8731 的主时钟 (XCK)
    assign AUD_XCK = clk_50; 

    // 3. 音频控制器 (Audio Controller - I2S Driver)
    // 负责发送数据到音频芯片
    Audio_Controller audio_control (
        .clk(clk_50),
        .rst_n(!reset),
        .left_data(left_channel_audio[31:16]),  // 取高16位以匹配大多数驱动
        .right_data(right_channel_audio[31:16]),
        .AUD_BCLK(AUD_BCLK),
        .AUD_DACLRCK(AUD_DACLRCK),
        .AUD_DACDAT(AUD_DACDAT)
    );

    // 4. 音频配置 (Audio Config - I2C)
    // 配置 WM8731 芯片开启并设置音量
    avconf audio_config (
        .CLOCK_50(clk_50),
        .reset(reset),
        .FPGA_I2C_SCLK(FPGA_I2C_SCLK),
        .FPGA_I2C_SDAT(FPGA_I2C_SDAT)
    );

endmodule
