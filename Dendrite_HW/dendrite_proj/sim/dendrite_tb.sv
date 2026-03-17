/* 24-bit (Q12.12) */

module dendrite_tb();
    logic signed [23:0] signals [3];
    logic signed [23:0] sum_signal;
    
    dendrite #(
        .PORTS_CNT(3),
        .BIT_WIDTH(24),
        .FRAC_BITS(12)
    ) DUT (
        .port_i(signals),
        .port_o(sum_signal)
    );
    
    initial begin
        signals[0] = 24'h002800;  // 2.5
        signals[1] = 24'h0014CD;  // 1.3
        signals[2] = 24'h00519A;  // 5.1
        // sum = 8.9 = 24'h008E66 (24'h008E67)
        #10;
        $display("\nCASE: 2.5 + 1.3 + 5.1 = 8.9");
        $display("0x002800 + 0x0014CD + 0x00519A = 0x%h", sum_signal);
        if ((sum_signal == 24'h008E66) || (sum_signal == 24'h008E67))
            $display("CASE PASSED");
        else
            $display("CASE FAILED (expect: 0x008E66)");
        #10;
        
        signals[0] = 24'h041800;  // 65.5
        signals[1] = 24'hFE2000;  // -30
        signals[2] = 24'hFFE800;  // -1.5
        // sum = 34 = 24'h022000
        #10;
        $display("\nCASE: 65.5 - 30 - 1.5 = 34");
        $display("0x002800 + 0x0014CD + 0x00519A = 0x%h", sum_signal);
        if (sum_signal == 24'h022000)
            $display("CASE PASSED");
        else
            $display("CASE FAILED (expect: 0x022000)");
        #10;
        
        signals[0] = 24'h005333;  // 5.2
        signals[1] = 24'hFF6000;  // -10
        signals[2] = 24'h001333;  // 1.2
        // sum = -3.6 = 24'hFFC666
        #10;
        $display("\nCASE: 5.2 - 10 + 1.2 = -3.6");
        $display("0x005333 + 0xFF6000 + 0x001333 = 0x%h", sum_signal);
        if (sum_signal == 24'hFFC666)
            $display("CASE PASSED");
        else
            $display("CASE FAILED (expect: 0xFFC666)");
        #10;
        
        signals[0] = 24'h7D0000;  // 2000
        signals[1] = 24'h032000;  // 50
        signals[2] = 24'h002000;  // 2
        // sum = 2052 = 24'h7FFFFF (saturation (max = 2047.999755859375))
        #10;
        $display("\nCASE: 2000 + 5 + 2 = 2047.999755859375 (2052)");
        $display("0x7D0000 + 0x032000 + 0x002000 = 0x%h", sum_signal);
        if (sum_signal == 24'h7FFFFF)
            $display("CASE PASSED");
        else
            $display("CASE FAILED (expect: 0x7FFFFF)");
        #10;
        
        signals[0] = 24'h000000;  // 0
        signals[1] = 24'h830000;  // -2000
        signals[2] = 24'hF9C000;  // -100
        // sum = -2100 = 24'h800000 (saturation (min = -2048))
        #10;
        $display("\nCASE: 0 - 2000 - 100 = -2048 (-2100)");
        $display("0x000000 + 0x830000 + 0xF9C000 = 0x%h", sum_signal);
        if (sum_signal == 24'h800000)
            $display("CASE PASSED");
        else
            $display("CASE FAILED (expect: 0x800000)");
        #10;
    end
endmodule
