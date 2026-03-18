module spikes_counter #(
    parameter LED_FIRST_IDX,
    parameter LED_LAST_IDX,
    parameter COUNTER_BIT_WIDTH = 32
)(
    input logic  clk_i,
    input logic  rstn_i,
    input logic  spike,
    output logic [LED_FIRST_IDX:LED_LAST_IDX] leds
);
    import spikes_counter_pkg::*;
    
    logic [COUNTER_BIT_WIDTH-1:0] counter;
    logic [$clog2(LED_LAST_IDX-LED_FIRST_IDX+1):0] led_index; 
    
    logic [LED_LAST_IDX:LED_FIRST_IDX] leds_signal;
    
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (~rstn_i) begin
            counter <= '0;
            led_index <= '0;
            leds_signal <= '0;
            leds <= '0;
        end else begin
            if (spike == 1'b1)
                counter <= counter + 1;
            else
                counter <= counter;
            
            // Move led every NSPIKES
            if (counter == NSPIKES) begin
                if (led_index == LED_LAST_IDX) begin
                    led_index <= 0;
                end else begin
                    led_index <= led_index + 1;
                end
                counter <= '0;
                leds_signal <= 1'b1 << led_index;
            end else begin
                leds <= leds_signal;
            end
        end 
    end

endmodule