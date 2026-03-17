interface fixed_point_arithmetic_if #(
    parameter int BIT_WIDTH = 32,
    parameter int FRAC_BITS = 20
)();

    /* Fixed-point multiply function */
    /*
    function automatic logic signed [BIT_WIDTH-1:0] mul (
    input logic signed [BIT_WIDTH-1:0] a,
    input logic signed [BIT_WIDTH-1:0] b
    );
        logic signed [2*BIT_WIDTH-1:0] product;
        begin
            product = a * b;
            mul = product >>> FRAC_BITS;
        end
    endfunction
    //*/
    
    ///*
    localparam logic signed [BIT_WIDTH-1:0] MAX_VAL = (1 <<< (BIT_WIDTH - 1)) - 1;
    localparam logic signed [BIT_WIDTH-1:0] MIN_VAL = -(1 <<< (BIT_WIDTH - 1));

    // Fixed-point multiply with rounding and saturation
    function automatic logic signed [BIT_WIDTH-1:0] mul (
        input logic signed [BIT_WIDTH-1:0] a,
        input logic signed [BIT_WIDTH-1:0] b
    );
        // Intermediate product has double width
        logic signed [(2*BIT_WIDTH)-1:0] full_product;
        logic signed [(2*BIT_WIDTH)-1:0] rounded_product;
        logic signed [BIT_WIDTH:0]       shifted_result;

        // Constants for rounding and shifting
        localparam logic signed [(2*BIT_WIDTH)-1:0] ROUNDING_BIAS = (1 <<< (FRAC_BITS - 1));

        begin
            // Multiply inputs
            full_product = a * b;

            // Add rounding bias
            rounded_product = full_product + ROUNDING_BIAS;

            // Shift down to align fractional bits
            shifted_result = rounded_product >>> FRAC_BITS;

            // Saturate the result to fit within BIT_WIDTH
            if (shifted_result > MAX_VAL)
                mul = MAX_VAL;
            else if (shifted_result < MIN_VAL)
                mul = MIN_VAL;
            else
                mul = shifted_result[BIT_WIDTH-1:0];
        end
    endfunction
    //*/
    
    function automatic logic signed [BIT_WIDTH-1:0] sum (
        input logic signed [BIT_WIDTH-1:0] a,
        input logic signed [BIT_WIDTH-1:0] b
    );
        logic signed [BIT_WIDTH:0] extended_sum;
        
        begin
            extended_sum = a + b;
            // Optional rounding: add 1 LSB if sum is positive and LSB of extended_sum is 1 (round half up)
            extended_sum = extended_sum + (extended_sum[0] & ~extended_sum[BIT_WIDTH]);
            
            // If sign of a == sign of b but sign of sum != sign of a, overflow occurred
            if ((a[BIT_WIDTH-1] == b[BIT_WIDTH-1]) && (extended_sum[BIT_WIDTH] != a[BIT_WIDTH-1])) begin
                // Saturate to max or min depending on sign
                if (a[BIT_WIDTH-1] == 1'b0)
                    sum = MAX_VAL; // positive overflow
                else
                    sum = MIN_VAL; // negative overflow
            end else begin
                // No overflow, just assign lower bits
                sum = extended_sum[BIT_WIDTH-1:0];
            end
        end
    endfunction

    function automatic logic signed [BIT_WIDTH-1:0] diff (
        input logic signed [BIT_WIDTH-1:0] a,
        input logic signed [BIT_WIDTH-1:0] b
    );
        logic signed [BIT_WIDTH-1:0] neg_b;
        logic signed [BIT_WIDTH:0] extended_diff;
        
        begin
            neg_b = -b;
            extended_diff = a + neg_b;
            
            // If sign of a == sign of b but sign of sum != sign of a, overflow occurred
            if ((a[BIT_WIDTH-1] == neg_b[BIT_WIDTH-1]) && (extended_diff[BIT_WIDTH] != a[BIT_WIDTH-1])) begin
                // Saturate to max or min depending on sign
                if (a[BIT_WIDTH-1] == 1'b0)
                    diff = MAX_VAL; // positive overflow
                else
                    diff = MIN_VAL; // negative overflow
            end else begin
                // No overflow, just assign lower bits
                 diff = extended_diff[BIT_WIDTH-1:0];
            end
        end
    endfunction
    
endinterface