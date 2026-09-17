/* 24-bit (Q12.12) */

module neuron_izh_tb();
    logic clk;
    logic rstn;
    logic signed [23:0] signals [3];
    logic spike;

    neuron_izh #(
        .PORTS_CNT(3),
        .BIT_WIDTH(32),
        .FRAC_BITS(12)
    ) DUT (
        .clk_i(clk),
        .rstn_i(rstn),
        .port_i(signals),
        .spike_o(spike)
    );

    initial clk = 0;
    always #5 clk = ~clk;
    
    /*
     * SIGNALS:
     * [30 = 24'h01E000; 20 = 24'h014000; 50 = 24'h032000]
     * [40 = 24'h028000; -10 = 24'hFF6000; 50 = 24'h032000]
     */
    initial begin
        rstn = 1'b0;
        signals[0] = 24'h01E000;
        signals[1] = 24'h014000;
        signals[2] = 24'h032000;
        #10;
        rstn = 1'b1;
    end

endmodule
