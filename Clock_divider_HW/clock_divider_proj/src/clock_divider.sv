module clk_divider #(
    parameter TRGET_FREQUENCY = 1000000,  // Target clock in Hz
    parameter BASE_FREQUENCY = 100000000,  // Base clock in Hz (100 MHz)
    parameter COUNTER_BIT_WIDTH = 32
)(
    input logic clk_i,
    input logic rstn_i,
    output logic slow_clk_o
);
    localparam DIVIDER =  BASE_FREQUENCY / (TRGET_FREQUENCY * 2);
    logic [COUNTER_BIT_WIDTH-1:0] counter;

    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (~rstn_i) begin
            counter <= 0;
            slow_clk_o <= 0;
        end else if (counter == DIVIDER) begin
            counter <= 0;
            slow_clk_o <= ~slow_clk_o;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule