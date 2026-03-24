`timescale 1ns/1ps

module top_example_tb;

    // DUT signals
    logic clk;
    logic rstn;
    logic RsTx;

    top_example dut (
        .clk_i (clk),
        .rstn_i(rstn),
        .RsTx  (RsTx)
    );

    // Clock: 100 MHz
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset
    initial begin
        rstn = 0;
        #100;
        rstn = 1;
    end

    // UART parameters (must match DUT)
    localparam CLK_FREQ = 100_000_000;
    localparam BAUD     = 115200;
    localparam BAUD_DIV = CLK_FREQ / BAUD;

    // Testbench UART RX logic
    typedef enum logic [1:0] {
        RX_IDLE,
        RX_START,
        RX_DATA,
        RX_STOP
    } rx_state_t;

    rx_state_t state;

    logic [15:0] baud_cnt;
    logic [3:0]  bit_idx;
    logic [7:0]  rx_byte;

    always_ff @(posedge clk) begin
        if (!rstn) begin
            state    <= RX_IDLE;
            baud_cnt <= 0;
            bit_idx  <= 0;
            rx_byte  <= 0;
        end else begin
            case (state)

                RX_IDLE: begin
                    if (RsTx == 0) begin
                        baud_cnt <= BAUD_DIV/2;
                        state <= RX_START;
                    end
                end

                RX_START: begin
                    if (baud_cnt == 0) begin
                        baud_cnt <= BAUD_DIV - 1;
                        bit_idx  <= 0;
                        state    <= RX_DATA;
                    end else begin
                        baud_cnt <= baud_cnt - 1;
                    end
                end

                RX_DATA: begin
                    if (baud_cnt == 0) begin
                        rx_byte <= {RsTx, rx_byte[7:1]}; // LSB first
                        baud_cnt <= BAUD_DIV - 1;

                        if (bit_idx == 7) begin
                            state <= RX_STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt - 1;
                    end
                end

                RX_STOP: begin
                    if (baud_cnt == 0) begin
                        $display("[%0t] RX BYTE = 0x%02h", $time, rx_byte);
                        state <= RX_IDLE;
                    end else begin
                        baud_cnt <= baud_cnt - 1;
                    end
                end

            endcase
        end
    end

endmodule