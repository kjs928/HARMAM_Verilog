
module stopwatch_dp (
    input clk,
    reset,
    run,
    clear,
    output [6:0] msec,
    output [6:0] sec,
    output [6:0] min,
    output [4:0] hour
);

    wire tick_100, tick_msec, tick_sec, tick_min;

    clk_div_100 u_clk_div_100 (
        .clk  (clk),
        .reset(reset),
        .run  (run),
        .clear(clear),
        .o_clk(tick_100)
    );

    time_counter #(
        .TICK_COUNT(100),
        .BIT_WIDTH (7)
    ) u_time_counter_Msec (
        .clk(clk),
        .reset(reset),
        .i_tick(tick_100),
        .o_time(msec),
        .o_tick(tick_msec),
        .clear(clear)
    );

    time_counter #(
        .TICK_COUNT(60),
        .BIT_WIDTH (7)
    ) u_time_counter_Sec (
        .clk(clk),
        .reset(reset),
        .i_tick(tick_msec),
        .o_time(sec),
        .o_tick(tick_sec),
        .clear(clear)
    );

    time_counter #(
        .TICK_COUNT(60),
        .BIT_WIDTH (7)
    ) u_time_counter_Min (
        .clk(clk),
        .reset(reset),
        .i_tick(tick_sec),
        .o_time(min),
        .o_tick(tick_min),
        .clear(clear)
    );

    time_counter #(
        .TICK_COUNT(24),
        .BIT_WIDTH (5)
    ) u_time_counter_Hour (
        .clk(clk),
        .reset(reset),
        .i_tick(tick_min),
        .o_time(hour),
        .clear(clear)
    );



endmodule


module clk_div_100 (
    input  clk,
    reset,
    run,
    clear,
    output o_clk
);
    //parameter FCOUNT = 10; // 시물레이션 용 clk 주파수 조절
    parameter FCOUNT = 1_000_000; //실제 fpga에 올릴 주파수값
    reg [$clog2(FCOUNT)-1:0] count_reg, count_next;
    reg
        clk_reg,
        clk_next; // 출력을 FF를 사용하여 sequential 하게 내보내기


    assign o_clk = clk_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            clk_reg   <= 0;
        end else begin
            count_reg <= count_next;
            clk_reg   <= clk_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        clk_next   = 1'b0;
        if (run) begin
            if (count_next == FCOUNT - 1) begin
                count_next = 0;
                clk_next   = 1'b1;
            end else begin
                count_next = count_reg + 1;
                clk_next   = 1'b0;
            end
        end else if (clear) begin
            count_next = 0;
            clk_next   = 0;
        end

    end


endmodule

module time_counter #(
    parameter TICK_COUNT = 100,
    BIT_WIDTH = 7
) (
    input clk,
    input reset,
    input clear,
    input i_tick,
    output reg [BIT_WIDTH-1:0] o_time,
    output reg o_tick
);

 

    always @(posedge clk or posedge reset) begin
        if (reset || clear) begin
            o_time <= 0;
            o_tick <= 0;

        end else begin
            if (i_tick) begin  
                if (o_time == TICK_COUNT - 1) begin
                    o_time <= 0;
                    o_tick <= 1;
                end else begin
                    o_time <= o_time + 1;
                    o_tick <= 0;
                end
            end else begin
                o_tick <= 0; 
            end
        end
    end



endmodule

