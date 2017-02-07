module carry_lookahead_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);
    // Define carry signals
    logic C[3:0];
    assign C[0] = 0;

    // Cascade 4 4-bit carry-lookahead adders
    carry_lookahead_4bit adderBlock0 (.A(A[3:0]), .B(B[3:0]), .S(Sum[3:0]), .CI(C[0]), .CO(C[1]));
    carry_lookahead_4bit adderBlock1 (.A(A[7:4]), .B(B[7:4]), .S(Sum[7:4]), .CI(C[1]), .CO(C[2]));
    carry_lookahead_4bit adderBlock2 (.A(A[11:8]), .B(B[11:8]), .S(Sum[11:8]), .CI(C[2]), .CO(C[3]));
    carry_lookahead_4bit adderBlock3 (.A(A[15:12]), .B(B[15:12]), .S(Sum[15:12]), .CI(C[3]), .CO);

endmodule

module carry_lookahead_4bit
(
    input   logic[3:0]      A,
    input   logic[3:0]      B,
    input   logic           CI,
    output  logic[3:0]      S,
    output  logic           CO
);

    // Define internal propagation, generation, and carry bits
    logic[3:0] P;
    logic[3:0] G;
    logic[3:0] C;

    // Determine carry inputs to adders
    assign C[0] = CI;
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (G[0] & P[1]) | (C[0] & P[0] & P[1]);
    assign C[3] = G[2] | (G[1] & P[2]) | (G[0] & P[1] & P[2]) | (C[0] & P[0] & P[1] & P[2]);
    assign C[4] = G[3] | (G[2] & P[3]) | (G[1] & P[2] & P[3]) | (G[0] & P[1] & P[2] & P[3]) | (C[0] & P[0] & P[1] & P[2] & P[3]);
    assign CO = C[4];

    // Attach bits to adders
    lookaheadAdder adder0 (.A(A[0]), .B(B[0]), .C(C[0]), .S(S[0]), .P(P[0]), .G(G[0]));
    lookaheadAdder adder1 (.A(A[1]), .B(B[1]), .C(C[1]), .S(S[1]), .P(P[1]), .G(G[1]));
    lookaheadAdder adder2 (.A(A[2]), .B(B[2]), .C(C[2]), .S(S[2]), .P(P[2]), .G(G[2]));
    lookaheadAdder adder3 (.A(A[3]), .B(B[3]), .C(C[3]), .S(S[3]), .P(P[3]), .G(G[3]));

endmodule

module lookaheadAdder
(
    input   A, B, C,
    output  S, P, G
    );

    assign S = A ^ B ^ C;
    assign P = A ^ B;
    assign G = A & B;

endmodule
