module RisingEdgeDetect (
    input  logic  clk, reset_h,
    input  logic  sig,
    output logic  posEdge
);

logic sigDelay1;

always_ff @ (posedge clk) begin
    if (reset_h == 1'b1) begin
        sigDelay1 <= '0;
    end else begin
        sigDelay1 <= sig;
    end
end

assign posEdge = sig & ~sigDelay1;

endmodule
