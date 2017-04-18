`include "Types.sv" 

module Tank (
    input  logic frameClk, reset,
    input  logic moveUp, moveDown, moveLeft, moveRight,
    input  logic sigKill, sigSpawn,

    input  logic [9:0] tankPosX, tankPosY,
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

TankEntity tankEntity (
    .frameClk, .tankReset(reset),
    .moveUp, .moveDown, .moveLeft, .moveRight,
    .sigKill, .sigSpawn, .tankStep,
    .tankPosX, .tankPosY,
    .tankDir, .tankExists,
    .curPosX, .curPosY, .nextPosX, .nextPosY
);

TankMapper tankMapper (
    .tankPosX(curPosX), .tankPosY(curPosY),
    .pixelPosX, .pixelPosY,
    .tankRadius, .turretWidth,
    .tankDir, .tankColor
);

endmodule



// TODO: Add sigCollide and clean up position logic
// TODO: Change input signaling to be of type DIRECTION
module TankEntity (
    input  logic frameClk, tankReset,
    input  logic moveUp, moveDown, moveLeft, moveRight,
    input  logic sigKill, sigSpawn,

    input  logic [9:0] tankStep,
    input  logic [9:0] tankPosX, tankPosY,

    output DIRECTION    tankDir,
    output logic        tankExists,
    output logic [9:0] curPosX, curPosY,
    output logic [9:0] nextPosX, nextPosY 
);

always_comb begin
    nextPosX = tankPosX;
    nextPosY = tankPosY;
    nextDir = tankDir;

    // Process movement if the tank exists
    if (tankExists == 1'b1) begin
        case ({moveUp, moveDown, moveLeft, moveRight})
            4'b1000: begin
                nextPosY -= tankStep;
                nextDir == UP;
            end

            4'b0100: begin
                nextPosY += tankStep;
                nextDir == DOWN;
            end

            4'b0010: begin
                nextPosX -= tankStep;
                nextDir == LEFT;
            end

            4'b0001: begin
                nextPosX += tankStep;
                nextDir == RIGHT;
            end
        endcase
    end
end

always_ff @ (posedge frameClk) begin
    if (tankReset == 1'b1) begin
        curPosX <= '0;
        curPosY <= '0;
    end else begin
        curPosX <= tankPosX;
        curPosY <= tankPosY;
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
    unique case({tankReset, sigSpawn, sigKill})
        3'b1XX: tankExists <= 1'b0;
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
            tankColor = TURRET;
        end else begin
            tankColor = TANK;
        end

    end else begin
        tankColor = BACKGROUND;

end

endmodule
