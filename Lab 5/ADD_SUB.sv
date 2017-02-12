module ADD_SUB ( 
	input 	[7:0] A, B,
	input 	fn,
	output 	[8:0] S);

    // fn == 1: A - B
    // fn == 0: A + B

	logic c0, c1, c2, c3, c4, c5, c6, c7; //internal carries in the 8-bit adder
	logic [7:0] BB; //internal B or NOT(B)
	logic A8, BB8; //internal sign extension bits
	
	assign BB = (B ^ {8{fn}}); // when fn=1, complement B
	assign A8 = A[7]; assign BB4 = BB[7]; // Sign extension bits
	
	// copied from sign-bits
	full_adder FA0(.x(A[0]), .y(BB[0]), .z(fn), .s(S[0]), .c(c0));
	full_adder FA1(.x(A[1]), .y(BB[1]), .z(c0), .s(S[1]), .c(c1));
	full_adder FA2(.x(A[2]), .y(BB[2]), .z(c1), .s(S[2]), .c(c2));
	full_adder FA3(.x(A[3]), .y(BB[3]), .z(c2), .s(S[3]), .c(c3));
	full_adder FA4(.x(A[4]), .y(BB[4]), .z(c3), .s(S[4]), .c(c4));
	full_adder FA5(.x(A[5]), .y(BB[5]), .z(c4), .s(S[5]), .c(c5));
	full_adder FA6(.x(A[6]), .y(BB[6]), .z(c5), .s(S[6]), .c(c6));
	full_adder FA7(.x(A[7]), .y(BB[7]), .z(c6), .s(S[7]), .c(c7));
	full_adder FA8(.x(A8), .y(BB8), .z(c7), .s (S[8]), .c());
	//this should work as well (.x(A[7]), .y(BB[7]), .z(c7), .s(S[8]), .c())
	
endmodule

module add_4bit ( 
	input 	[3:0] C, D,
	input 	cin,
	output 	[3:0] S,
    output cout);

	logic c0, c1, c2 , c3; //internal carries in the 8-bit adder
	logic [4:0] D;
	
	assign c0 = 0;
	assign D = 4'b0001;
	// copied from sign-bits
	full_adder FA0(.x(C[0]), .y(D[0]), .z(fn), .s(CO[0]), .c(c0));
	full_adder FA1(.x(C[1]), .y(D[1]), .z(c0), .s(CO[1]), .c(c1));
	full_adder FA2(.x(C[2]), .y(D[2]), .z(c1), .s(CO[2]), .c(c2));
	full_adder FA3(.x(C[3]), .y(D[3]), .z(c2), .s(CO[3]), .c(c3));

	full_adder FA4(.x(C[3]), .y(D[3]), .z(c3), .s (CO[4]), .c());

	
endmodule

module full_Adder (input logic x, y, z,
                   output logic s, c);

    assign s = x^y^z;
    assign c = (x&y)|(y&z)|(z&x);
endmodule