module clock_dp (
    input clk,
    input reset,
    input i_sec, i_min, i_hour,
    output [6:0] msec,
    output [6:0] sec,
    output [6:0] min,
    output [4:0] hour
);

    wire tick_100, tick_msec, tick_sec, tick_min;

    clk_div_100_clk u_clk_div_100 (
        .clk  (clk),
        .reset(reset),
        .o_clk(tick_100)
    );

    time_counter_clk #(
        .TICK_COUNT(100),
        .BIT_WIDTH (7)
    ) u_time_counter_Msec (
        .clk(clk),
        .reset(reset),
        .i_time(1'b0),
        .i_tick(tick_100),
        .o_time(msec),
        .o_tick(tick_msec)
    );

    time_counter_clk #(
        .TICK_COUNT(60),
        .BIT_WIDTH (7)
    ) u_time_counter_Sec (
        .clk(clk),
        .reset(reset),
        .i_time(i_sec),
        .i_tick(tick_msec),
        .o_time(sec),
        .o_tick(tick_sec)
    );

    time_counter_clk #(
        .TICK_COUNT(60),
        .BIT_WIDTH (7)
    ) u_time_counter_Min (
        .clk(clk),
        .reset(reset),
        .i_time(i_min),
        .i_tick(tick_sec),
        .o_time(min),
        .o_tick(tick_min)
    );

    time_counter_clk #(
        .TICK_COUNT(24),
        .BIT_WIDTH (5)
    ) u_time_counter_Hour (
        .clk(clk),
        .reset(reset),
        .i_time(i_hour),
        .i_tick(tick_min),
        .o_time(hour),
        .o_tick() // 필요 없는 경우 연결 생략
    );

endmodule

module clk_div_100_clk (
    input clk,
    input reset,
    output reg o_clk
);

    parameter FCOUNT = 1_000_000; // 100Hz 클럭 생성

    reg [$clog2(FCOUNT)-1:0] count_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            o_clk <= 0;  
        end else begin
            if (count_reg == FCOUNT - 1) begin 
                count_reg <= 0;
                o_clk <= 1; 
            end else begin
                count_reg <= count_reg + 1;
                o_clk <= 0;
            end
        end
    end

endmodule

module time_counter_clk #(
    parameter TICK_COUNT = 100,
    parameter BIT_WIDTH = 7
) (
    input clk,
    input reset,
    input i_time,
    input i_tick,
    output reg [BIT_WIDTH-1:0] o_time,
    output reg o_tick
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            o_time <= 0;
            o_tick <= 0;
        end else begin
            if (i_tick || (i_time && !o_tick)) begin  
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
