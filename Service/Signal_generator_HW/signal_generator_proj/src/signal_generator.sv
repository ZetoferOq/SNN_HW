module signal_generator_const #(
    parameter BIT_WIDTH = 32,
    parameter FRAC_BITS = 17,
    parameter OUTPUT_SIGNAL_VALUE
)(
    input logic clk_i,
    input logic rstn_i,
    output logic [BIT_WIDTH-1:0] signal_o
);
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (~rstn_i) begin
            signal_o <= '0;
        end else begin
            signal_o <= OUTPUT_SIGNAL_VALUE;
        end
    end
endmodule