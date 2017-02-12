/*Inputs
S – logic [7:0]
Clk, Reset, Run, ClearA_LoadB – logic
Outputs
AhexU, AhexL, BhexU, BhexL – logic [6:0]
Aval, Bval – logic [7:0]
X –logic*/

typedef enum logic [3:0] {ready, reset, clrA_ldB, count, add, shift, done} state;

module multiplier_8bit (input logic  Clk, Reset, ClearA_LoadB, Run,
                        input  logic [7:0]  S,
                        output logic [7:0]  Aval,    Bval,
                        output logic        X, M,
                        output logic [6:0]  AhexL, AhexU, BhexL, BhexU);

endmodule
endmodule
