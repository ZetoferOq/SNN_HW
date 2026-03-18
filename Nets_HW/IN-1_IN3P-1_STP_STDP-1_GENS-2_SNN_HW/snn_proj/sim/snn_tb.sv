module snn_tb();
    logic clk;
    logic rstn;
    logic [7:0] leds_n0;
    logic [7:0] leds_n1;
    
    snn #(
        .BIT_WIDTH(32),
        .FRAC_BITS(17)
    ) DUT (
        .clk_i(clk),
        .rstn_i(rstn),
        .leds_n0_o(leds_n0),
        .leds_n1_o(leds_n1)
    );

    initial clk = 0;
    always #0.5 clk = ~clk;
    
    initial begin
        rstn = 1'b0;
        #100
        rstn = 1'b1;
    end
endmodule