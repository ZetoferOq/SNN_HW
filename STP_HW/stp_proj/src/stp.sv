module stp #(
    parameter BIT_WIDTH = 32,
    parameter FRAC_BITS = 30
)(
    input logic clk_i,
    input logic rstn_i,
    input  logic signed spike_i,
    output logic signed [BIT_WIDTH-1:0] nt_y_o
);
    import stp_pkg::*;
    
    fixed_point_arithmetic_if #(.BIT_WIDTH(BIT_WIDTH), .FRAC_BITS(FRAC_BITS)) fixp_if();
    
    logic signed [BIT_WIDTH-1:0] nt_x, nt_z, nt_q;
    logic clk_delay, prev_spike;
    
    logic signed [BIT_WIDTH-1:0] k1_nt_x, k2_nt_x, k3_nt_x;
    logic signed [BIT_WIDTH-1:0] k1_nt_y_o, k2_nt_y_o, k3_nt_y_o;
    logic signed [BIT_WIDTH-1:0] k1_nt_z, k2_nt_z, k3_nt_z;
    logic signed [BIT_WIDTH-1:0] k1_nt_q, k2_nt_q, k3_nt_q;
    
    /* (nt_y_o', nt_q') decay exp: arg' = arg * (-1/tau) */
    function automatic signed [BIT_WIDTH-1:0] f_exp(
        input signed [BIT_WIDTH-1:0] arg,
        input signed [BIT_WIDTH-1:0] tau
    );
        begin
            f_exp = fixp_if.mul(arg, tau);
        end
    endfunction
    
    /* nt_x' = nt_z * (1/tau_rec) */
    function automatic signed [BIT_WIDTH-1:0] f_x(
        input signed [BIT_WIDTH-1:0] nt_z_in,
        input signed [BIT_WIDTH-1:0] one_div_tau_rec
    );
        begin
            f_x = fixp_if.mul(nt_z_in, one_div_tau_rec);
        end
    endfunction
    
    /* nt_z' = nt_y_o * (1/tau_decay) - nt_z * (1/tau_rec) */
    function automatic signed [BIT_WIDTH-1:0] f_z(
        input signed [BIT_WIDTH-1:0] nt_y_o_in,
        input signed [BIT_WIDTH-1:0] nt_z_in,
        input signed [BIT_WIDTH-1:0] one_div_tau_decay,
        input signed [BIT_WIDTH-1:0] one_div_tau_rec
    );
        begin
            f_z = fixp_if.mul(nt_y_o_in, one_div_tau_decay) - fixp_if.mul(nt_z_in, one_div_tau_rec);
        end
    endfunction
    
    always_comb begin
        k1_nt_x = f_x(nt_z, ONE_DIV_TAU_REC);
        k1_nt_y_o = f_exp(nt_y_o, NEG_ONE_DIV_TAU_DECAY);
        k1_nt_z = f_z(nt_y_o, nt_z, ONE_DIV_TAU_DECAY, ONE_DIV_TAU_REC);
        k1_nt_q = f_exp(nt_q, NEG_ONE_DIV_TAU_FACIL);
        
        //?//k2_nt_x = nt_x + fixp_if.mul(DT, k1_nt_x);
        k2_nt_y_o = nt_y_o + fixp_if.mul(DT, k1_nt_y_o);
        k2_nt_z = nt_z + fixp_if.mul(DT, k1_nt_z);
        k2_nt_q = nt_q + fixp_if.mul(DT, k1_nt_q);
        
        // f_x() expects nt_z_in (Z input), but you're calling it with a k2_nt_x, which is an X - not correct.
        //?//k3_nt_x = k1_nt_x + f_x(k2_nt_x, ONE_DIV_TAU_REC);
        k3_nt_x = k1_nt_x + f_x(k2_nt_z, ONE_DIV_TAU_REC);
        k3_nt_y_o = k1_nt_y_o + f_exp(k2_nt_y_o, NEG_ONE_DIV_TAU_DECAY);
        k3_nt_z = k1_nt_z + f_z(nt_y_o, k2_nt_z, ONE_DIV_TAU_DECAY, ONE_DIV_TAU_REC);
        k3_nt_q = k1_nt_q + f_exp(k2_nt_q, NEG_ONE_DIV_TAU_FACIL);
    end
    
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (~rstn_i) begin
            nt_x <= INIT_NT_X;
            nt_y_o <= INIT_NT_Y;
            nt_z <= INIT_NT_Z;
            nt_q <= INIT_NT_Q;
            clk_delay <= 1'b0;
            prev_spike <= 1'b0;
        end else begin
            /* Keep for 2 clocks */            
            clk_delay <= spike_i;
            prev_spike <= clk_delay;
            
            if (prev_spike == 1'b1) begin                
                nt_x <= nt_x + fixp_if.mul(DT_DIV_2, k3_nt_x) - fixp_if.mul(nt_x,nt_q);
                nt_y_o <= nt_y_o + fixp_if.mul(DT_DIV_2, k3_nt_y_o) + fixp_if.mul(nt_x,nt_q);
            end else begin          
                nt_x <= nt_x + fixp_if.mul(DT_DIV_2, k3_nt_x);
                nt_y_o <= nt_y_o + fixp_if.mul(DT_DIV_2, k3_nt_y_o);
            end
            
            nt_z <= nt_z + fixp_if.mul(DT_DIV_2, k3_nt_z);
            
            if (spike_i == 1'b1)
                nt_q <= nt_q + fixp_if.mul(DT_DIV_2, k3_nt_q) + fixp_if.mul(ONE_DIV_2,(ONE-nt_q));
            else
                nt_q <= nt_q + fixp_if.mul(DT_DIV_2, k3_nt_q);
        end
    end

endmodule
