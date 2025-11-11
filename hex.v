// =====================================================
// Module: hex8_to_dec3
// Description: Convert 8-bit hex (0x00–0xFF) to decimal digits
// Example: 8'h4F = 79 -> hundreds=0, tens=7, ones=9
// =====================================================

module hex8_to_dec3 (
    input  [7:0] hex_in,       // 输入 8位16进制 (0x00–0xFF)
    output reg [3:0] hundreds, // 百位
    output reg [3:0] tens,     // 十位
    output reg [3:0] ones      // 个位
);

    integer value;
    always @(*) begin
        // 转成整数
        value = hex_in;

        // 计算各位数字
        hundreds = value / 100;
        tens     = (value % 100) / 10;
        ones     = value % 10;
    end
endmodule