module regFile (
    input logic [15:0] mainBus,
    input logic [2:0] DR,
    input logic [2:0] SR1, SR2,
    input logic LD_REG, Clk, Reset,

    output logic [15:0] SR1_OUT, SR2_OUT
);

    // Define array of 8 16-bit registers
    logic [7:0][15:0] REG;

    assign SR1_OUT = REG[SR1];
    assign SR2_OUT = REG[SR2];

    always_ff @ (posedge Clk) begin
//        for (i = 0; i < 8; i++)
//            REG[i] <= REG[i];
// TODO: Verify if this is needed

        if(Reset == 1)
            REG = '0;

        else if (LD_REG == 1)
            REG[DR] <= mainBus;
    end

endmodule
