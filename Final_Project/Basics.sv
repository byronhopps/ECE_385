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



module ScoreCounter (
    input  logic clk, reset_h,
    input  logic up, down,
    output logic [7:0] count
);

logic sigUp, sigDown;

RisingEdgeDetect(.clk, .reset_h, .sig(up),   .posEdge(sigUp)  );
RisingEdgeDetect(.clk, .reset_h, .sig(down), .posEdge(sigDown));

// Register for holding count value
always_ff @ (posedge clk) begin
    if (reset_h == 1'b1 || {sigUp, sigDown} == 2'b11) begin
        count <= '0;
    end else if (sigUp) begin
        count <= count + 1;
    end else if (sigDown) begin
        count <= count - 1;
    end
end

endmodule
