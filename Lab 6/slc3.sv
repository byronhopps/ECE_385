//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    Feb. 18, 2017
// Design Name:    ECE 385 Lab 6 Given Code - SLC-3 top-level (External SRAM)
// Module Name:    SLC3
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 09-22-2015
//    Revised 02-13-2017
//    Spring 2017 Distribution
//
//------------------------------------------------------------------------------

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


module slc3(
    input logic [15:0] S,
    input logic    Clk, Reset, Run, Continue,
    output logic [11:0] LED,
    output logic [6:0] HEX0, HEX1, HEX2, HEX3,
    output logic CE, UB, LB, OE, WE,
    output logic [19:0] ADDR,
    inout wire [15:0] Data //tristate buffers need to be of type wire
);

// Declaration of push button active high signals
logic Reset_ah, Continue_ah, Run_ah;

assign Reset_ah = ~Reset;
assign Continue_ah = ~Continue;
assign Run_ah = ~Run;

// Internal connections
logic BEN;
logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED;
logic GatePC, GateMDR, GateALU, GateMARMUX;
logic [1:0] PCMUX, ADDR2MUX, ALUK;
logic DRMUX, SR1MUX, SR2MUX, ADDR1MUX;
logic MIO_EN;

logic [15:0] MDR_In;
logic [15:0] MAR, MDR, IR;
logic [15:0] Data_from_SRAM, Data_to_SRAM;

// An array of 4-bit wires to connect the hex_drivers efficiently to wherever we want
// For Week 1, they will directly be connected to the IR register
// For Week 2, they will be patched into the MEM2IO module so that Memory-mapped IO can take place
logic [3:0][3:0] hex_4;
// Remove the following assignments for Week 2
assign hex_4[3][3:0] = IR[15:12];
assign hex_4[2][3:0] = IR[11:8];
assign hex_4[1][3:0] = IR[7:4];
assign hex_4[0][3:0] = IR[3:0];

// For week 1 only
HexDriver hex_driver3 (.IN(IR[15:12]), .OUT(HEX3));
HexDriver hex_driver2 (.IN(IR[11:8]), .OUT(HEX2));
HexDriver hex_driver1 (.IN(IR[7:4]), .OUT(HEX1));
HexDriver hex_driver0 (.IN(IR[3:0]), .OUT(HEX0));

// Connect MAR to ADDR, which is also connected as an input into MEM2IO
//    MEM2IO will determine what gets put onto Data_CPU (which serves as a potential
//    input into MDR)
assign ADDR = { 4'b00, MAR }; //Note, our external SRAM chip is 1Mx16, but address space is only 64Kx16
assign MIO_EN = ~OE;

// You need to make your own datapath module and connect everything to the datapath
// Be careful about whether Reset is active high or low
datapath d0 (.*, .Reset(Reset_ah));

// Our SRAM and I/O controller
Mem2IO memory_subsystem(
    .*, .Reset(Reset_ah), .ADDR(ADDR), .Switches(S),
//    Uncomment the following line for Week 2 to patch Hex display into Mem2IO
//    .HEX0(hex_4[0][3:0]), .HEX1(hex_4[1][3:0]), .HEX2(hex_4[2][3:0]), .HEX3(hex_4[3][3:0]),
    .HEX0(), .HEX1(), .HEX2(), .HEX3(),
    .Data_from_CPU(MDR), .Data_to_CPU(MDR_In),
    .Data_from_SRAM(Data_from_SRAM), .Data_to_SRAM(Data_to_SRAM)
);

// The tri-state buffer serves as the interface between Mem2IO and SRAM
tristate #(.N(16)) tr0(
    .Clk(Clk), .tristate_output_enable(~WE), .Data_write(Data_to_SRAM), .Data_read(Data_from_SRAM), .Data(Data)
);

// State machine and control signals
ISDU state_controller(
    .*, .Reset(Reset_ah), .Run(Run_ah), .Continue(Continue_ah),
    .Opcode(IR[15:12]), .IR_5(IR[5]), .IR_11(IR[11]),
    .Mem_CE(CE), .Mem_UB(UB), .Mem_LB(LB), .Mem_OE(OE), .Mem_WE(WE)
);

// An example of instantiating the test_memory. Do not instantiate it here.
// Read the instructions in the header of test_memory.sv about how to use it.
// Test memory is only for simulation, and should NOT be included when circuit is tested on FPGA board.
// Otherwise, the circuit will not function correctly.
/*
test_memory test_memory0(
    .Clk(Clk), .Reset(~Reset),
    .I_O(Data), .A(ADDR),
    .*
);
*/
endmodule
