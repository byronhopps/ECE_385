module carry_select_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a carry select.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
     
endmodule

module carrySelect_4bit
(
    input   logic[3:0]      A,
    input   logic[3:0]      B,
    output  logic[3:0]      S,
    input   logic           CI,
    output  logic           CO
);

endmodule

module mux_2in
(
    input   logic a1, b0, s,
    output  logic out
);

    assign out = (a1 & s) | (b0 & ~s);

endmodule
