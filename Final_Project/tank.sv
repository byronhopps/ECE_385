`include "Types.sv" 

module TankEntity (
    input  logic frameClk, tankReset,
    input  logic moveUp, moveDown, moveLeft, moveRight,
    input  logic sigKill, sigSpawn,

    input  logic [31:0] tankStep,
    input  logic [31:0] tankPosX, tankPosY,

    output DIRECTION    tankDir,
    output logic        tankExists,
    output logic [31:0] curPosX, curPosY,
    output logic [31:0] nextPosX, nextPosY 
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
);

endmodule
