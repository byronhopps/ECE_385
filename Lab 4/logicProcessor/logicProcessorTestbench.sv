module mainTest();

timeunit 10ns;
timeprecision 1ns;

// Define IO signals
logic clk = 0;
logic reset, loadA, loadB, execute;
logic [7:0] Din;
logic [2:0] F;
logic [1:0] R;
logic [3:0] LED;
logic [7:0] Aval, Bval;
logic [6:0] AhexL, AhexU, BhexL, BhexU;

// Storage for results
logic [7:0] ans_1a, ans_1b;

// Counter for instances where the simulation results
// don't match expectations
integer errorCnt = 0;

// Setup DUT
processor processor1(.*);

// Clock Toggle
always begin : CLOCK_GENERATION
	#1 clk = ~clk;
end

initial begin : CLOCK_INITIALIZATION
	clk = 0;
end

initial begin : TEST_VECTORS
	reset = 0;
	loadA = 1;
	loadB = 1;
	execute = 1;
	
	Din = 8'h33;
	F = 3'b010;
	R = 2'b10;

	#2 reset = 1;
	
	// Toggle loadA
	#2 loadA = 0;
	#2 loadA = 1;
	
	// Toggle loadB with input data of 0x55
	#2 loadB = 0;
	Din = 8'h55;
	#2 loadB = 1;
	Din = 8'h00;
	
	// Toggle execute
	#2 execute = 0;
	#22 execute = 1;
	
	// Expected result of 1st cycle
	ans_1a = (8'h33 ^ 8'h55);
	
	// Check results
	if (Aval != ans_1a)
		errorCnt++;
	
	if (Bval != 8'h55)
		errorCnt++;
		
	// Change F and R
	F = 3'b110;
	R = 2'b01;
	
	// Toggle execute
	#2 execute = 0;
	#2 execute = 1;
	
	#22 execute = 0;
	
	// Check results
	if (Aval != ans_1a)
		errorCnt++;
		
	ans_2b = ~(ans_1a ^ 8'h55);
	if (Bval != ans_2b)
		errorCnt++;
		
	R = 2'b11;
	
	#2 execute = 1;
	
	// A and B should swap
	#22 if (Aval != ans_2b)
		errorCnt++;
	
	if (Bval != ans_1a)
		errorCnt++;
	
	if (errorCnt == )
		$display("Design successful");
	else
		$display("%d errors detected", errorCnt);
end

endmodule
