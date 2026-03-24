module soma_tb #(
    parameter BIT_WIDTH = 32,
    parameter FRAC_BITS = 17
)();
    logic clk;
    logic rstn;
    logic [BIT_WIDTH-1:0] signal;
    logic spike;

    soma_izh #(
        .BIT_WIDTH(BIT_WIDTH),
        .FRAC_BITS(FRAC_BITS)
    ) DUT (
        .clk_i(clk),
        .rstn_i(rstn),
        .signal_i(signal),
        .spike_o(spike)
    );

    initial clk = 0;
    always #0.5 clk = ~clk;
    
    //initial signal = 32'h00640000;  // 50
    //initial signal = 32'h00780000;  // 60
    //initial signal = 32'h008c0000;  // 70
    //initial signal = 32'h00a00000;  // 80
    initial signal = 32'h00c80000;  // 100
    
    initial begin
        rstn = 1'b0;
        #1;
        rstn = 1'b1;
    end

endmodule
