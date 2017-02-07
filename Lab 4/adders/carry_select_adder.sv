module carry_select_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    // Define carry signals
    logic[3:0] c;
    assign CO = c[3];

    // Define adder modules
    carrySelect_4bit adder0 (.A(A[3:0]), .B(B[3:0]), .S(Sum[3:0]), .CI(0), .CO(c[0]));
    carrySelect_4bit adder1 (.A(A[7:4]), .B(B[7:4]), .S(Sum[7:4]), .CI(c[0]), .CO(c[1]));
    carrySelect_4bit adder2 (.A(A[11:8]), .B(B[11:8]), .S(Sum[11:8]), .CI(c[1]), .CO(c[2]));
    carrySelect_4bit adder3 (.A(A[15:12]), .B(B[15:12]), .S(Sum[15:12]), .CI(c[2]), .CO(c[3]));

endmodule

module carrySelect_4bit
(
    input   logic[3:0]      A,
    input   logic[3:0]      B,
    output  logic[3:0]      S,
    input   logic           CI,
    output  logic           CO
);

    // Define signals for sum logic
    logic[3:0] sum_c0;
    logic[3:0] sum_c1;

    // Define signals for carry propagation
    logic[3:0] c_c0;
    logic[3:0] c_c1;

    // Determine sum for bit 0
    fullAdder adder0_c0 (.a(A[0]), .b(B[0]), .s(sum_c0[0]), .cin(0), .cout(c_c0[0]));
    fullAdder adder0_c1 (.a(A[0]), .b(B[0]), .s(sum_c1[0]), .cin(1), .cout(c_c1[0]));
    mux_2in S0_mux (.a1(sum_c1[0]), .b0(sum_c0[0]), .s(CI), .out(S[0]));

    // Determine sum for bit 1
    fullAdder adder1_c0 (.a(A[1]), .b(B[1]), .s(sum_c0[1]), .cin(c_c0[0]), .cout(c_c0[1]));
    fullAdder adder1_c1 (.a(A[1]), .b(B[1]), .s(sum_c1[1]), .cin(c_c1[0]), .cout(c_c1[1]));
    mux_2in S1_mux (.a1(sum_c1[1]), .b0(sum_c0[1]), .s(CI), .out(S[1]));

    // Determine sum for bit 2
    fullAdder adder2_c0 (.a(A[2]), .b(B[2]), .s(sum_c0[2]), .cin(c_c0[1]), .cout(c_c0[2]));
    fullAdder adder2_c1 (.a(A[2]), .b(B[2]), .s(sum_c1[2]), .cin(c_c1[1]), .cout(c_c1[2]));
    mux_2in S2_mux (.a1(sum_c1[2]), .b0(sum_c0[2]), .s(CI), .out(S[2]));

    // Determine sum for bit 3
    fullAdder adder3_c0 (.a(A[3]), .b(B[3]), .s(sum_c0[3]), .cin(c_c0[2]), .cout(c_c0[3]));
    fullAdder adder3_c1 (.a(A[3]), .b(B[3]), .s(sum_c1[3]), .cin(c_c1[2]), .cout(c_c1[3]));
    mux_2in S3_mux (.a1(sum_c1[3]), .b0(sum_c0[3]), .s(CI), .out(S[3]));

    // Determine carry output
    mux_2in carry_mux (.a1(c_c1[3]), .b0(c_c0[3]), .out(CO), .s(CI));

endmodule

module mux_2in
(
    input   logic a1, b0, s,
    output  logic out
);

    assign out = (a1 & s) | (b0 & ~s);

endmodule
