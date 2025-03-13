module fnd_controller (
    input clk,
    input reset,
    input sw_mode,
    input [6:0] msec,
    input [6:0] sec,
    input [6:0] min,
    input [4:0] hour,
    output [7:0] fnd_font,
    output [3:0] fnd_comm
);

    wire [3:0] w_bcd, 
    w_digit_1_msec, w_digit_10_msec,
    w_digit_1_sec, w_digit_10_sec, 
    w_digit_1_min, w_digit_10_min, 
    w_digit_1_hour, w_digit_10_hour,
    w_msec_sec,w_min_hour;

    wire [2:0] seg_sel;
    wire o_clk,o_dot;

    // ✅ 1kHz 클럭 분주기
    clk_divider u_clk_divider (
        .clk  (clk),
        .reset(reset),
        .o_clk(o_clk)
    );

    // ✅ 7-segment 선택 카운터 (0~3)
    counter u_counter (
        .clk(o_clk),
        .reset(reset),
        .seg_sel(seg_sel)
    );

    digit_splitter #(7) u_ds_Msec (
        .bcd(msec),
        .digit_1(w_digit_1_msec),
        .digit_10(w_digit_10_msec)
    );

    digit_splitter #(7) u_ds_Sec (
        .bcd(sec),
        .digit_1(w_digit_1_sec),
        .digit_10(w_digit_10_sec)
    );

    digit_splitter #(7) u_ds_Min (
        .bcd(min),
        .digit_1(w_digit_1_min),
        .digit_10(w_digit_10_min)
    );

    digit_splitter #(5) u_ds_Hour (
        .bcd(hour),
        .digit_1(w_digit_1_hour),
        .digit_10(w_digit_10_hour)
    );
    mux_8x1 u_mux_8x1_msec_sec (
        .sel(seg_sel),
        .x0(w_digit_1_msec), 
        .x1(w_digit_10_msec), 
        .x2(w_digit_1_sec), 
        .x3(w_digit_10_sec), 
        .x4(4'hf), 
        .x5(4'hf), 
        .x6(4'hf), 
        .x7(4'hf),
        .y(w_msec_sec)
    );

    mux_8x1 u_mux_8x1_min_hour (
        .sel(seg_sel),
        .x0(w_digit_1_min), 
        .x1(w_digit_10_min), 
        .x2(w_digit_1_hour), 
        .x3(w_digit_10_hour), 
        .x4(4'hf), 
        .x5(4'hf), 
        .x6(4'hf), 
        .x7(4'hf),
        .y(w_min_hour)
    );

    mux_2x1 u_final_select(
        .select(sw_mode),
        .x0(w_msec_sec),
        .x1(w_min_hour),
        .out(w_bcd)
    );



    // ✅ BCD 값을 7-Segment로 변환
    bcdtoseg u_bcdtoseg (
        .bcd(w_bcd),
        .seg(fnd_font),
        .dot_enable((seg_sel == 3'b010)& o_dot)
    );

    // ✅ 활성화할 7-segment 자리 선택
    decoder_3x8 u_dec (
        .seg_sel (seg_sel),
        .seg_comm(fnd_comm)
    );

    dot_enable u_dot_enable (
    .clk(clk), 
    .reset(reset), 
    .o_dot(o_dot)
    );


endmodule

module mux_2x1 (
    input select,
    input [3:0] x0, x1,
    output [3:0] out
);
    assign out = (select) ? x1 : x0;
endmodule



module decoder_3x8 (
    input [2:0] seg_sel,
    output reg [3:0] seg_comm
);
    always @(seg_sel) begin
        case (seg_sel)
            3'b000: seg_comm = 4'b1110;  // 1의 자리 활성화
            3'b001: seg_comm = 4'b1101;  // 10의 자리 활성화
            3'b010: seg_comm = 4'b1011;  // 100의 자리 활성화
            3'b011: seg_comm = 4'b0111;  // 1000의 자리 활성화
            3'b100: seg_comm = 4'b1110;  // 1의 자리 활성화 (반복)
            3'b101: seg_comm = 4'b1101;  // 10의 자리 활성화 (반복)
            3'b110: seg_comm = 4'b1011;  // 100의 자리 활성화 (반복)
            3'b111: seg_comm = 4'b0111;  // 1000의 자리 활성화 (반복)
            default:
            seg_comm = 4'b1111;  // 모든 자리 비활성화 (안전장치)
        endcase
    end
endmodule



module digit_splitter #(
    parameter BIT_WIDTH = 7
) (
    input [BIT_WIDTH-1:0] bcd,  // ✅ 7비트 Binary 입력
    output reg [3:0] digit_1,  // ✅ 1의 자리
    output reg [3:0] digit_10  // ✅ 10의 자리
);

    always @(*) begin
        digit_1 = bcd % 10;  // ✅ 1의 자리 (BCD의 하위 4비트)
        digit_10 = (bcd / 10) % 10;  // ✅ 10의 자리 (BCD의 상위 4비트)
    end
endmodule


module mux_8x1 (
    input [2:0] sel,
    input [3:0] x0, x1, x2, x3, x4, x5, x6, x7,
    output reg [3:0] y
);
    always @(*) begin
        case (sel)
            3'b000: y = x0;
            3'b001: y = x1;
            3'b010: y = x2;
            3'b011: y = x3;
            3'b100: y = x4;
            3'b101: y = x5;
            3'b110: y = x6;
            3'b111: y = x7;
            default: y = 4'b1111;  
        endcase
    end
endmodule


// ✅ 1kHz 클럭 분주기
module clk_divider (
    input  clk,
    input  reset,
    output o_clk
);
    parameter CLK_DIV = 50000; // ✅ 유지보수성을 위해 parameter 사용
    reg [15:0] r_count;
    reg r_clk;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_count <= 0;
            r_clk   <= 1'b0;
        end else begin
            if (r_count == CLK_DIV - 1) begin
                r_count <= 0;
                r_clk   <= ~r_clk;
            end else begin
                r_count <= r_count + 1;
            end
        end
    end

    assign o_clk = r_clk;
endmodule


// ✅ 7-Segment 선택을 위한 2비트 카운터
module counter (
    input clk,
    input reset,
    output reg [2:0] seg_sel // ✅ 2비트 → 3비트로 변경
);
    always @(posedge clk or posedge reset) begin
        if (reset) seg_sel <= 3'b000;
        else seg_sel <= seg_sel + 1;
    end
endmodule


// ✅ BCD → 7-Segment 변환
module bcdtoseg (
    input [3:0] bcd,
    input dot_enable,  // ✅ 추가: dot(소수점) 활성화 여부
    output reg [7:0] seg
);
    always @(bcd) begin
        case (bcd)
            4'h0: seg = 8'hC0;
            4'h1: seg = 8'hF9;
            4'h2: seg = 8'hA4;
            4'h3: seg = 8'hB0;
            4'h4: seg = 8'h99;
            4'h5: seg = 8'h92;
            4'h6: seg = 8'h82;
            4'h7: seg = 8'hF8;
            4'h8: seg = 8'h80;
            4'h9: seg = 8'h90;
            default: seg = 8'hFF;  // 예외 처리
        endcase

        // ✅ 소수점 비트(dot)를 제어
        if (dot_enable==1)begin
            seg = seg & 8'h7F;  // dot ON (7번째 비트를 0으로 설정)
        end
        else begin
            seg = seg | 8'h80;  // dot OFF (7번째 비트를 1로 설정)
        end
    end

endmodule

module dot_enable (
    input clk, reset, 
    output reg o_dot  // ✅ reg로 선언해야 함
);
    reg [25:0] count;  // ✅ 20비트 크기 (더 큰 주기 지원 가능)

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            o_dot <= 0;  // ✅ 초기화
        end else begin
            if (count == 49_999_999) begin  // ✅ 명확한 값 사용
                count <= 0;
                o_dot <= ~o_dot;  // ✅ 바로 토글
            end else begin
                count <= count + 1;
            end
        end
    end
endmodule



