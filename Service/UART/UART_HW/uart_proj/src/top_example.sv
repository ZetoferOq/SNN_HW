module top_example (
    input  logic clk_i,
    input  logic rstn_i,
    output logic RsTx
);
    logic [31:0] tx_data;
    logic tx_start;
    logic tx_busy;

    logic [31:0] counter;

/*
    // 8bit tx example
    logic [7:0] tx_data;

    uart_tx8 uart_inst (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .data8_i(tx_data),
        .tx8_start_i(tx_start),
        .tx_o(RsTx),
        .tx8_busy_o(tx_busy)
    );

    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            tx_data <= 8'h0;
            tx_start <= 0;
            counter <= 0;
        end else begin
            if (counter == 32'd500_000 && !tx_busy) begin
                tx_data  <=8'hFF;
                tx_start <= 1;
            end else begin
                tx_start <= 0;
            end

            if (counter == 32'd100_000_000) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end
*/

    uart_tx32 uart_inst (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .data32_i(tx_data),
        .tx32_start_i(tx_start),
        .tx_o(RsTx),
        .tx32_busy_o(tx_busy)
    );


    assign is_multiple = (counter % 1000000 == 0);
   
    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            tx_data <= 32'h0;
            tx_start <= 0;
            counter <= 0;
        end else begin
            // Fixed value
            if (counter == 32'd500_000 && !tx_busy) begin
                tx_data <= 32'hDEADBEFF;
                tx_start <= 1;
            end else begin
                tx_data <= 32'h0;
                tx_start <= 0;
            end
            
            /*
            // Counter dynamic value
            if (is_multiple) begin
                tx_data <= counter;
                tx_start <= 1;
            end else begin
                tx_data <= 32'h0;
                tx_start <= 0;
            end
            */

            if (counter == 32'd100_000_000) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule