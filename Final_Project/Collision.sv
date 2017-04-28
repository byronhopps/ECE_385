module ArenaEdgeDetect (
    input  logic [9:0] posX, posY,
    input  logic [7:0] radius,
    output logic collide
);

parameter rightEdge = 640;
parameter leftEdge = 0;
parameter topEdge = 0;
parameter bottomEdge = 480;

always_comb begin
    collide = 0;

    if ((leftEdge + radius >= posX) || (posX >= rightEdge - radius)) begin
        collide = 1;
    end

    if ((topEdge + radius >= posY) || (posY >= bottomEdge - radius)) begin
        collide = 1;
    end
end

endmodule



module EntityCollisionDetect (
    input  logic [9:0] posX0, posY0,
    input  logic [9:0] posX1, posY1,
    input  logic [7:0] radiusX0, radiusX1,
    input  logic [7:0] radiusY0, radiusY1,
    output logic collide
);

logic Xcollide, Ycollide;
assign collide = Xcollide & Ycollide;

always_comb begin
    if (posX1 >= posX0) begin
        Xcollide = (posX1 - posX0) <= radiusX0 + radiusX1;
    end else begin
        Xcollide = (posX0 - posX1) <= radiusX0 + radiusX1;
    end
end

always_comb begin
    if (posY1 >= posY0) begin
        Ycollide = (posY1 - posY0) <= radiusY0 + radiusY1;
    end else begin
        Ycollide = (posY0 - posY1) <= radiusY0 + radiusY1;
    end
end

endmodule
