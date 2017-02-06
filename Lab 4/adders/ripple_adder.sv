module ripple_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a ripple adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */

     
endmodule

module fullAdder (input a, b, cin,
                  output s, cout);
						
	assign s = a^b^cin;
	assign cout = (a&b)|(b&cin)|(cin&a);
endmodule
