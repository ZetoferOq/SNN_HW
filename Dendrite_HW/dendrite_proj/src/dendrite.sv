module dendrite #(
    parameter PORTS_CNT = 3,
    parameter BIT_WIDTH = 24,
    parameter FRAC_BITS = 12
)(
    input  logic signed [BIT_WIDTH-1:0] port_i [PORTS_CNT],
    output logic signed [BIT_WIDTH-1:0] port_o
);
    localparam signed [BIT_WIDTH-1:0] MAX_VAL = (1 << (BIT_WIDTH-1)) - 1;
    localparam signed [BIT_WIDTH-1:0] MIN_VAL = - (1 << (BIT_WIDTH-1));
    
    /* To avoid losing bits during addition, sum into a wider signed variable */
    logic signed [BIT_WIDTH+$clog2(PORTS_CNT)-1:0] sum;
    
    always_comb begin
        sum = '0;
        for (int i = 0; i < PORTS_CNT; i++) begin
            sum += port_i[i];
        end
    end
    
    /* If sum exceeds valid range, saturate to max/min */
    assign port_o = (sum > MAX_VAL) ? MAX_VAL[BIT_WIDTH-1:0] : (sum < MIN_VAL) ? MIN_VAL[BIT_WIDTH-1:0] : sum[BIT_WIDTH-1:0];
    
endmodule