module TESTBENCH ();

timeunit 10ns;
timeprecision 1ns;

// Internal logic signals
	input logic [15:0] S,
	input logic	Clk, Reset, Run, Continue,
	output logic [11:0] LED,
	output logic [6:0] HEX0, HEX1, HEX2, HEX3
	//logic CE, UB, LB, OE, WE;
   //logic [19:0] ADDR;

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
#2   Reset = 1;
#2   Run = 1;

end
endmodule
