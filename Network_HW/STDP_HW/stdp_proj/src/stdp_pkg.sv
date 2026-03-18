package stdp_pkg;

/* A_DIV_B: Avoid division by specifying the resulting value in advance */

/* Q12.12 - NOT ENOUGH ACCURACY */
/*
localparam signed DT                         = 24'h000004;  // 0.0009765625 (0.001)
localparam signed DT_DIV_2                   = 24'h000002;  // 0.00048828125 (0.0005) (dt/2)
localparam signed INIT_WEIGHT                = 24'h00099A;  // 0.60009765625 (0.6)
localparam signed INIT_TRACE_PRE             = 24'h000000;  // 0
localparam signed INIT_TRACE_POST            = 24'h000000;  // 0
localparam signed DELTA_FUNC_AMPLITUDE       = 24'h001000;  // 1
localparam signed ONE                        = 24'h001000;  // 1
//NYI//localparam signed TAU_DELAY                  = 24'h000000;  // 0 (0 cycles)
localparam signed LEARNING_RATE              = 24'h000029;  // 0.010009765625 (0.01)
localparam signed ASYMMETRY                  = 24'h001000;  // 1
localparam signed NEG_ONE_DIV_TAU_DECAY_PRE  = 24'hFFFE66;  // (-0.1) (-1/tau_decay_pre (10ms))
localparam signed NEG_ONE_DIV_TAU_DECAY_POST = 24'hFFFE66;  // (-0.1) (-1/tau_decay_post (10ms))
//*/
/* END Q12.12 */

/* Q12.20 */
///*
localparam signed DT                         = 32'h00000419;  // 0.001
localparam signed DT_DIV_2                   = 32'h0000020C;  // 0.0005 (dt/2)
localparam signed INIT_WEIGHT                = 32'h0009999A;  // 0.6
localparam signed INIT_TRACE_PRE             = 32'h00000000;  // 0
localparam signed INIT_TRACE_POST            = 32'h00000000;  // 0
localparam signed DELTA_FUNC_AMPLITUDE       = 32'h00100000;  // 1
localparam signed ONE                        = 32'h00100000;  // 1
//NYI//localparam signed TAU_DELAY                  = 32'h00000000;  // 0
localparam signed LEARNING_RATE              = 32'h000028F6;  // 0.01
localparam signed ASYMMETRY                  = 32'h00100000;  // 1
localparam signed NEG_ONE_DIV_TAU_DECAY_PRE  = 32'hFFFE6666;  // -0.1 (-1/tau_decay_pre (10ms))
localparam signed NEG_ONE_DIV_TAU_DECAY_POST = 32'hFFFE6666;  // -0.1 (-1/tau_decay_post (10ms))
//*/
/* END Q12.20 */

endpackage