/*
 * Integer clock divider with 50 % duty cycle.
 * Generates a square wave on slow_clk_o with frequency
 *       output frequency = BASE_FREQUENCY / (2 * HALF),
 *   where HALF = max(1, BASE_FREQUENCY / (2 * TARGET_FREQUENCY)) is the number
 *   of base clocks in one half-period of the output signal.
 *
 * FREQUENCY SELECTION RESTRICTIONS:
 *   1. The output frequency is exact only when BASE_FREQUENCY is divisible
 *      by (2 * TARGET_FREQUENCY) without a remainder. Otherwise you get the
 *      closest achievable frequency rather than the exact target value.
 *   2. TARGET_FREQUENCY must be > 0.
 *   3. TARGET_FREQUENCY cannot exceed BASE_FREQUENCY / 2.
 *      If it is greater, the divider silently sets HALF = 1 and outputs BASE_FREQUENCY / 2.
 *   4. COUNTER_BIT_WIDTH must satisfy the 2**COUNTER_BIT_WIDTH >= HALF.
 *      Otherwise the counter will prematurely and the output will never toggle.
 *
 * Notes
 *   1. slow_clk_o is a generated clock. On the FPGA it should be routed through a BUFG and
 *      constrained with create_generated_clock.
 *   2. After changing TARGET_FREQUNCY do not forget to fix '-divide_by' value for create_generated_clock
 *      in the .xdc file: new value = 2 * HALF
 */
module clk_divider #(
    parameter int TARGET_FREQUENCY  = 1_000_000,    // Hz
    parameter int BASE_FREQUENCY    = 100_000_000,  // Hz
    parameter int COUNTER_BIT_WIDTH = 32
)(
    input  logic clk_i,
    input  logic rstn_i,
    output logic slow_clk_o
);
    localparam int DIV_MAX = BASE_FREQUENCY / (TARGET_FREQUENCY * 2);
    localparam int HALF    = (DIV_MAX < 1) ? 1 : DIV_MAX;

    logic [COUNTER_BIT_WIDTH-1:0] counter;

    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (~rstn_i) begin
            counter    <= '0;
            slow_clk_o <= 1'b0;
        end else if (counter == HALF - 1) begin
            counter    <= '0;
            slow_clk_o <= ~slow_clk_o;
        end else begin
            counter    <= counter + 1'b1;
        end
    end

endmodule