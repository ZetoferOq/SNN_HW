module uart_tx8 #(
    parameter CLK_FREQ = 100000000,
    parameter BAUD     = 115200
)(
    input  logic clk_i,
    input  logic rstn_i,
    input  logic [7:0] data8_i,
    input  logic tx8_start_i,
    output logic tx_o,
    output logic tx8_busy_o
);

    // Baud generator
    localparam integer BAUD_DIV = CLK_FREQ / BAUD;

    logic [15:0] baud_cnt = 0;
    logic baud_tick;

    always_ff @(posedge clk_i) begin
        if (baud_cnt == BAUD_DIV - 1) begin
            baud_cnt <= 0;
            baud_tick <= 1;
        end else begin
            baud_cnt <= baud_cnt + 1;
            baud_tick <= 0;
        end
    end

    // TX logic
    logic [3:0] bit_idx;
    logic [9:0] shift_reg = 10'b1111111111;

    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            tx_o <= 1;
            tx8_busy_o <= 0;
            bit_idx <= 0;
        end else begin
            if (tx8_start_i && !tx8_busy_o) begin
                // start + data + stop
                shift_reg <= {1'b1, data8_i, 1'b0};
                tx8_busy_o <= 1;
                bit_idx <= 0;
            end else if (tx8_busy_o && baud_tick) begin
                if (bit_idx == 9) begin
                    tx8_busy_o <= 0;
                    tx_o <= 1;
                end else begin
                    tx_o <= shift_reg[0];
                    shift_reg <= shift_reg >> 1;
                    bit_idx <= bit_idx + 1;
                end
            end
        end
    end

endmodule