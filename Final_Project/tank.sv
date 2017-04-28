module Tank (
    input  logic frameClk, reset_h,
    input  logic moveUp, moveDown, moveLeft, moveRight,
    input  logic sigKill, sigSpawn, sigStop,
    input  logic [3:0] playerNumber,

    input  logic [9:0] spawnPosX, spawnPosY,
    input  logic [9:0] pixelPosX, pixelPosY,

    input  logic [9:0] tankStep,
    input  logic [7:0] tankRadius,
    input  logic [7:0] turretWidth,

    output DIRECTION    tankDir,
    output COLOR        tankColor,
    output logic        tankExists,
    output logic [9:0] curPosX, curPosY,
    output logic [9:0] nextPosX, nextPosY 
);

logic sigStopInt, arenaEdgeCollide;
assign sigStopInt = arenaEdgeCollide | sigStop;

// TODO: add tankStartDir input
TankEntity tankEntity (
    .frameClk, .tankReset(reset_h),
    .moveUp, .moveDown, .moveLeft, .moveRight,
    .sigKill, .sigSpawn, .sigStop(sigStopInt), .tankStep,
    .tankDir, .tankExists,
    .spawnPosX, .spawnPosY,
    .curPosX, .curPosY, .nextPosX, .nextPosY
);

ArenaEdgeDetect tankEdgeDetect (
    .posX(nextPosX), .posY(nextPosY), .radius(tankRadius),
    .collide(arenaEdgeCollide)
);

TankMapper tankMapper (
    .tankPosX(curPosX), .tankPosY(curPosY),
    .tankRadius, .turretWidth, .playerNumber,
    .pixelPosX, .pixelPosY,
    .tankDir, .tankColor
);

endmodule



// TODO: Change input signaling to be of type DIRECTION
module TankEntity (
    input  logic frameClk, tankReset,
    input  logic moveUp, moveDown, moveLeft, moveRight,
    input  logic sigKill, sigSpawn, sigStop,

    input  logic [9:0] tankStep,
    input  logic [9:0] spawnPosX, spawnPosY,

    output DIRECTION    tankDir,
    output logic        tankExists,
    output logic [9:0] curPosX, curPosY,
    output logic [9:0] nextPosX, nextPosY 
);

always_comb begin
    nextPosX = curPosX;
    nextPosY = curPosY;
    nextDir = tankDir;

    // Process movement if the tank exists
    if (tankExists == 1'b1) begin
        case ({moveUp, moveDown, moveLeft, moveRight})
            4'b1000: begin
                nextPosY -= tankStep;
                nextDir = UP;
            end

            4'b0100: begin
                nextPosY += tankStep;
                nextDir = DOWN;
            end

            4'b0010: begin
                nextPosX -= tankStep;
                nextDir = LEFT;
            end

            4'b0001: begin
                nextPosX += tankStep;
                nextDir = RIGHT;
            end
            
            default: begin end
        endcase
    end
end

// Tank position registers
always_ff @ (posedge frameClk) begin
    if (tankReset == 1'b1) begin
        curPosX <= '0;
        curPosY <= '0;
    end else if (sigKill == 1'b1) begin
        curPosX <= 10'd1000;
        curPosY <= 10'd1000;
    end else if (sigSpawn == 1'b1) begin
        curPosX <= spawnPosX;
        curPosY <= spawnPosY;
    end else if (sigStop == 1'b1) begin
        curPosX <= curPosX;
        curPosY <= curPosY;
    end else begin
        curPosX <= nextPosX;
        curPosY <= nextPosY;
    end
end

DIRECTION nextDir;
always_ff @ (posedge frameClk) begin
    if (tankReset == 1'b1) begin
        tankDir <= RIGHT;
    end else begin
        tankDir <= nextDir;
    end
end

always_ff @ (posedge frameClk) begin
    unique casez({tankReset, sigSpawn, sigKill})
        3'b1??: tankExists <= 1'b0;
        3'b010: tankExists <= 1'b1;
        3'b001: tankExists <= 1'b0;
        3'b000: tankExists <= tankExists;

        3'b011: begin
            tankExists <= 1'b0;
            $error("Tank spawned and killed at the same time");
        end
    endcase
end

endmodule



module TankMapper (
    input  logic [9:0] tankPosX, tankPosY,
    input  logic [9:0] pixelPosX, pixelPosY,
    input  logic [7:0] tankRadius,
    input  logic [7:0] turretWidth,
    input  logic [3:0] playerNumber,
    input  DIRECTION   tankDir,
    output COLOR       tankColor
);

logic isTurret;
always_comb begin

    // If the current pixel is within a box of radius tankRadius centered at tankPos
    // TODO: verify that this works even with overflow/underflow
    if (tankPosX-tankRadius <= pixelPosX && pixelPosX <= tankPosX+tankRadius
     && tankPosY-tankRadius <= pixelPosY && pixelPosY <= tankPosY+tankRadius) begin

        // Determines whether the current pixel is part of the turret or not
        unique case (tankDir)
            UP: isTurret = (
                tankPosX-turretWidth <= pixelPosX && pixelPosX <= tankPosX+turretWidth
                && tankPosY-tankRadius <= pixelPosY && pixelPosY <= tankPosY
            );

            DOWN: isTurret = (
                tankPosX-turretWidth <= pixelPosX && pixelPosX <= tankPosX+turretWidth
                && tankPosY <= pixelPosY && pixelPosY <= tankPosY+tankRadius
            );

            LEFT: isTurret = (
                tankPosX-tankRadius <= pixelPosX && pixelPosX <= tankPosX
                && tankPosY-turretWidth <= pixelPosY && pixelPosY <= tankPosY+turretWidth
            );

            RIGHT: isTurret = (
                tankPosX <= pixelPosX && pixelPosX <= tankPosX+tankRadius
                && tankPosY-turretWidth <= pixelPosY && pixelPosY <= tankPosY+turretWidth
            );

            default: begin
                isTurret = 1'b0;
                $error("Unhandled direction in tankMapper");
            end
        endcase

        if (isTurret == 1'b1) begin
            case (playerNumber)
                0: tankColor = TURRET_0;
                1: tankColor = TURRET_1;
                2: tankColor = TURRET_2;
                3: tankColor = TURRET_3;
                default: tankColor = TURRET;
            endcase
        end else begin
            case (playerNumber)
                0: tankColor = TANK_0;
                1: tankColor = TANK_1;
                2: tankColor = TANK_2;
                3: tankColor = TANK_3;
                default: tankColor = TANK;
            endcase
        end

    end else begin
        isTurret = 1'bX;
        tankColor = BACKGROUND;
    end

end

endmodule
