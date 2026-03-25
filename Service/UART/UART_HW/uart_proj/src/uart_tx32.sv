module uart_tx32 (
    input  logic        clk_i,
    input  logic        rstn_i,
    input  logic [31:0] data32_i,
    input  logic        tx32_start_i,
    output logic        tx_o,
    output logic        tx32_busy_o
);
    logic [1:0] byte_idx;
    logic [7:0] data_byte;
    logic [31:0] data32_latched;

    logic tx8_start;
    logic tx8_busy;

    uart_tx8 uart8_inst (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .data8_i(data_byte),
        .tx8_start_i(tx8_start),
        .tx_o(tx_o),
        .tx8_busy_o(tx8_busy)
    );

    /*
     * FSM states:
     * IDLE           - No data tx. Swith to LOAD state at "tx32_start_i == 1" trigger arrive.
     * LOAD           - Load (prepare) next byte and trigger START state.
     * START          - Trigger "tx8_start = 1" and swith to WAIT_ACCEPT state.
     * WAIT_ACCEPT    - Wait until the uart_tx8 module confirms it has accepted request from START state, 
     *                  which is indicated by the signal busy going HIGH (wait tx8_busy == 1).
     * WAIT_DONE      - Wait until byte tx finishes (wait tx8_busy=0).
     *                  Then switch to LOAD state to obtain next byte (if current byte is not last).
     *                  Or switch to IDLE state (if current byte is last).
     */
    typedef enum logic [2:0] {
        IDLE,
        LOAD,
        START,
        WAIT_ACCEPT,
        WAIT_DONE
    } state_t;

    state_t state;

    // Finite State Machine
    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            state        <= IDLE;
            tx32_busy_o  <= 0;
            byte_idx     <= 0;
            data_byte    <= 0;
            tx8_start    <= 0;
        end else begin
            case (state)

                IDLE: begin
                    tx8_start <= 0;
                    if (tx32_start_i) begin
                        tx32_busy_o <= 1;
                        byte_idx <= 0;
                        data32_latched <= data32_i; // Latch input data
                        state <= LOAD;
                    end
                end

                LOAD: begin
                    case (byte_idx)
                        2'd0: data_byte <= data32_latched[7:0];
                        2'd1: data_byte <= data32_latched[15:8];
                        2'd2: data_byte <= data32_latched[23:16];
                        2'd3: data_byte <= data32_latched[31:24];
                    endcase
                    state <= START;
                end

                START: begin
                    tx8_start <= 1;
                    state     <= WAIT_ACCEPT;
                end

                WAIT_ACCEPT: begin
                    if (tx8_busy) begin
                        tx8_start <= 0; // release request
                        state <= WAIT_DONE;
                    end
                end

                WAIT_DONE: begin
                    if (!tx8_busy) begin
                        if (byte_idx == 2'd3) begin  // Last byte
                            tx32_busy_o <= 0;
                            state <= IDLE;
                        end else begin               // Intermediate bytes
                            byte_idx <= byte_idx + 1;
                            state <= LOAD;
                        end
                    end
                end

            endcase
        end
    end

endmodule