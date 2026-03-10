module elif_hw1(
    input  logic clk,
    input  logic reset,
    input  logic TAORB,
    output logic [1:0] LA, // Street A: 2'b10=G, 2'b01=Y, 2'b00=R
    output logic [1:0] LB  // Street B: 2'b10=G, 2'b01=Y, 2'b00=R
);

    // 1. Durum Tanımlamaları [cite: 1187, 1140, 1141, 1142, 1143]
    typedef enum logic [1:0] {S0, S1, S2, S3} state_t;
    state_t state, next_state;

    logic [2:0] timer; // 0-7 arası sayabilir, 5 için yeterli [cite: 1187]

    // 2. Durum Register'ı (Sequential Logic) [cite: 1199, 302, 303]
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= S0;
        else
            state <= next_state;
    end

    // 3. Zamanlayıcı Mantığı (Sequential) [cite: 1200, 1201]
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            timer <= 3'd0;
        // S1 veya S3 (Sarı ışıklar) durumunda say [cite: 1190, 1195]
        else if (state == S1 || state == S3)
            timer <= timer + 3'd1;
        else
            timer <= 3'd0; // S0 veya S2'ye geçince sıfırla [cite: 1201]
    end

    // 4. Sonraki Durum Mantığı (Combinational) [cite: 1199, 1187]
    always_comb begin
        case (state)
            S0: begin // A Yeşil, B Kırmızı [cite: 1188]
                if (TAORB) next_state = S0;
                else       next_state = S1; // Trafik B'ye kayarsa [cite: 1189]
            end

            S1: begin // A Sarı, B Kırmızı (5 Döngü Bekle) [cite: 1190, 1191]
                if (timer < 3'd4) next_state = S1; // 0,1,2,3,4 -> Toplam 5 döngü
                else              next_state = S2;
            end

            S2: begin // A Kırmızı, B Yeşil [cite: 1192]
                if (!TAORB) next_state = S2;
                else        next_state = S3; // Trafik A'ya dönerse [cite: 1193]
            end

            S3: begin // A Kırmızı, B Sarı (5 Döngü Bekle) [cite: 1194, 1196]
                if (timer < 3'd4) next_state = S3;
                else              next_state = S0;
            end

            default: next_state = S0;
        endcase
    end

    // 5. Çıkış Mantığı (Combinational) [cite: 1199, 1186]
    always_comb begin
        case (state)
            S0: begin LA = 2'b10; LB = 2'b00; end // Green - Red [cite: 1140]
            S1: begin LA = 2'b01; LB = 2'b00; end // Yellow - Red [cite: 1141]
            S2: begin LA = 2'b00; LB = 2'b10; end // Red - Green [cite: 1142]
            S3: begin LA = 2'b00; LB = 2'b01; end // Red - Yellow [cite: 1143]
            default: begin LA = 2'b00; LB = 2'b00; end
        endcase
    end

endmodule