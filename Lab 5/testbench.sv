module TESTBENCH ();

timeunit 10ns;
timeprecision 1ns;

// Internal logic signals
logic Clk = 0;
logic Reset, ClearA_LoadB, Run, X, M;
logic [7:0] S, Aval, Bval;
logic [6:0] AhexL, AhexU, BhexL, BhexU;
logic [7:0] ansA, ansB;

// Error count
integer errors = 0;

multiplier_8bit multiplier (.*);

// Clock toggle
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin : CLOCK_INITIALIZATION
    Clk = 0;
end

// Tests start here
initial begin : TEST_VECTORS
    Reset = 0;
    ClearA_LoadB = 1;
    Run = 1;

#2  Reset = 1;

// Load values
    S = 8'b11000101;
#2  ClearA_LoadB = 0;
#4  ClearA_LoadB = 1;
    S = 8'b00000111;

// Run multiplier
#2  Run = 0;
#50 Run = 1;

// Check answer
    ansA = 8'b11111110;
    ansB = 8'b01100011;
    if (Aval != ansA) errors++;
    if (Bval != ansB) errors++;

// Load values
    S = 8'b00000111;
#2  ClearA_LoadB = 0;
#4  ClearA_LoadB = 1;
    S = 8'b11000101;

// Run multiplier
#2  Run = 0;
#50 Run = 1;

// Check answer
    ansA = 8'b11111110;
    ansB = 8'b01100011;
    if (Aval != ansA) errors++;
    if (Bval != ansB) errors++;
	 
	 
// Load values
    S = 8'b00111011;
#2  ClearA_LoadB = 0;
#4  ClearA_LoadB = 1;
    S = 8'b00000111;

// Run multiplier
#2  Run = 0;
#50 Run = 1;

// Check answer
    ansA = 8'b00000001;
    ansB = 8'b10011101;
    if (Aval != ansA) errors++;
    if (Bval != ansB) errors++;

// Load values
    S = 8'b11111001;
#2  ClearA_LoadB = 0;
#4  ClearA_LoadB = 1;
    S = 8'b11000101;

// Run multiplier
#2  Run = 0;
#50 Run = 1;

// Check answer
    ansA = 8'b00000001;
    ansB = 8'b10011101;
    if (Aval != ansA) errors++;
    if (Bval != ansB) errors++;

end
endmodule
