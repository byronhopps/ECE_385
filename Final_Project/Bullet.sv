module Bullet (
    input  logic frameClk, reset_h,
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

logic sigKillInt, arenaEdgeCollide;
assign sigKillInt = (arenaEdgeCollide | sigKill) & bulletExists;

BulletEntity bulletEntity (
    .frameClk, .reset(reset_h), .sigKill(sigKillInt), .sigSpawn,
    .sigBounce(),
    .bulletStartDir, .bulletStep, .bulletLife,
    .bulletStartX, .bulletStartY,
    .bulletExists, .bulletPosX, .bulletPosY,
    .nextPosX, .nextPosY
);

logic [9:0] nextPosX, nextPosY;
ArenaEdgeDetect bulletEdgeDetect (
    .posX(nextPosX), .posY(nextPosY), .radius(bulletRadius),
    .collide(arenaEdgeCollide)
);

BulletMapper bulletMapper(
    .bulletPosX, .bulletPosY, .pixelPosX, .pixelPosY,
    .bulletExists, .bulletRadius, .bulletColor
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
    output logic [9:0] nextPosX, nextPosY
);

// Bullet movement control logic

enum logic [1:0] {DEAD, SPAWNED, MOVING, BOUNCE} state, nextState;

assign bulletExists = (state != DEAD);

// State transition logic
always_comb begin
    nextState = state;
    case (state)
        DEAD: if(sigSpawn) nextState = SPAWNED;
        SPAWNED: nextState = MOVING;

        MOVING: begin
            if (sigKill) begin
                nextState = DEAD;
            end else if (sigBounce) begin
                nextState = BOUNCE;
            end
        end

        BOUNCE: begin
            if (bounceCountNext > bulletLife) begin
                nextState = DEAD;
            end else begin
                nextState = MOVING;
            end
        end
    endcase
end

// Register for state
always_ff @ (posedge frameClk) begin
    if (reset == 1'b1) begin
        state <= DEAD;
    end else begin
        state <= nextState;
    end
end

// Logic for determining bullet position
always_comb begin
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
            $error("Unhandled direction in bullet direction control");
        end
    endcase
end

// Registers for bullet position
always_ff @ (posedge frameClk) begin
    if (reset == 1'b1) begin
        bulletPosX <= '0;
        bulletPosY <= '0;
    end else if (state == SPAWNED) begin
        bulletPosX <= bulletStartX;
        bulletPosY <= bulletStartY;
    end else if (state == DEAD) begin
        bulletPosX <= 10'd100;
        bulletPosY <= 10'd1000;
    end else begin
        bulletPosX <= nextPosX;
        bulletPosY <= nextPosY;
    end
end

// Bullet direction control logic
DIRECTION bulletDir, nextDir;
always_comb begin
    nextDir = bulletDir;
    case (state)
        DEAD: nextDir = bulletStartDir;
        SPAWNED: nextDir = bulletStartDir;
        MOVING: nextDir = bulletDir;
        BOUNCE: nextDir = bounceDir;
    endcase
end

DIRECTION bounceDir;
always_comb begin
    unique case (bulletDir)
        UP:    bounceDir = DOWN;
        DOWN:  bounceDir = UP;
        LEFT:  bounceDir = RIGHT;
        RIGHT: bounceDir = LEFT;

        default: begin
            nextDir = bulletDir;
            $error("Unhandled direction in bullet direction change logic");
        end
    endcase
end

// Register for bullet direction
always_ff @ (posedge frameClk) begin
    if (reset == 1'b1) begin
        bulletDir <= RIGHT;
    end else begin
        bulletDir <= nextDir;
    end
end

// Logic for counting the number of bounces
logic [7:0] bounceCount, bounceCountNext;
always_ff @ (posedge frameClk) begin
    if (reset == 1'b1) begin
        bounceCount <= '0;
    end else begin
        bounceCount <= bounceCountNext;
    end
end

always_comb begin
    case (state)
        DEAD: bounceCountNext = '0;
        SPAWNED: bounceCountNext = '0;
        MOVING: bounceCountNext = bounceCount;
        BOUNCE: bounceCountNext = bounceCount + 1'b1;
    endcase
end

endmodule



module BulletMapper (
    input  logic [9:0] bulletPosX, bulletPosY,
    input  logic [9:0] pixelPosX, pixelPosY,
    input  logic [7:0] bulletRadius,
    input  logic       bulletExists,
    output COLOR       bulletColor
);

always_comb begin
    // If the current pixel is within a box of radius bulletRadius centered at bulletPos
    // TODO: verify that this works even with overflow/underflow
    if (bulletExists == 1'b1
     && bulletPosX-bulletRadius <= pixelPosX && pixelPosX <= bulletPosX+bulletRadius
     && bulletPosY-bulletRadius <= pixelPosY && pixelPosY <= bulletPosY+bulletRadius) begin

        bulletColor = BULLET;
    end else begin
        bulletColor = BACKGROUND;
    end
end

endmodule



module BulletStartPos (
    input  DIRECTION tankDir,
    input  RECT      nextTankArea,
    input  RADIUS    bulletRadius,
    output POSITION  bulletStartPos
);

always_comb begin
    case (tankDir)
        UP: begin
            bulletStartPos.x = nextTankArea.center.x;
            bulletStartPos.y = nextTankArea.center.y - nextTankArea.radius.y - bulletRadius.y - 8'd1;
        end

        DOWN: begin
            bulletStartPos.x = nextTankArea.center.x;
            bulletStartPos.y = nextTankArea.center.y + nextTankArea.radius.y + bulletRadius.y + 8'd1;
        end

        LEFT: begin
            bulletStartPos.x = nextTankArea.center.x - nextTankArea.radius.x - bulletRadius.x - 8'd1;
            bulletStartPos.y = nextTankArea.center.y;
        end

        RIGHT: begin
            bulletStartPos.x = nextTankArea.center.x + nextTankArea.radius.x + bulletRadius.x + 8'd1;
            bulletStartPos.y = nextTankArea.center.y;
        end

        default: begin
            bulletStartPos.x = 0;
            bulletStartPos.y = 0;
        end
    endcase
end

endmodule
