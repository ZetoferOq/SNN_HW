module stp_tb();
    logic clk;
    logic rstn;
    logic spike;
    logic [31:0] nt_y;
    
    stp #(
        .BIT_WIDTH(32),
        .FRAC_BITS(30)
    ) DUT (
        .clk_i(clk),
        .rstn_i(rstn),
        .spike_i(spike),
        .nt_y_o(nt_y)
    );
    
    initial clk = 0;
    always #0.5 clk = ~clk;
    
    initial begin
        rstn = 1'b0;
        spike = 1'b0;
        #10;
        rstn = 1'b1;
       
        for (int i = 0; i < 10; i++) begin
            spike = 1'b1;
            #1;  // Hold spike for 1 cycle
            spike = 1'b0;
            #100000;
        end
        
    end
endmodule
