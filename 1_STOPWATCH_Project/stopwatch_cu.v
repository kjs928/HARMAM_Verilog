
module stopwatch_cu (
    input  
    clk,
    reset,
    i_btn_run,
    i_btn_clear,

    output reg
    o_run,
    o_clear

);

    // FSM 구조로 cu 설계
    parameter STOP = 2'b00, RUN = 2'b01, CLEAR = 2'b10;

    reg [1:0] state,next;

    //state register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= STOP;
        end else begin
            state <= next;
        end

    end

    // next state 결정
    always @(*) begin
        next = state;
        case (state)
            STOP: begin 
                if (i_btn_run) next = RUN;
                else if (i_btn_clear) next = CLEAR; 
            end

            RUN: begin
                if (i_btn_run) next = STOP;
            end

            CLEAR:begin
                if (i_btn_clear) begin
                    next = STOP;
                end
            end

        endcase
    end

    // 출력 부분(o_run,o_clear)
    always @(*) begin
        o_run = 1'b0;
        o_clear = 1'b0;
        case (state)
            RUN:begin
                o_run  = 1'b1;
                o_clear = 1'b0;
            end

            STOP: begin
                o_run  = 1'b0;
                o_clear = 1'b0;
            end

            CLEAR: begin
                o_run  = 1'b0;
                o_clear = 1'b1;
            end 
        endcase
    end

endmodule
