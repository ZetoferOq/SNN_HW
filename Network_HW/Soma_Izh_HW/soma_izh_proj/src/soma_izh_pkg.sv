package soma_izh_pkg;

/* A_DIV_B: Avoid division by specifying the resulting value in advance */

/* Q12.12 */
/*
localparam signed DT        = 24'h000004;  // 0.0009765625 (0.001)
localparam signed DT_DIV_2  = 24'h000002;  // 0.00048828125 (0.0005) (dt/2)
localparam signed INIT_U    = 24'h000000;  // 0
localparam signed V_PEAK    = 24'h023000;  //  35
localparam signed V_RESET   = 24'hfce000;  //  -50
localparam signed VR        = 24'hfc4000;  //  -60
localparam signed VT        = 24'hfd8000;  //  -40
localparam signed A         = 24'h00007b;  //  0.030029296875 (0.03)
localparam signed B         = 24'hffe000;  //  -2
localparam signed D         = 24'h064000;  //  100
localparam signed K_DIV_C   = 24'h00001d;  //  0.007080078125 (k/C)
localparam signed ONE_DIV_C = 24'h000029;  //  0.010009765625 (1/C)
*/
/* END Q12.12 */

/* Q12.20 */
/*
localparam signed DT        = 32'h00000419;  // 0.0010004043579101562 (0.001)
localparam signed DT_DIV_2  = 32'h0000020C;  // 0.000499725341796875 (0.0005) (dt/2)
localparam signed INIT_U    = 32'h00000000;  // 0
localparam signed V_PEAK    = 32'h02300000;  //  35
localparam signed V_RESET   = 32'hFCE00000;  //  -50
localparam signed VR        = 32'hFC400000;  //  -60
localparam signed VT        = 32'hFD800000;  //  -40
localparam signed A         = 32'h00007AE1;  //  0.029999732971191406 (0.03)
localparam signed B         = 32'hFFE00000;  //  -2
localparam signed D         = 32'h06400000;  //  100
localparam signed K_DIV_C   = 32'h00001CAC;  //  0.006999969482421875 (0.007)(k/C)
localparam signed K         = 32'h000b3333;  //  0.7
localparam signed ONE_DIV_C = 32'h000028F6;  //  0.010000228881835938 (0.01) (1/C)
//*/
/* END Q12.20 */

/* Q14.50 */
/*
localparam signed DT        = 64'h0000010624dd2f1b;  //  0.001
localparam signed DT_DIV_2  = 64'h00000083126e978d;  //  0.0005 (dt/2)
localparam signed INIT_U    = 64'h0000000000000000;  //  0
localparam signed V_PEAK    = 64'h008c000000000000;  //  35
localparam signed V_RESET   = 64'hff38000000000000;  //  -50
localparam signed VR        = 64'hff10000000000000;  //  -60
localparam signed VT        = 64'hff60000000000000;  //  -40
localparam signed A         = 64'h00001eb851eb851f;  //  0.03
localparam signed B         = 64'hfff8000000000000;  //  -2
localparam signed D         = 64'h0190000000000000;  //  100
localparam signed K         = 64'h0002cccccccccccd;  //  0.7
localparam signed ONE_DIV_C = 64'h00000a3d70a3d70a;  //  0.01 (1/C)
//*/
/* END Q14.50 */


/* Q15.17 */
///*
localparam signed DT        = 32'h00000083;  //  0.001
localparam signed DT_DIV_2  = 32'h00000042;  //  0.0005 (dt/2)
localparam signed INIT_U    = 32'h00000000;  //  0
localparam signed V_PEAK    = 32'h00460000;  //  35
localparam signed V_RESET   = 32'hff9c0000;  //  -50
localparam signed VR        = 32'hff880000;  //  -60
localparam signed VT        = 32'hffb00000;  //  -40
localparam signed A         = 32'h00000f5c;  //  0.03
localparam signed B         = 32'hfffc0000;  //  -2
localparam signed D         = 32'h00c80000;  //  100
localparam signed K         = 32'h00016666;  //  0.7
localparam signed ONE_DIV_C = 32'h0000051f;  //  0.01 (1/C)
//*/
/* END Q15.17 */

endpackage