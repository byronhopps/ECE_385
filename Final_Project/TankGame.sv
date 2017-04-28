module TankGame (
    input               CLOCK_50,
    input        [3:0]  KEY,          //bit 0 is set up as Reset
    input  logic [17:0] SW,
    output logic [7:0]  LEDG,

    // VGA Interface
    output logic [7:0]  VGA_R,        //VGA Red
                        VGA_G,        //VGA Green
                        VGA_B,        //VGA Blue
    output logic        VGA_CLK,      //VGA Clock
                        VGA_SYNC_N,   //VGA Sync signal
                        VGA_BLANK_N,  //VGA Blank signal
                        VGA_VS,       //VGA virtical sync signal
                        VGA_HS,       //VGA horizontal sync signal

    // CY7C67200 Interface
    inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
    output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
    output logic        OTG_CS_N,     //CY7C67200 Chip Select
                        OTG_RD_N,     //CY7C67200 Write
                        OTG_WR_N,     //CY7C67200 Read
                        OTG_RST_N,    //CY7C67200 Reset
    input               OTG_INT,      //CY7C67200 Interrupt

    // SDRAM Interface for Nios II Software
    output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
    inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
    output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
    output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
    output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                        DRAM_CAS_N,   //SDRAM Column Address Strobe
                        DRAM_CKE,     //SDRAM Clock Enable
                        DRAM_WE_N,    //SDRAM Write Enable
                        DRAM_CS_N,    //SDRAM Chip Select
                        DRAM_CLK      //SDRAM Clock
);

logic [15:0] keycode;

logic reset_n, reset_h;
assign reset_n = KEY[0];
assign reset_h = ~reset_n;
assign LEDG[0] = reset_h;

parameter screenSizeX = 640;
parameter screenSizeY = 480;

TankGame_soc soc (
    .clk_clk(CLOCK_50),
    .reset_reset_n(reset_n),
    .sdram_wire_addr(DRAM_ADDR),
    .sdram_wire_ba(DRAM_BA),
    .sdram_wire_cas_n(DRAM_CAS_N),
    .sdram_wire_cke(DRAM_CKE),
    .sdram_wire_cs_n(DRAM_CS_N),
    .sdram_wire_dq(DRAM_DQ),
    .sdram_wire_dqm(DRAM_DQM),
    .sdram_wire_ras_n(DRAM_RAS_N),
    .sdram_wire_we_n(DRAM_WE_N),
    .sdram_out_clk(DRAM_CLK),
    .otg_hpi_addr_export(hpi_addr),
    .otg_hpi_data_in_port(hpi_data_in),
    .otg_hpi_data_out_port(hpi_data_out),
    .otg_hpi_cs_export(hpi_cs),
    .otg_hpi_r_export(hpi_r),
    .otg_hpi_w_export(hpi_w),
    .keycode_export(keycode),
    .button_wire_export(),
    .led_wire_export(),
    .switch_wire_export()
);

logic [1:0] hpi_addr;
logic [15:0] hpi_data_in, hpi_data_out;
logic hpi_r, hpi_w,hpi_cs;

// Interface between NIOS II and EZ-OTG chip
hpi_io_intf hpi_io_inst(
    .Clk(CLOCK_50),
    .Reset(reset_h),

    // signals connected to NIOS II
    .from_sw_address(hpi_addr),
    .from_sw_data_in(hpi_data_in),
    .from_sw_data_out(hpi_data_out),
    .from_sw_r(hpi_r),
    .from_sw_w(hpi_w),
    .from_sw_cs(hpi_cs),

    // signals connected to EZ-OTG chip
    .OTG_DATA,
    .OTG_ADDR,
    .OTG_RD_N,
    .OTG_WR_N,
    .OTG_CS_N,
    .OTG_RST_N
);

// Signal for current pixel being drawn
logic [9:0] xPixel, yPixel;
logic frameClk;
assign frameClk = VGA_VS;

// Main VGA controller for design
VGA_controller vga_controller_instance(
    .Clk(CLOCK_50), .Reset(reset_h),
    .VGA_HS, .VGA_VS,
    .VGA_CLK,
    .VGA_BLANK_N,
    .VGA_SYNC_N,
    .DrawX(xPixel), .DrawY(yPixel)
);

//logic moveUp, moveDown, moveLeft, moveRight, shoot;
/* always_comb begin */
/*     moveUp = 0;   moveDown = 0; */
/*     moveLeft = 0; moveRight = 0; */
/*     shoot = 0; */
/*     case (keycode) */
/*         26: moveUp = 1; */
/*         22: moveDown = 1; */
/*         04: moveLeft = 1; */
/*         07: moveRight = 1; */
/*         44: shoot = 1; */
/*         default: begin end */
/*     endcase */
/* end */

logic tankExists [1:0];
logic bulletExists [1:0];
logic tankKill [1:0];
logic bulletKill [1:0];
logic bulletHitTank0 [1:0]
logic bulletHitTank1 [1:0]
logic bulletHitBullet;
logic [9:0] curTankPosX [1:0];
logic [9:0] curTankPosY [1:0];
logic [7:0] tankRadius, bulletRadius;

assign tankRadius = 10;
assign bulletRadius = 3;

assign tankKill[0] = bulletHitTank0[0] | bulletHitTank0[1] | ~KEY[2];
assign tankKill[1] = bulletHitTank1[0] | bulletHitTank1[1] | ~KEY[2];
assign bulletKill[0] = bulletHitTank0[0] | bulletHitTank1[0] | bulletHitBullet | ~KEY[2] | ~KEY[3];
assign bulletKill[1] = bulletHitTank0[1] | bulletHitTank1[1] | bulletHitBullet | ~KEY[2] | ~KEY[3];

DIRECTION tankDir [1:0];
COLOR tankPixelColor[1:0];
COLOR bulletPixelColor[1:0];

// Control hardware for tank 0
Tank tank_0 (
    .frameClk, .reset_h,
    .playerNumber(0),
    .moveUp(SW[3]), .moveDown(SW[2]), .moveLeft(SW[4]), .moveRight(SW[1]),
    .sigKill(tankKill[0]), .sigSpawn(~KEY[1]), .sigStop(),
    .pixelPosX(xPixel), .pixelPosY(yPixel),
    .spawnPosX(50), .spawnPosY(50),
    .tankStep(2), .tankRadius, .turretWidth(3),
    .tankDir(tankDir[0]), .tankColor(tankPixelColor[0]), .tankExists(tankExists[0]),
    .curPosX(curTankPosX[0]), .curPosY(curTankPosY[0]), .nextPosX(), .nextPosY()
);

// Control hardware for tank 1
Tank tank_1 (
    .frameClk, .reset_h,
    .playerNumber(1),
    .moveUp(SW[16]), .moveDown(SW[15]), .moveLeft(SW[17]), .moveRight(SW[14]),
    .sigKill(tankKill[1]), .sigSpawn(~KEY[1]), .sigStop(),
    .pixelPosX(xPixel), .pixelPosY(yPixel),
    .spawnPosX(590), .spawnPosY(430),
    .tankStep(2), .tankRadius, .turretWidth(3),
    .tankDir(tankDir[1]), .tankColor(tankPixelColor[1]), .tankExists(tankExists[1]),
    .curPosX(curTankPosX[1]), .curPosY(curTankPosY[1]), .nextPosX(), .nextPosY()
);


logic [9:0] bulletPosX [1:0];
logic [9:0] bulletPosY [1:0];

// NOTE: sigSpawn should only work when tank exists
Bullet bullet0_0 (
    .frameClk, .reset_h,
    .sigKill(~KEY[3]), .sigSpawn(SW[0]), .sigBounce(),
    .bulletStartDir(tankDir[0]),
    .bulletRadius,
    .bulletStep(7), .bulletLife(3),
    .pixelPosX(xPixel), .pixelPosY(yPixel),
    .bulletStartX(bulletStartX[0]), .bulletStartY(bulletStartY[0]),
    .bulletExists(bulletExists[0]),
    .bulletPosX(bulletPosX[0]), .bulletPosY(bulletPosY[0]),
    .bulletColor(bulletPixelColor[0])
);

// NOTE: sigSpawn should only work when tank exists
Bullet bullet1_0 (
    .frameClk, .reset_h,
    .sigKill(~KEY[3]), .sigSpawn(SW[13]), .sigBounce(),
    .bulletStartDir(tankDir[1]),
    .bulletRadius,
    .bulletStep(7), .bulletLife(3),
    .pixelPosX(xPixel), .pixelPosY(yPixel),
    .bulletStartX(bulletStartX[1]), .bulletStartY(bulletStartY[1]),
    .bulletExists(bulletExists[1]),
    .bulletPosX(bulletPosX[1]), .bulletPosY(bulletPosY[1]),
    .bulletColor(bulletPixelColor[1])
);

// Bullet 0 from tank 0 hitting tank 0 collision detection
EntityCollisionDetect bullet00_tank0 (
    .posX0(curTankPosX[0]), .posY0(curTankPosY[0]),
    .radiusX0(tankRadius), .radiusY0(tankRadius),
    .poxX1(bulletPosX[0]), .posY1(bulletPosY[0]),
    .radiusX1(bulletRadius), .radiusY1(bulletRadius),
    .collide(bulletHitTank0[0])
);

// Bullet 0 from tank 1 hitting tank 0 collision detection
EntityCollisionDetect bullet10_tank0 (
    .posX0(curTankPosX[0]), .posY0(curTankPosY[0]),
    .radiusX0(tankRadius), .radiusY0(tankRadius),
    .poxX1(bulletPosX[1]), .posY1(bulletPosY[1]),
    .radiusX1(bulletRadius), .radiusY1(bulletRadius),
    .collide(bulletHitTank0[1])
);

// Bullet 0 from tank 0 hitting tank 1 collision detection
EntityCollisionDetect bullet00_tank1 (
    .posX0(curTankPosX[1]), .posY0(curTankPosY[1]),
    .radiusX0(tankRadius), .radiusY0(tankRadius),
    .poxX1(bulletPosX[0]), .posY1(bulletPosY[0]),
    .radiusX1(bulletRadius), .radiusY1(bulletRadius),
    .collide(bulletHitTank1[0])
);

// Bullet 0 from tank 1 hitting tank 1 collision detection
EntityCollisionDetect bullet10_tank1 (
    .posX0(curTankPosX[1]), .posY0(curTankPosY[1]),
    .radiusX0(tankRadius), .radiusY0(tankRadius),
    .poxX1(bulletPosX[1]), .posY1(bulletPosY[1]),
    .radiusX1(bulletRadius), .radiusY1(bulletRadius),
    .collide(bulletHitTank1[1])
);

// Bullet-on-bullet collision detection
EntityCollisionDetect bullet00_bullet10 (
    .posX0(bulletPosX[0]), .posY0(bulletPosY[0]),
    .radiusX0(bulletRadius), .radiusY0(bulletRadius),
    .posX1(bulletPosX[1]), .posY1(bulletPosY[1]),
    .radiusX1(bulletRadius), .radiusY1(bulletRadius),
    .collide(bulletHitBullet)
);

logic [9:0] bulletStartX [1:0];
logic [9:0] bulletStartY [1:0];

always_comb begin
    case (tankDir[1])
        UP: begin
            bulletStartX[1] = curTankPosX[1];
            bulletStartY[1] = curTankPosY[1] - tankRadius - bulletRadius;
        end

        DOWN: begin
            bulletStartX[1] = curTankPosX[1];
            bulletStartY[1] = curTankPosY[1] + tankRadius + bulletRadius;
        end

        LEFT: begin
            bulletStartX[1] = curTankPosX[1] - tankRadius - bulletRadius;
            bulletStartY[1] = curTankPosY[1];
        end

        RIGHT: begin
            bulletStartX[1] = curTankPosX[1] + tankRadius + bulletRadius;
            bulletStartY[1] = curTankPosY[1];
        end

        default: begin
            bulletStartX[1] = 0;
            bulletStartY[1] = 0;
        end
    endcase
end


always_comb begin
    case (tankDir[0])
        UP: begin
            bulletStartX[0] = curTankPosX[0];
            bulletStartY[0] = curTankPosY[0] - tankRadius - bulletRadius;
        end

        DOWN: begin
            bulletStartX[0] = curTankPosX[0];
            bulletStartY[0] = curTankPosY[0] + tankRadius + bulletRadius;
        end

        LEFT: begin
            bulletStartX[0] = curTankPosX[0] - tankRadius - bulletRadius;
            bulletStartY[0] = curTankPosY[0];
        end

        RIGHT: begin
            bulletStartX[0] = curTankPosX[0] + tankRadius + bulletRadius;
            bulletStartY[0] = curTankPosY[0];
        end

        default: begin
            bulletStartX[0] = 0;
            bulletStartY[0] = 0;
        end
    endcase
end

logic junglePixelValid;
COLOR junglePixelColor;
JungleTerrain (#1) jungle (
    .frameClk, .reset_h,
    .sigSpawn(~KEY[1]), .sigKill(~KEY[2]), .terrainID(1),
    .spawnPosX(300), .spawnPosY(200), .spawnRadiusX(100), .spawnRadiusY(200),
    .pixelPosX(xPixel), .pixelPosY(.yPixel),
    .pixelValid(junglePixelValid), .pixelColor(junglePixelColor)
);

always_comb begin
    if (junglePixelValid)
        {VGA_R, VGA_G, VGA_B} = junglePixelColor;
    end else if (bulletPixelColor[0] != BACKGROUND && bulletExists[0]) begin
        {VGA_R, VGA_G, VGA_B} = bulletPixelColor[0];
    end else if (bulletPixelColor[1] != BACKGROUND && bulletExists[1]) begin
        {VGA_R, VGA_G, VGA_B} = bulletPixelColor[1];
    end else if (tankPixelColor[0] != BACKGROUND && tankExists[0]) begin
        {VGA_R, VGA_G, VGA_B} = tankPixelColor[0];
    end else if (tankPixelColor[1] != BACKGROUND && tankExists[1]) begin
        {VGA_R, VGA_G, VGA_B} = tankPixelColor[1];
    end else begin
        {VGA_R, VGA_G, VGA_B} = BACKGROUND;
    end
end

endmodule
