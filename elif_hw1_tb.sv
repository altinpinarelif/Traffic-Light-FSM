`timescale 1ns/1ps

module tb_elif_hw1();
    // 1. Giriş ve Çıkış Sinyalleri
    logic clk;
    logic reset;
    logic TAORB;
    wire [1:0] LA, LB;

    // 2. Test Edilen Modülün (DUT) Bağlanması
    elif_hw1 dut (
        .clk(clk),
        .reset(reset),
        .TAORB(TAORB),
        .LA(LA),
        .LB(LB)
    );

    // 3. Saat Sinyali Üretimi (10ns periyot)
    initial clk = 0;
    always #5 clk = ~clk; 

    // 4. Test Senaryosu
    initial begin
        // --- Başlangıç ve Reset ---
        reset = 1; TAORB = 1; // Başlangıçta A sokağında trafik var
        #20; 
        reset = 0; // Sistemi çalıştır (S0 durumuna girer)
        
        // --- Senaryo 1: S0 Beklemesi ---
        #50; // Bir süre S0'da (Yeşil-Kırmızı) bekle
        
        // --- Senaryo 2: Trafik Değişimi (TAORB = 0) ---
        TAORB = 0; // A boşaldı, B'de trafik var
        // Burada S1'e geçecek ve timer saymaya başlayacak
        
        // --- Senaryo 3: S2 Geçişi Beklemesi ---
        // S1'de 5 döngü bekleyip S2'ye (Kırmızı-Yeşil) geçmesini bekliyoruz
        #100; 

        // --- Senaryo 4: Trafik Tekrar A'ya Döner (TAORB = 1) ---
        TAORB = 1; 
        // S3'e geçecek ve yine 5 döngü sayıp S0'a dönecek
        
        #100;
        $display("Simulasyon Basariyla Tamamlandi.");
        $stop; // Simülasyonu durdur ve Wave ekranını incele
    end

endmodule