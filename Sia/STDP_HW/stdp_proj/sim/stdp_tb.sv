module stdp_tb();
    logic clk;
    logic rstn;
    logic spike_pre;
    logic spike_post;
    logic [31:0] weight;
    
    stdp #(
        .BIT_WIDTH(32),
        .FRAC_BITS(20)
    ) DUT (
        .clk_i(clk),
        .rstn_i(rstn),
        .spike_pre_i(spike_pre),
        .spike_post_i(spike_post),
        .weight_o(weight)
    );
    
    initial clk = 0;
    always #0.5 clk = ~clk;
    
    initial begin
        rstn = 1'b0;
        spike_pre = 1'b0;
        spike_post = 1'b0;
        #10;
        rstn = 1'b1;
        
        /* Increase weight */
        for (int i = 0; i < 10; i++) begin
            spike_pre = 1'b1;
            #1;  // Hold spike for 1 cycle
            spike_pre = 1'b0;
            #20000;
            spike_post = 1'b1;
            #1;  // Hold spike for 1 cycle
            spike_post = 1'b0;
            #100000;
        end

        #500000;

        /* Decrease weight */
        for (int i = 0; i < 10; i++) begin
            spike_post = 1'b1;
            #1;  // Hold spike for 1 cycle
            spike_post = 1'b0;
            #20000;
            spike_pre = 1'b1;
            #1;  // Hold spike for 1 cycle
            spike_pre = 1'b0;
            #100000;
        end
    end
endmodule
