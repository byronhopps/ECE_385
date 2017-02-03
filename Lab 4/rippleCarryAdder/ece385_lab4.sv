module adder2 (input [1:0] A, B,
               input cin,
               output [1:0] S,
               output cout);

	logic c1;
	fullAdder FA0(.a(A[0]), .b(B[0]), .cin(cin), .s(S[0]), .cout(c1));
	fullAdder FA1(.a(A[1]), .b(B[1]), .cin(c1), .s(S[1]), .cout(cout));
endmodule



module fullAdder (input a, b, cin,
                  output s, cout);
						
	assign s = a^b^cin;
	assign cout = (a&b)|(b&cin)|(cin&a);
endmodule
