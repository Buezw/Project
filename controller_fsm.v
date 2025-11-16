module controller_fsm (clk, reset, match_signal, halt_flag, state, enable_count);
    input clk;
    input reset;
    input match_signal;
    input halt_flag;

    output reg [1:0] state;
    output reg enable_count;

    parameter IDLE  = 2'b00;
    parameter MATCH = 2'b01;
    parameter HALT  = 2'b10;

    reg [1:0] next_state;

    // state register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // next state logic
    always @(*) begin
        next_state = IDLE; // default

        case (state)
            IDLE:
                if (halt_flag)
                    next_state = HALT;
                else if (match_signal)
                    next_state = MATCH;
                else
                    next_state = IDLE;

            MATCH:
                if (halt_flag)
                    next_state = HALT;
                else if (!match_signal)
                    next_state = IDLE;
                else
                    next_state = MATCH;

            HALT:
                if (!halt_flag)
                    next_state = IDLE;
                else
                    next_state = HALT;

            default: next_state = IDLE;
        endcase
    end

    // enable_count logic
    always @(*) begin
        enable_count = (state == MATCH);
    end

endmodule
