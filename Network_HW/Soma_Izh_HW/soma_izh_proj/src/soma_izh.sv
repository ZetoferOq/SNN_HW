module soma_izh #(
    parameter BIT_WIDTH = 32,
    parameter FRAC_BITS = 17
)(
    input  logic clk_i,
    input  logic rstn_i,
    input  logic signed [BIT_WIDTH-1:0] signal_i,
    output logic spike_o
);
    import soma_izh_pkg::*;
    
    fixed_point_arithmetic_if #(.BIT_WIDTH(BIT_WIDTH), .FRAC_BITS(FRAC_BITS)) fixp_if();
     
    logic signed [BIT_WIDTH-1:0] v, u;
    
    logic signed [BIT_WIDTH-1:0] k1_v, k2_v, k3_v;
    logic signed [BIT_WIDTH-1:0] k1_u, k2_u, k3_u;
    
    /* v' = (K * (v - VR) * (v - VT) - u + signal_i) * (1/C) */
    function automatic signed [BIT_WIDTH-1:0] f_v(
        input signed [BIT_WIDTH-1:0] v_in,
        input signed [BIT_WIDTH-1:0] u_in,
        input signed [BIT_WIDTH-1:0] signal_in
    );
        begin
            f_v = fixp_if.mul((fixp_if.mul((v_in - VR), fixp_if.mul(K, (v_in - VT))) - u_in + signal_in), ONE_DIV_C);
        end
    endfunction
    
    /* u' = A * (B * (v - VR) - u) */
    function automatic signed [BIT_WIDTH-1:0] f_u(
        input signed [BIT_WIDTH-1:0] v_in,
        input signed [BIT_WIDTH-1:0] u_in
    );
        begin
            f_u = fixp_if.mul(A, (fixp_if.mul(B, (v_in - VR)) - u_in));
        end
    endfunction
    
    always_comb begin
        k1_v = f_v(v, u, signal_i);
        k1_u = f_u(v, u);
        
        k2_v = v + fixp_if.mul(DT, k1_v);
        k2_u = u + fixp_if.mul(DT, k1_u);
        
        k3_v = k1_v + f_v(k2_v, u, signal_i);
        k3_u = k1_u + f_u(v, k2_u);
    end
    
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (~rstn_i) begin
            v <= VR;
            u <= INIT_U;
            spike_o <= 1'b0;
        end else begin
            if (v >= V_PEAK) begin
                spike_o <= 1'b1;
                v <= V_RESET;
                u <= u + D;
            end else begin
                spike_o <= 1'b0;
                /*
                 * No need to use v_next and u_next, because non-blocking assignments are used, 
                 * which ensure that the old (previous value) is used
                 */
                //v <= v + fixp_if.mul(DT_DIV_2, ((fixp_if.mul((fixp_if.mul(K, (fixp_if.mul((v - VR), (v - VT)))) - u + signal_i), ONE_DIV_C)) + (fixp_if.mul((fixp_if.mul(K, (fixp_if.mul(((v + fixp_if.mul(DT, (fixp_if.mul((fixp_if.mul(K, (fixp_if.mul((v - VR), (v - VT)))) - u + signal_i), ONE_DIV_C)))) - VR), ((v + fixp_if.mul(DT, (fixp_if.mul((fixp_if.mul(K, (fixp_if.mul((v - VR), (v - VT)))) - u + signal_i), ONE_DIV_C)))) - VT)))) - u + signal_i), ONE_DIV_C))));
                //u <= u + fixp_if.mul(DT_DIV_2, ((fixp_if.mul(A, (fixp_if.mul(B, (v - VR)) - u)))+(fixp_if.mul(A, (fixp_if.mul(B, (v - VR)) - (u + fixp_if.mul(DT, fixp_if.mul(A, (fixp_if.mul(B, (v - VR)) - u)))))))));
                v <= v + fixp_if.mul(DT_DIV_2, k3_v);
                u <= u + fixp_if.mul(DT_DIV_2, k3_u);
            end
        end
    end

endmodule
