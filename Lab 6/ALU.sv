module ALU (
    input logic [15:0] A, B,
    input logic [1:0] ALUK,

    output logic [15:0] OUT
);

    always_comb begin
        case(ALUK)
            ALU_OPS::ADD : OUT = A + B;
            ALU_OPS::AND : OUT = A & B;
            ALU_OPS::NOT : OUT = ~A;
            default : begin
                OUT = '0;
                $warning("Unspecified ALU operation");
            end
        endcase
    end

endmodule
