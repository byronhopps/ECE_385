module JungleTerrain (
    input  logic frameClk, reset_h,
    input  logic sigSpawn, sigKill,
    input  logic terrainID,
    input  logic [9:0] spawnPosX, spawnPosY,
    input  logic [7:0] spawnRadiusX, spawnRadiusY,

    input  logic [9:0] pixelPosX, pixelPosY,
    output logic pixelValid,
    output COLOR pixelColor
);

parameter entityTerrainID = 0;

logic sigSpawnInt, sigKillInt;
assign sigSpawnInt = sigSpawn & (entityTerrainID == terrainID);
assign sigKillInt = sigKill & (entityTerrainID == terrainID);

enum logic {ON, OFF} state, nextState;

// Next state logic
always_ff @ (posedge frameClk) begin
    if (reset_h == 1'b1 | sigKillInt) begin
        nextState <= OFF;
    end else if (sigSpawnInt) begin
        nextState <= ON;
    end
end

// Position load logic
logic [9:0] posX, posY;
logic [9:0] nextPosX, nextPosY;
always_ff @ (posedge frameClk) begin
    if (reset_h == 1'b1) begin
        posX <= '0;
        posY <= '0;
    end else if (sigSpawnInt) begin
        posX <= spawnPosX;
        posY <= spawnPosY;
    end else begin
        posX <= posX;
        posY <= posY;
    end
end

// Radius load logic
logic [9:0] radiusX, radiusY;
logic [9:0] nextRadiusX, nextRadiusY;
always_ff @ (posedge frameClk) begin
    if (reset_h == 1'b1) begin
        radiusX <= '0;
        radiusY <= '0;
    end else if (sigSpawnInt) begin
        radiusX <= spawnRadiusX;
        radiusY <= spawnRadiusY;
    end else begin
        radiusX <= radiusX;
        radiusY <= radiusY;
    end
end

// Color mapper logic
always_comb begin
    pixelColor = BACKGROUND;
    pixelValid = 0;

    // If the current pixel is within the box defined for the jungle tile
    if (state == ON
        && posX-radiusX <= pixelPosX && pixelPosX <= posX+radiusX
        && posY-radiusY <= pixelPosY && pixelPosY <= posY+radiusY) begin

        // Paint the jungle as an array of 2x2 boxes
        if (pixelPosX[0] == pixelPosY[0]) begin
            pixelColor = JUNGLE;
            pixelValid = 1;
        end
    end
end

endmodule
