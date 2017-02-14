module shifter (input  logic [8:0] A,
                input  logic [7:0] B,
                output logic [8:0] Ashift,
                output logic [7:0] Bshift); 

    always_comb begin
        Ashift[8] = A[8];
        Ashift[7] = A[8];
        Ashift[6] = A[7];
        Ashift[5] = A[6];
        Ashift[4] = A[5];
        Ashift[3] = A[4];
        Ashift[2] = A[3];
        Ashift[1] = A[2];
        Ashift[0] = A[1];
        Bshift[7] = A[0];
        Bshift[6] = B[7];
        Bshift[5] = B[6];
        Bshift[4] = B[5];
        Bshift[3] = B[4];
        Bshift[2] = B[3];
        Bshift[1] = B[2];
        Bshift[0] = B[1];
    end
endmodule
