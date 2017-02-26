module TESTBENCH ();

timeunit 10ns;
timeprecision 1ns;

// Internal logic signals
logic [15:0] S;
logic	Clk, Reset, Run, Continue;
logic [11:0] LED;
logic [6:0] HEX0, HEX1, HEX2, HEX3;

// Instantiating the DUT
// module and signal name
slc3_toplevel slc3 (.*);

// Clock toggle
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end


// Tests start here
initial begin : TEST_VECTORS
    S = 16'd11;
    Run = 1;
//  Continue = 1;
#4  Reset = 1;
#4  Reset = 0;
#4  Reset = 1;
#4  Run = 0;
#4  Run = 1;

end
endmodule
