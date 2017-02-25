
// Temporary top-level module for week 1
module slc3_toplevel(
    input logic [15:0] S,
    input logic    Clk, Reset, Run, Continue,
    output logic [11:0] LED,
    output logic [6:0] HEX0, HEX1, HEX2, HEX3
);

    logic CE, UB, LB, OE, WE;
    wire [15:0] memoryIO;
    logic [19:0] ADDR;

    slc3 mainComputer (.Clk, .Reset, .Run, .Continue,
        .LED, .HEX0, .HEX1, .HEX2, .HEX3, .ADDR, .CE, .UB, .LB, .OE, .WE,
        .Data(memoryIO)
    );

    test_memory memoryUnit(.Clk, .Reset, .CE, .UB, .LB, .OE, .WE,
        .I_O(memoryIO), .A(ADDR)
    );

endmodule

