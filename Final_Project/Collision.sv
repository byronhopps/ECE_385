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



// Deprecated, please use DetectCollision instead
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
        Xcollide = ((posX1 - posX0) <= (radiusX0 + radiusX1));
    end else begin
        Xcollide = ((posX0 - posX1) <= (radiusX0 + radiusX1));
    end
end

always_comb begin
    if (posY1 >= posY0) begin
        Ycollide = ((posY1 - posY0) <= (radiusY0 + radiusY1));
    end else begin
        Ycollide = ((posY0 - posY1) <= (radiusY0 + radiusY1));
    end
end

endmodule



module DetectCollision (
    input  RECT  A, B,
    output logic collision
);

logic Xcollide, Ycollide;
assign collision = Xcollide & Ycollide;

always_comb begin
    if (B.center.x >= A.center.x) begin
        Xcollide = ((B.center.x - A.center.x) <= (A.radius.x + B.radius.x));
    end else begin
        Xcollide = ((A.center.x - B.center.x) <= (A.radius.x + B.radius.x));
    end
end

always_comb begin
    if (B.center.y >= A.center.y) begin
        Ycollide = ((B.center.y - A.center.y) <= (A.radius.y + B.radius.y));
    end else begin
        Ycollide = ((A.center.y - B.center.y) <= (A.radius.y + B.radius.y));
    end
end

endmodule


module ObstacleCollisionDetect (
    input  logic  sysClk, frameClk, reset_h,
    input  RECT   entityArea,
    input  RECT   obstacleArea [n],
    input  logic  obstacleExists [n],
    output logic  sigCollide, done
);

parameter n = -1;

assign sigCollide = ~done | results.or();
/* assign sigCollide = done & results.or(); */

logic collision;
DetectCollision collisionDetector (.A(entityArea), .B(obstacleArea[idx]), .collision);

// Storage array to store detection results
logic results [n];
always_ff @ (posedge (sysClk)) begin
    if (reset_h == 1'b1) begin
        results <= '{default:0};
    end else begin
        results[idx] <= collision & obstacleExists[idx];
    end
end

// Internal counter from 0 to n
// Counts once per frame clock cycle
// Used to generate array indices
logic [$clog2(n):0] idx, idxNext;
assign idxNext = (idx == n-1) ? idx : idx + 1'd1;

// Update index on edge of system clock
always_ff @ (posedge sysClk) begin
    if (reset_h == 1'b1 || fClkRose) begin
        idx <= '0;
    end else begin
        idx <= idxNext;
    end
end

logic fClkRose;
RisingEdgeDetect fClkPosEdge (
    .clk(sysClk), .reset_h,
    .sig(frameClk), .posEdge(fClkRose)
);

// Ensure that the module will have time to finish
assert property ($rose(frameClk) |=> done);
assign done = (idx == n-1);

endmodule



module PointWithinArea (
    input  POSITION pos,
    input  RECT     area,
    output logic    overlap
);

logic xOverlap, yOverlap;

assign xOverlap = (area.center.x - area.radius.x <= pos.x
                && pos.x <= area.center.x + area.radius.x);

assign yOverlap = (area.center.y - area.radius.y <= pos.y
                && pos.y <= area.center.y + area.radius.y);

assign overlap = xOverlap & yOverlap;

endmodule
