

module top_stopwatch (
    input clk,
    reset,
    btn_run_hour,
    btn_clear,
    btn_min,
    btn_sec,
    input [1:0]sw,

    output [3:0] fnd_comm,
    output [7:0] fnd_font,
    output [3:0] led
);

    wire w_btn_clear,w_btn_run_hour,w_btn_run,w_btn_hour,w_btn_min,w_btn_sec;
    wire w_run,w_clear; //control unit output
    wire [6:0]s_msec,s_sec,s_min,c_msec,c_sec,c_min,msec,sec,min;
    wire [4:0]s_hour,c_hour,hour;
    
    assign w_btn_run=w_btn_run_hour & (!sw[1]);
    assign w_btn_hour= w_btn_run_hour & (sw[1]);



    btn_debounce u_btn_debounce_RUN_STOP_HOUR(
        .i_btn(btn_run_hour), 
        .clk(clk), 
        .reset(reset),
        .o_btn(w_btn_run_hour)
    );

    btn_debounce u_btn_debounce_CLEAR(
        .i_btn(btn_clear), 
        .clk(clk), 
        .reset(reset),
        .o_btn(w_btn_clear)
    );

    btn_debounce u_btn_debounce_MIN(
        .i_btn(btn_min), 
        .clk(clk), 
        .reset(reset),
        .o_btn(w_btn_min)
    );

    btn_debounce u_btn_debounce_SEC(
        .i_btn(btn_sec), 
        .clk(clk), 
        .reset(reset),
        .o_btn(w_btn_sec)
    );

    clock_dp u_clock_dp(
        .clk(clk),
        .reset(reset),
        .i_sec(w_btn_sec),
        .i_min(w_btn_min),
        .i_hour(w_btn_hour),
        .msec(c_msec),
        .sec(c_sec),
        .min(c_min),
        .hour(c_hour)
    );


    stopwatch_dp u_stopwatch_dp(
        .clk(clk),
        .reset(reset),
        .run(w_run),
        .clear(w_clear),
        .msec(s_msec),
        .sec(s_sec),
        .min(s_min),
        .hour(s_hour)
    );



    stopwatch_cu u_control_unit (
        .clk(clk),
        .reset(reset),
        .i_btn_run(w_btn_run),
        .i_btn_clear(w_btn_clear),
        .o_run(w_run),
        .o_clear(w_clear)
    );

    fnd_controller u_fnd_controller (
        .clk(clk),
        .reset(reset),
        .sw_mode(sw[0]),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );

    led_indicator u_led_indicator (
        .sw(sw),
        .clk(clk),
        .reset(reset),
        .led(led)
    );

    dp_mux u_dp_mux(
        .s_hour(s_hour),
        .s_min(s_min),
        .s_msec(s_msec),
        .s_sec(s_sec),
        .c_hour(c_hour),
        .c_min(c_min),
        .c_msec(c_msec),
        .c_sec(c_sec),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour),
        .sw_mode(sw[1])
      
    );




endmodule

module led_indicator (
    input reset,clk,
    input [1:0]sw,
    output reg [3:0] led
);
    always @(posedge clk or posedge reset) begin
    if (reset) begin
        led <= 4'b0000;
    end else begin
        case (sw)
            2'b00:led <= 4'b0001;
            2'b01: led <= 4'b0010;
            2'b10: led <= 4'b0100;
            2'b11: led <= 4'b1000; 
            default: led <= 4'b0000;
        endcase
    end
end

endmodule  // ✅ end 추가



module dp_mux (
    input [6:0] s_msec, s_sec, s_min, c_msec, c_sec, c_min,
    input [4:0] s_hour, c_hour,
    input sw_mode,
    output reg [6:0] msec, sec, min,
    output reg [4:0] hour
);

    always @(*) begin
            // sw_mode에 따라 선택
            if (sw_mode == 0) begin
                msec = s_msec;
                sec  = s_sec;
                min  = s_min;
                hour = s_hour;
            end else begin
                msec = c_msec;
                sec  = c_sec;
                min  = c_min;
                hour = c_hour;
            end
        end

    
endmodule
