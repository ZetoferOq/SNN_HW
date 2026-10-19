# clock_divider

Integer clock divider with 50 % duty cycle.
Generates a square wave on slow_clk_o with frequency `output frequency = BASE_FREQUENCY / (2 * HALF)`
where `HALF = max(1, BASE_FREQUENCY / (2 * TARGET_FREQUENCY))` is the number of base clocks in one half-period of the output signal.

## FREQUENCY SELECTION RESTRICTIONS:

1. The output frequency is exact only when `BASE_FREQUENCY` is divisible by `(2 * TARGET_FREQUENCY)` without a remainder. Otherwise you get the closest achievable frequency rather than the exact target value;
2. `TARGET_FREQUENCY` must be > 0.
3. `TARGET_FREQUENCY` cannot exceed `BASE_FREQUENCY / 2`. If it is greater, the divider silently sets `HALF = 1` and outputs `BASE_FREQUENCY / 2`;
4. `COUNTER_BIT_WIDTH` must satisfy the `2**COUNTER_BIT_WIDTH >= HALF`. Otherwise the counter will prematurely and the output will never toggle.

## Notes

1. `slow_clk_o` is a generated clock. On the FPGA it should be routed through a `BUFG` and constrained with create_generated_clock;
2. After changing `TARGET_FREQUNCY` do not forget to fix `-divide_by` value for `create_generated_clock` in the .xdc file: `new value = 2 * HALF`.

## Example of usage

Design fiile:
```
    logic slow_clk_raw;
    logic slow_clk;
    (* dont_touch = "true" *)  clk_divider #(
        .TARGET_FREQUENCY(1000000)  // 1 MHz
    ) clk_div (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .slow_clk_o(slow_clk_raw)
    );
    
    BUFG u_bufg_slow_clk (
        .I (slow_clk_raw),
        .O (slow_clk)
    );

    // NOW slow_clk CAN BE USED
```

.xdc file:

```
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports clk_i]
create_clock -period 100.000 -name clk_i -waveform {0.000 50.000} -add [get_ports clk_i]
create_generated_clock -name slow_clk -source [get_ports clk_i] -divide_by 100 [get_pins u_bufg_slow_clk/O]
```