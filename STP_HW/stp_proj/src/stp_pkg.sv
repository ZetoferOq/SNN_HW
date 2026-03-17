package stp_pkg;

/* A_DIV_B: Avoid division by specifying the resulting value in advance */

/* Q12.12 - NOT ENOUGH ACCURACY FOR ALL NTs */
/*
localparam signed DT                    = 24'h000004;  // 0.0009765625 (0.001)
localparam signed DT_DIV_2              = 24'h000002;  // 0.00048828125 (0.0005) (dt/2)
localparam signed INIT_NT_X             = 24'h001000;  // 1
localparam signed INIT_NT_Y             = 24'h000000;  // 0
localparam signed INIT_NT_Z             = 24'h000000;  // 0
localparam signed INIT_NT_Q             = 24'h000000;  // 0
localparam signed DELTA_FUNC_AMPLITUDE  = 24'h001000;  // 1
localparam signed ONE                   = 24'h001000;  // 1
localparam signed ONE_DIV_2             = 24'h000800;  // 0.5
//NYI//localparam signed TAU_DELAY             = 24'h000000;  // 0 (0 cycles)
localparam signed ONE_DIV_TAU_REC       = 24'h000052;  // 0.02001953125 (0.02?) (1/tau_rec (50ms))
localparam signed ONE_DIV_TAU_DECAY     = 24'h00019A;  // 0.10009765625 (0.1) (1/tau_decay (10ms))
localparam signed NEG_ONE_DIV_TAU_DECAY = 24'hFFFE66;  // -0.10009765625 (-0.1) (-1/tau_decay (10ms))
localparam signed NEG_ONE_DIV_TAU_FACIL = 24'hFFFFFC;  // -0.0009765625 (-0.001) (-1/tau_facil (1000ms))
*/
/* END Q12.12 */

/* Q12.20 - NOT ENOUGH ACCURACY FOR NT_Q */
/*
localparam signed DT                    = 32'h00000419;  // 0.0010004043579101562 (0.001)
localparam signed DT_DIV_2              = 32'h0000020C;  // 0.000499725341796875 (0.0005) (dt/2)
localparam signed INIT_NT_X             = 32'h00100000;  // 1
localparam signed INIT_NT_Y             = 32'h00000000;  // 0
localparam signed INIT_NT_Z             = 32'h00000000;  // 0
localparam signed INIT_NT_Q             = 32'h00000000;  // 0
localparam signed DELTA_FUNC_AMPLITUDE  = 32'h00100000;  // 1
localparam signed ONE                   = 32'h00100000;  // 1
localparam signed ONE_DIV_2             = 32'h00080000;  // 0.5
//NYI//localparam signed TAU_DELAY             = 32'h00000000;  // 0 (0 cycles)
localparam signed ONE_DIV_TAU_REC       = 32'h000051EC;  // 0.020000457763671875 (0.02?) (1/tau_rec (50ms))
localparam signed ONE_DIV_TAU_DECAY     = 32'h0001999A;  // 0.10000038146972656 (0.1) (1/tau_decay (10ms))
localparam signed NEG_ONE_DIV_TAU_DECAY = 32'hFFFE6666;  // -0.10000038146972656 (-0.1) (-1/tau_decay (10ms))
localparam signed NEG_ONE_DIV_TAU_FACIL = 32'hFFFFAE14;  // -0.0010004043579101562 (-0.001) (-1/tau_facil (1000ms))
//*/
/* END Q12.20 */

/* Q2.30 */
///*
localparam signed DT                    = 32'h0010624E;  // 0.001
localparam signed DT_DIV_2              = 32'h00083127;  // 0.0005 (dt/2)
localparam signed INIT_NT_X             = 32'h40000000;  // 1
localparam signed INIT_NT_Y             = 32'h00000000;  // 0
localparam signed INIT_NT_Z             = 32'h00000000;  // 0
localparam signed INIT_NT_Q             = 32'h00000000;  // 0
localparam signed DELTA_FUNC_AMPLITUDE  = 32'h40000000;  // 1
localparam signed ONE                   = 32'h40000000;  // 1
localparam signed ONE_DIV_2             = 32'h20000000;  // 0.5
//NYI//localparam signed TAU_DELAY             = 32'h00000000;  // 0 (0 cycles)
localparam signed ONE_DIV_TAU_REC       = 32'h0147AE14;  // 0.02 (1/tau_rec (50ms))
localparam signed ONE_DIV_TAU_DECAY     = 32'h06666666;  // 0.1 (1/tau_decay (10ms))
localparam signed NEG_ONE_DIV_TAU_DECAY = 32'hf999999A;  // -0.1 (-1/tau_decay (10ms))
localparam signed NEG_ONE_DIV_TAU_FACIL = 32'hFFEf9DB2;  // -0.001 (-1/tau_facil (1000ms))
//*/
/* END Q2.30 */


/* Q64.32 */
/*
localparam signed DT                    = 64'h0000000000418937;  // 0.001
localparam signed DT_DIV_2              = 64'h000000000020c49c;  // 0.0005 (dt/2)
localparam signed INIT_NT_X             = 64'h0000000100000000;  // 1
localparam signed INIT_NT_Y             = 64'h0000000000000000;  // 0
localparam signed INIT_NT_Z             = 64'h0000000000000000;  // 0
localparam signed INIT_NT_Q             = 64'h0000000000000000;  // 0
localparam signed DELTA_FUNC_AMPLITUDE  = 64'h0000000100000000;  // 1
localparam signed ONE                   = 64'h0000000100000000;  // 1
localparam signed ONE_DIV_2             = 64'h0000000080000000;  // 0.5
//NYI//localparam signed TAU_DELAY             = 64'h00000000;  // 0 (0 cycles)
localparam signed ONE_DIV_TAU_REC       = 64'h00000000051eb852;  // 0.02 (1/tau_rec (50ms))
localparam signed ONE_DIV_TAU_DECAY     = 64'h000000001999999a;  // 0.1 (1/tau_decay (10ms))
localparam signed NEG_ONE_DIV_TAU_DECAY = 64'hffffffffe6666666;  // -0.1 (-1/tau_decay (10ms))
localparam signed NEG_ONE_DIV_TAU_FACIL = 64'hffffffffffbe76c9;  // -0.001 (-1/tau_facil (1000ms))
//*/
/* END Q64.32 */

endpackage