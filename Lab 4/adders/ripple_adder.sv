module ripple_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    // Define internal carry bits
    logic [15:0] c;

    // Carry input is zero
    assign c[0] = 0;

    // 16 full adders with ripple carry
    fullAdder adder0 (.a(A[0]), .b(B[0]), .s(Sum[0]), .cin(c[0]), .cout(c[1]));
    fullAdder adder1 (.a(A[1]), .b(B[1]), .s(Sum[1]), .cin(c[1]), .cout(c[2]));
    fullAdder adder2 (.a(A[2]), .b(B[2]), .s(Sum[2]), .cin(c[2]), .cout(c[3]));
    fullAdder adder3 (.a(A[3]), .b(B[3]), .s(Sum[3]), .cin(c[3]), .cout(c[4]));
    fullAdder adder4 (.a(A[4]), .b(B[4]), .s(Sum[4]), .cin(c[4]), .cout(c[5]));
    fullAdder adder5 (.a(A[5]), .b(B[5]), .s(Sum[5]), .cin(c[5]), .cout(c[6]));
    fullAdder adder6 (.a(A[6]), .b(B[6]), .s(Sum[6]), .cin(c[6]), .cout(c[7]));
    fullAdder adder7 (.a(A[7]), .b(B[7]), .s(Sum[7]), .cin(c[7]), .cout(c[8]));
    fullAdder adder8 (.a(A[8]), .b(B[8]), .s(Sum[8]), .cin(c[8]), .cout(c[9]));
    fullAdder adder9 (.a(A[9]), .b(B[9]), .s(Sum[9]), .cin(c[9]), .cout(c[10]));
    fullAdder adder10 (.a(A[10]), .b(B[10]), .s(Sum[10]), .cin(c[10]), .cout(c[11]));
    fullAdder adder11 (.a(A[11]), .b(B[11]), .s(Sum[11]), .cin(c[11]), .cout(c[12]));
    fullAdder adder12 (.a(A[12]), .b(B[12]), .s(Sum[12]), .cin(c[12]), .cout(c[13]));
    fullAdder adder13 (.a(A[13]), .b(B[13]), .s(Sum[13]), .cin(c[13]), .cout(c[14]));
    fullAdder adder14 (.a(A[14]), .b(B[14]), .s(Sum[14]), .cin(c[14]), .cout(c[15]));
    fullAdder adder15 (.a(A[15]), .b(B[15]), .s(Sum[15]), .cin(c[15]), .cout(CO));

endmodule

module fullAdder (input a, b, cin,
                  output s, cout);

    assign s = a^b^cin;
    assign cout = (a&b)|(b&cin)|(cin&a);
endmodule

