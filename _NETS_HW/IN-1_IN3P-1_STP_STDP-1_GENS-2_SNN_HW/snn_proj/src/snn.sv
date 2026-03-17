module snn #(
    parameter BIT_WIDTH = 32,
    parameter FRAC_BITS = 17
)(
    input  logic clk_i,
    input  logic rstn_i,
    output logic [7:0] leds_n0_o,
    output logic [7:0] leds_n1_o
);
    logic slow_clk;
    (* dont_touch = "true" *)  clk_divider #(
        .TRGET_FREQUENCY(1000000)  // 1 MHz 
        //.TRGET_FREQUENCY(10000000)  // 10 MHz
        //.TRGET_FREQUENCY(20000000)  // 20 MHz
        //.TRGET_FREQUENCY(25000000)  // 25 MHz
        //.TRGET_FREQUENCY(30000000)  // 30 MHz (Too much)
        //.TRGET_FREQUENCY(50000000)  // 50 MHz
    ) clk_div (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .slow_clk_o(slow_clk)
    );

    logic signed [BIT_WIDTH-1:0] signal_g0_n0, signal_g1_n1;
    logic spike_n0, spike_n1;
    
    (* dont_touch = "true" *) signal_generator_const #(
        .BIT_WIDTH(32),
        .FRAC_BITS(17),
        //.OUTPUT_SIGNAL_VALUE(32'h00140000)  // 10
        //.OUTPUT_SIGNAL_VALUE(32'h003c0000)  // 30
        //.OUTPUT_SIGNAL_VALUE(32'h00640000)  // 50
        //.OUTPUT_SIGNAL_VALUE(32'h00680000)  // 52 - SPIKES
        //.OUTPUT_SIGNAL_VALUE(32'h006e0000)  // 55
        //.OUTPUT_SIGNAL_VALUE(32'h00780000)  // 60
        //.OUTPUT_SIGNAL_VALUE(32'h008c0000)  // 70
        //.OUTPUT_SIGNAL_VALUE(32'h00c80000)  // 100
        .OUTPUT_SIGNAL_VALUE(32'h01900000)  // 200
    ) gen_c_n0 (
        .clk_i(slow_clk),
        .rstn_i(rstn_i),
        .signal_o(signal_g0_n0)
    );
    
    (* dont_touch = "true" *) signal_generator_const #(
        .BIT_WIDTH(32),
        .FRAC_BITS(17),
        //.OUTPUT_SIGNAL_VALUE(32'h00140000)  // 10
        //.OUTPUT_SIGNAL_VALUE(32'h003c0000)  // 30
        .OUTPUT_SIGNAL_VALUE(32'h00640000)  // 50
        //.OUTPUT_SIGNAL_VALUE(32'h00780000)  // 60
        //.OUTPUT_SIGNAL_VALUE(32'h008c0000)  // 70
        //.OUTPUT_SIGNAL_VALUE(32'h00c80000)  // 100
    ) gen_c_n1 (
        .clk_i(slow_clk),
        .rstn_i(rstn_i),
        .signal_o(signal_g1_n1)
    );

    (* dont_touch = "true" *) spikes_counter #(
        .LED_FIRST_IDX(0),
        .LED_LAST_IDX(7)
    ) spikes_counter_n0 (
        .clk_i(slow_clk),
        .rstn_i(rstn_i),
        .spike(spike_n0),
        .leds(leds_n0_o)
    );

    (* dont_touch = "true" *) spikes_counter #(
        .LED_FIRST_IDX(0),
        .LED_LAST_IDX(7)
    ) spikes_counter_n1 (
        .clk_i(slow_clk),
        .rstn_i(rstn_i),
        .spike(spike_n1),
        .leds(leds_n1_o)
    );

    (* dont_touch = "true" *) soma_izh #(
        .BIT_WIDTH(32),
        .FRAC_BITS(17)
    ) neuron_0 (
        .clk_i(slow_clk),
        .rstn_i(rstn_i),
        .signal_i(signal_g0_n0),
        .spike_o(spike_n0)
    );
    
    logic signed [BIT_WIDTH-1:0] signal_n1_i [2];
    assign signal_n1_i[0] = signal_g1_n1;
    (* dont_touch = "true" *) neuron_izh #(
        .PORTS_CNT(2),
        .BIT_WIDTH(32),
        .FRAC_BITS(17)
    ) neuron_1 (
        .clk_i(slow_clk),
        .rstn_i(rstn_i),
        .port_i(signal_n1_i),
        .spike_o(spike_n1)
    );
    
    (* dont_touch = "true" *) stp_stdp_synapse #(
        .SYN_BIT_WIDTH(32),
        .SYN_FRAC_BITS(17),
        .STP_BIT_WIDTH(32),
        .STP_FRAC_BITS(30),
        .STDP_BIT_WIDTH(32),
        .STDP_FRAC_BITS(20),
        .SCALING_FACTOR(32'h00280000) // 20 (Q15.17)
    ) synapse_n0_n1 (
        .clk_i(slow_clk),
        .rstn_i(rstn_i),
        .spike_pre_i(spike_n0),
        .spike_post_i(spike_n1),
        .signal_o(signal_n1_i[1])
    );    
    
endmodule
