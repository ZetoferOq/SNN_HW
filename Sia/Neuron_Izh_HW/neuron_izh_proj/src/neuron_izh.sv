module neuron_izh #(
    parameter PORTS_CNT = 3,
    parameter BIT_WIDTH = 24,
    parameter FRAC_BITS = 12
)(
    input  logic clk_i,
    input  logic rstn_i,
    input  logic signed [BIT_WIDTH-1:0] port_i [PORTS_CNT],
    output logic spike_o
);
    logic signed [BIT_WIDTH-1:0] conn_signal;

    dendrite #(
        .PORTS_CNT(PORTS_CNT),
        .BIT_WIDTH(BIT_WIDTH),
        .FRAC_BITS(FRAC_BITS)
    ) dendrite (
        .port_i(port_i),
        .port_o(conn_signal)
    );

    soma_izh #(
        .BIT_WIDTH(BIT_WIDTH),
        .FRAC_BITS(FRAC_BITS)
    ) soma (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .signal_i(conn_signal),
        .spike_o(spike_o)
    );

endmodule

