module TESTBENCH ();

timeunit 10ns;
timeprecision 1ns;

// Internal logic signals
logic [15:0] S;
logic	Clk, Reset, Run, Continue;
logic [11:0] LED;
logic [6:0] HEX0, HEX1, HEX2, HEX3;

logic [15:0] MAR, MDR, PC, IR; 
logic BEN, N, Z, P;
logic [7:0][15:0] REG;

assign MAR = slc3.mainComputer.d0.MAR;
assign MDR = slc3.mainComputer.d0.MDR;
assign PC = slc3.mainComputer.d0.PC;
assign IR = slc3.mainComputer.d0.IR;

assign BEN = slc3.mainComputer.d0.BEN;
assign N = slc3.mainComputer.d0.N;
assign P = slc3.mainComputer.d0.P;
assign Z = slc3.mainComputer.d0.Z;

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
    S = 16'd90;
    Run = 1;
#4  Reset = 1;
#4  Reset = 0;
#4  Reset = 1;
#4  Run = 0;
#4  Run = 1;
#32 S = 16'd2;

end
endmodule
