module JungleTerrain (
    input  logic clk, reset_h,
    input  logic sigSpawn, sigKill,
    input  logic [7:0] terrainID,
    input  RECT  spawnArea,
    input  POSITION pixelPos,

    output logic pixelValid,
    output COLOR pixelColor
);

parameter entityTerrainID = 0;

RECT curArea;
logic entityValid;
EntityCore #(entityTerrainID) jungleEntityCore (
    .clk, .reset_h,
    .sigSpawn, .sigKill,
    .terrainID, .entityValid,
    .spawnArea, .curArea
);

logic pixelInArea;
PointWithinArea pixelCheck (
    .pos(pixelPos), .area(curArea), .overlap(pixelInArea)
);

// Color mapper logic
always_comb begin
    pixelColor = BACKGROUND;
    pixelValid = 0;

    // If the current pixel is within the box defined for the jungle tile
    if (entityValid && pixelInArea) begin

        // Paint the jungle as an array of 2x2 boxes
        if (pixelPos.x[1] == pixelPos.y[1]) begin
            pixelColor = JUNGLE_1;
            pixelValid = 1;
        end else begin
            pixelColor = JUNGLE_2;
            pixelValid = 1;
        end
    end
end

endmodule



module WallTerrain (
    input  logic clk, reset_h,
    input  logic sigSpawn, sigKill,
    input  logic [7:0] terrainID,
    input  RECT  spawnArea,
    input  POSITION pixelPos,

    output RECT  wallArea,
    output logic wallExists,
    output logic pixelValid,
    output COLOR pixelColor
);

parameter entityTerrainID = 0;

RECT curArea;
logic entityValid;
EntityCore #(entityTerrainID) wallEntityCore (
    .clk, .reset_h,
    .sigSpawn, .sigKill,
    .terrainID, .entityValid(wallExists),
    .spawnArea, .curArea(wallArea)
);

logic pixelInArea;
PointWithinArea pixelCheck (
    .pos(pixelPos), .area(wallArea), .overlap(pixelInArea)
);

// Color mapper logic
always_comb begin
    pixelColor = BACKGROUND;
    pixelValid = 0;

    // If the current pixel is within the box defined for the wall tile
    if (wallExists && pixelInArea) begin

        // Paint white lines to simulate bricks
        if (pixelPos.x[3:0] == 4'h8 || pixelPos.y[2:0] == 3'h4) begin
            pixelColor = WHITE;
            pixelValid = 1;
        end

        // Otherwise paint the wall color
        else begin
            pixelColor = WALL;
            pixelValid = 1;
        end
    end
end

endmodule



module WaterTerrain (
    input  logic clk, reset_h,
    input  logic sigSpawn, sigKill,
    input  logic [7:0] terrainID,
    input  RECT  spawnArea,
    input  POSITION pixelPos,

    output RECT  waterArea,
    output logic waterExists,
    output logic pixelValid,
    output COLOR pixelColor
);

parameter entityTerrainID = 0;

RECT curArea;
logic entityValid;
EntityCore #(entityTerrainID) waterEntityCore (
    .clk, .reset_h,
    .sigSpawn, .sigKill,
    .terrainID, .entityValid(waterExists),
    .spawnArea, .curArea(waterArea)
);

logic pixelInArea;
PointWithinArea pixelCheck (
    .pos(pixelPos), .area(waterArea), .overlap(pixelInArea)
);

// Color mapper logic
always_comb begin
    pixelColor = BACKGROUND;
    pixelValid = 0;

    // If the current pixel is within the box defined for the wall tile
    if (waterExists && pixelInArea) begin
        pixelColor = WATER;
        pixelValid = 1;
    end
end

endmodule
module EntityCore (
    input  logic clk, reset_h,
    input  logic sigSpawn, sigKill,
    input  logic sigLoad,
    input  logic [7:0] terrainID,
    input  RECT  spawnArea,
    output RECT  curArea,
    output logic entityValid
);

parameter entityTerrainID = 0;

assign entityValid = (state == ON);

logic sigSpawnInt;
assign sigSpawnInt = sigSpawn & (entityTerrainID == terrainID);

enum logic {ON, OFF} state;

// Next state logic
always_ff @ (posedge clk) begin
    if (reset_h == 1'b1 | sigKill) begin
        state <= OFF;
    end else if (sigSpawnInt) begin
        state <= ON;
    end
end

// Location load logic
always_ff @ (posedge clk) begin
    if (reset_h == 1'b1) begin
        curArea <= '{center:'{0,0}, radius:'{0,0}};
    end else if (sigSpawnInt) begin
        curArea <= spawnArea;
    end else begin
        curArea <= curArea;
    end
end

endmodule
