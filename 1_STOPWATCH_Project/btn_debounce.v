module btn_debounce(
    input i_btn, clk, reset,
    output o_btn
);

    // 1kHz 클럭 분주를 위한 레지스터
    reg [$clog2(100_000)-1:0] counter_reg;
    reg r_1khz;

    // 디바운스 처리용 시프트 레지스터
    reg [7:0] q_reg;
    reg edge_detect;
    wire btn_debounce;

    //  1kHz 클럭 생성기 (동기적 동작)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            r_1khz <= 0;
        end else if (counter_reg == 100_000 - 1) begin
            counter_reg <= 0;
            r_1khz <= 1;  // 1kHz 펄스 발생
        end else begin
            counter_reg <= counter_reg + 1;
            r_1khz <= 0;
        end
    end

    //  디바운스용 시프트 레지스터 (1kHz 클럭에 동기화)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            q_reg <= 0;
        end else if (r_1khz) begin  // 1kHz 속도로 업데이트
            q_reg <= {i_btn, q_reg[7:1]};
        end
    end

    //  모든 비트가 1이면 버튼이 안정적으로 눌린 것으로 판단
    assign btn_debounce = &q_reg;

    //  Edge Detector (이전 상태 저장)
    always @(posedge clk or posedge reset) begin
        if (reset) 
            edge_detect <= 0;
        else 
            edge_detect <= btn_debounce;  // btn_debounce의 이전 상태 저장
    end

    // 최종 출력 
    assign o_btn = btn_debounce & ~edge_detect;

endmodule
