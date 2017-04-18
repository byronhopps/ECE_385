`include "Types.sv"

module Bullet (
    input  logic frameClk, reset,
    input  logic sigKill, sigSpawn, sigBounce,

    input  DIRECTION   bulletStartDir,
    input  logic [7:0] bulletRadius,
    input  logic [7:0] bulletStep, bulletLife,
    input  logic [9:0] pixelPosX, pixelPosY,
    input  logic [9:0] bulletStartX, bulletStartY,

    output logic       bulletExists,
    output logic [9:0] bulletPosX, bulletPosY,
    output COLOR       bulletColor
);

BulletEntity bulletEntity (
    .frameClk, .reset, .sigKill, .sigSpawn, .sigBounce,
    .bulletStartDir, .bulletStep, .bulletLife,
    .bulletStartX, .bulletStartY,
    .bulletExists, .bulletPosX, .bulletPosY
);

BulletMapper bulletMapper(
    .bulletPosX, .bulletPosY, .pixelPosX, .pixelPosY,
    .bulletRadius, .bulletColor
);

endmodule



module BulletEntity (
    input  logic frameClk, reset,
    input  logic sigKill, sigSpawn, sigBounce,

    input  DIRECTION    bulletStartDir,
    input  logic [7:0]  bulletStep, bulletLife,
    input  logic [9:0]  bulletStartX, bulletStartY,

    output logic bulletExists,
    output logic [9:0] bulletPosX, bulletPosY,
);

// Bullet movement control logic
logic [9:0] nextPosX, nextPosY;
always_comb begin

    // On sigSpawn reset position to start position
    if (sigSpawn = 1'b1) begin
        nextPosX = bulletStartX;
        nextPosY = bulletStartY;

    // Otherwise update positon based on the current direction
    end else begin
        unique case (bulletDir)
            UP: begin
                nextPosX = bulletPosX;
                nextPosY = bulletPosY - bulletStep;
            end

            DOWN: begin
                nextPosX = bulletPosX;
                nextPosY = bulletPosY + bulletStep;
            end

            LEFT: begin
                nextPosX = bulletPosX - bulletStep;
                nextPosY = bulletPosY;
            end

            RIGHT: begin
                nextPosX = bulletPosX + bulletStep;
                nextPosY = bulletPosY;
            end

            default: begin
                nextPosX = bulletPosX;
                nextPosY = bulletPosY;
                $error("Unhandled direction in bullet direction control")
            end
        endcase
    end
end

// Registers for bullet position
always_ff @ (posedge frameClk) begin
    if (reset == 1'b1) begin
        bulletPosX <= '0;
        bulletPosY <= '0;
    end else begin
        bulletPosX <= nextPosX;
        bulletPosY <= nextPosY;
    end
end

// Bullet direction control logic
DIRECTION bulletDir, nextDir;
always_comb begin

    if (sigSpawn == 1'b1) begin
        nextDir = bulletStartDir;
    end

    // Change direction on bounce signal
    else if (bounce == 1'b1) begin
        unique case (dir)
            UP:    nextDir = DOWN;
            DOWN:  nextDir = UP;
            LEFT:  nextDir = RIGHT;
            RIGHT: nextDir = LEFT;

            default: begin
                nextDir = bulletDir;
                $error("Unhandled direction in bullet direction change logic")
            end
        endcase
    end

    // Maintain current direction unless bouncing
    else begin
        nextDir = bulletDir;
    end
end


// Register for bullet direction
always_ff @ (posedge frameClk) begin
    if (reset == 1'b1) begin
        bulletDir <= RIGHT;
    end else begin
        bulletDir <= nextDir;
    end
end


// Logic for bullet state tracking
always_ff @ (posedge frameClk) begin
    if (reset == 1'b1 || sigKill == 1'b1 || bounceCountNext >= bulletLife + 1) begin
        bulletExists <= 1'b0;
    end else if (sigSpawn == 1'b1)
        bulletExists <= 1'b1;
    end
end

// Logic for counting the number of bounces
logic [7:0] bounceCount, bounceCountNext;
always_ff @ (posedge frameClk) begin
    if (reset == 1'b1)
        bounceCount = '0;
    else
        bounceCount <= bounceCountNext;
end

always_comb begin
    bounceCountNext = bounceCount;
    if (sigSpawn = 1'b1)
        bounceCountNext = '0;
    else if (sigBounce = 1'b1)
        bounceCountNext = bounceCount + 1;
end

endmodule



module BulletMapper (
    input  logic [9:0] bulletPosX, bulletPosY,
    input  logic [9:0] pixelPosX, pixelPosY,
    input  logic [7:0] bulletRadius,
    output COLOR       bulletColor
);

always_comb begin
    // If the current pixel is within a box of radius bulletRadius centered at bulletPos
    // TODO: verify that this works even with overflow/underflow
    if (bulletPosX-bulletRadius <= pixelPosX && pixelPosX <= bulletPosX+bulletRadius
     && bulletPosY-bulletRadius <= pixelPosY && pixelPosY <= bulletPosY+bulletRadius) begin

        bulletColor = BULLET;
    end else begin
        bulletColor = BACKGROUND;
    end
end

endmodule
