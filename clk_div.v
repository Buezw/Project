// Module: clk_div2

module clk_div2 (clk_in, reset, clk_out);

    input clk_in;   
    input reset;      
    output clk_out;  

    reg clk_out;

    always @(posedge clk_in or posedge reset)
    begin
        if (reset)
            clk_out <= 1'b0;
        else
            clk_out <= ~clk_out;  
    end

endmodule
