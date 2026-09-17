module stp_stdp_synapse #(
    parameter SYN_BIT_WIDTH = 32,
    parameter SYN_FRAC_BITS = 20,
    parameter STP_BIT_WIDTH = 32,
    parameter STP_FRAC_BITS = 30,
    parameter STDP_BIT_WIDTH = 32,
    parameter STDP_FRAC_BITS = 20,
    parameter SCALING_FACTOR = 20
)(
    input  logic clk_i,
    input  logic rstn_i,
    input  logic signed spike_pre_i,
    input  logic signed spike_post_i,
    output logic signed [SYN_BIT_WIDTH-1:0] signal_o
);
    fixed_point_arithmetic_if #(.BIT_WIDTH(SYN_BIT_WIDTH), .FRAC_BITS(SYN_FRAC_BITS)) fixp_if();
    
    logic signed [STP_BIT_WIDTH-1:0] nt_y;
    logic signed [STDP_BIT_WIDTH-1:0] weight;
    logic signed [SYN_BIT_WIDTH-1:0] conv_nt_y, conv_weight;
    
    stp #(
        .BIT_WIDTH(STP_BIT_WIDTH),
        .FRAC_BITS(STP_FRAC_BITS)
    ) stp (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .spike_i(spike_pre_i),
        .nt_y_o(nt_y)
    );
    
    stdp #(
        .BIT_WIDTH(STDP_BIT_WIDTH),
        .FRAC_BITS(STDP_FRAC_BITS)
    ) stdp (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .spike_pre_i(spike_pre_i),
        .spike_post_i(spike_post_i),
        .weight_o(weight)
    );

    always_comb begin
        if (SYN_FRAC_BITS > STP_FRAC_BITS)
            conv_nt_y = nt_y <<< (SYN_FRAC_BITS - STP_FRAC_BITS);
        else if (SYN_FRAC_BITS < STP_FRAC_BITS)
            conv_nt_y = nt_y >>> (STP_FRAC_BITS - SYN_FRAC_BITS);
        else /* SYN_FRAC_BITS == STP_FRAC_BITS */
            conv_nt_y = nt_y;
            
        if (SYN_FRAC_BITS > STDP_FRAC_BITS)
            conv_weight = weight <<< (SYN_FRAC_BITS - STDP_FRAC_BITS);
        else if (SYN_FRAC_BITS < STDP_FRAC_BITS)
            conv_weight = weight >>> (STDP_FRAC_BITS - SYN_FRAC_BITS);
        else /* SYN_FRAC_BITS == STDP_FRAC_BITS */
            conv_weight = weight;
         
        signal_o = fixp_if.mul(fixp_if.mul(conv_nt_y,conv_weight),SCALING_FACTOR);
    end
    
endmodule
