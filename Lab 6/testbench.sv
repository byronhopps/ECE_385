
module TESTBENCH ();

timeunit 10ns;
timeprecision 1ns;

// Internal logic signals
logic [15:0] S;
logic	Clk, Reset, Run, Continue;
logic [11:0] LED;
logic [6:0] HEX0, HEX1, HEX2, HEX3;

// Remeber values of internal registers
logic [15:0] MAR, MDR, PC, IR;
logic [7:0] [15:0] REG; 
logic BEN, N, Z, P;

assign MAR = slc3.mainComputer.d0.MAR;
assign MDR = slc3.mainComputer.d0.MDR;
assign IR = slc3.mainComputer.d0.IR;
assign PC = slc3.mainComputer.d0.PC;
assign BEN = slc3.mainComputer.d0.BEN;
assign N = slc3.mainComputer.d0.N;
assign Z = slc3.mainComputer.d0.Z;
assign P = slc3.mainComputer.d0.P;
assign REG = slc3.mainComputer.d0.register_file.REG;

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
    S = 16'd3;
    Run = 1;
//  Continue = 1;
#4  Reset = 1;
#4  Reset = 0;
#4  Reset = 1;
#4  Run = 0;
#4  Run = 1;

end
endmodule
