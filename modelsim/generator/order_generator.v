// =====================================================
// Module 1: Order Generator (LFSR-based Price Feed)
// =====================================================


module order_generator (clk, reset, buy_price, sell_price);
    input clk;         
    input reset;       
    output [7:0] buy_price;  
    output [7:0] sell_price; 

    // Pseudo-Random Shift Register, has a sequence of 2^15 
    reg [15:0] lfsr1;
    reg [15:0] lfsr2;
    reg [20:0] div;

    // Clock divider
    always @(posedge clk or posedge reset) 
    begin
        if (reset)
        begin
            div <= 0;
        end
        else
            div <= div+1;
    end

    wire slow_clk = div[20];

    // Implement of Shift Register
always @(posedge slow_clk or posedge reset)
    begin
    if (reset) 
    begin
        // Give a none zero value;
        lfsr1 <= 16'hACE1;
        lfsr2 <= 16'h3C21;
    end
    else 
    begin
        // Shift
        lfsr1[15] <= lfsr1[14];
        lfsr1[14] <= lfsr1[13];
        lfsr1[13] <= lfsr1[12];
        lfsr1[12] <= lfsr1[11];
        lfsr1[11] <= lfsr1[10];
        lfsr1[10] <= lfsr1[9];
        lfsr1[9] <= lfsr1[8];
        lfsr1[8] <= lfsr1[7];
        lfsr1[7] <= lfsr1[6];
        lfsr1[6] <= lfsr1[5];
        lfsr1[5] <= lfsr1[4];
        lfsr1[4] <= lfsr1[3];
        lfsr1[3] <= lfsr1[2];
        lfsr1[2] <= lfsr1[1];
        lfsr1[1] <= lfsr1[0];
        lfsr1[0] <= (lfsr1[15] ^ lfsr1[13] ^ lfsr1[12] ^ lfsr1[10]);

        lfsr2[15] <= lfsr2[14];
        lfsr2[14] <= lfsr2[13];
        lfsr2[13] <= lfsr2[12];
        lfsr2[12] <= lfsr2[11];
        lfsr2[11] <= lfsr2[10];
        lfsr2[10] <= lfsr2[9];
        lfsr2[9] <= lfsr2[8];
        lfsr2[8] <= lfsr2[7];
        lfsr2[7] <= lfsr2[6];
        lfsr2[6] <= lfsr2[5];
        lfsr2[5] <= lfsr2[4];
        lfsr2[4] <= lfsr2[3];
        lfsr2[3] <= lfsr2[2];
        lfsr2[2] <= lfsr2[1];
        lfsr2[1] <= lfsr2[0];
        lfsr2[0] <= (lfsr2[15] ^ lfsr2[14] ^ lfsr2[12] ^ lfsr2[3]);
    end
end

// Assign Pseudo-Random
assign buy_price  = 8'd50 + lfsr1[4:0];  
assign sell_price = 8'd55 + lfsr2[4:0];


endmodule