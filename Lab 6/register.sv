module register_16 (
    input logic Clk, LD, Reset,
    input logic [15:0] In,

    output logic [15:0] Out
);

always_ff @ (posedge Clk) begin
    if (Reset == 1)
        Out <= '0;
    else if (LD == 1)
        Out <= In;
    end

endmodule
