module stdp #(
    parameter BIT_WIDTH = 32,
    parameter FRAC_BITS = 20
)(
    input logic clk_i,
    input logic rstn_i,
    input  logic signed spike_pre_i,
    input  logic signed spike_post_i,
    output logic signed [BIT_WIDTH-1:0] weight_o
);
    import stdp_pkg::*;

    fixed_point_arithmetic_if #(.BIT_WIDTH(BIT_WIDTH), .FRAC_BITS(FRAC_BITS)) fixp_if();

    logic signed [BIT_WIDTH-1:0] trace_pre, trace_post;

    logic signed [BIT_WIDTH-1:0] k1_trace_pre, k2_trace_pre, k3_trace_pre;
    logic signed [BIT_WIDTH-1:0] k1_trace_post, k2_trace_post, k3_trace_post;
    logic signed [BIT_WIDTH-1:0] trace_pre_contrib, trace_post_contrib; 

    /* decay exp: arg' = arg * (-1/tau) */
    function automatic signed [BIT_WIDTH-1:0] f_exp(
        input signed [BIT_WIDTH-1:0] arg,
        input signed [BIT_WIDTH-1:0] one_div_tau
    );
        begin
            f_exp = fixp_if.mul(arg, one_div_tau);
        end
    endfunction

    always_comb begin
        k1_trace_pre = f_exp(trace_pre, NEG_ONE_DIV_TAU_DECAY_PRE);
        k1_trace_post = f_exp(trace_post, NEG_ONE_DIV_TAU_DECAY_POST);
        
        k2_trace_pre = trace_pre + fixp_if.mul(DT, k1_trace_pre);
        k2_trace_post = trace_post + fixp_if.mul(DT, k1_trace_post);
        
        k3_trace_pre = k1_trace_pre + f_exp(k2_trace_pre, NEG_ONE_DIV_TAU_DECAY_PRE);
        k3_trace_post = k1_trace_post + f_exp(k2_trace_post, NEG_ONE_DIV_TAU_DECAY_POST);
        
        if (spike_post_i == 1'b1)
            trace_pre_contrib = fixp_if.mul(fixp_if.mul(LEARNING_RATE,(ONE - weight_o)),trace_pre);
        else
            trace_pre_contrib = '0;
        
        if (spike_pre_i == 1'b1)
            trace_post_contrib = fixp_if.mul(fixp_if.mul(fixp_if.mul(LEARNING_RATE,ASYMMETRY),weight_o),trace_post);
        else
            trace_post_contrib = '0;
    end

    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (~rstn_i) begin
            trace_pre <= INIT_TRACE_PRE;
            trace_post <= INIT_TRACE_POST;
            weight_o <= INIT_WEIGHT;
        end else begin
            trace_pre <= trace_pre + fixp_if.mul(DT_DIV_2, k3_trace_pre) + (spike_pre_i ? DELTA_FUNC_AMPLITUDE : '0);
            trace_post <= trace_post + fixp_if.mul(DT_DIV_2, k3_trace_post) + (spike_post_i ? DELTA_FUNC_AMPLITUDE : '0);
            weight_o <= weight_o + trace_pre_contrib - trace_post_contrib;
        end
    end
    
endmodule