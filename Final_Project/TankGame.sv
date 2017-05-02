module TankGame (
    input               CLOCK_50,
    input        [3:0]  KEY,          //bit 0 is set up as Reset
    input  logic [17:0] SW,
    output logic [8:0]  LEDG,
    output logic [17:0] LEDR,

    // VGA Interface
    output logic [7:0]  VGA_R,        //VGA Red
                        VGA_G,        //VGA Green
                        VGA_B,        //VGA Blue
    output logic        VGA_CLK,      //VGA Clock
                        VGA_SYNC_N,   //VGA Sync signal
                        VGA_BLANK_N,  //VGA Blank signal
                        VGA_VS,       //VGA virtical sync signal
                        VGA_HS,       //VGA horizontal sync signal

    // Hex displays
    output logic [6:0]  HEX4,         //Hex display 4
                        HEX5,         //Hex display 5
                        HEX6,         //Hex display 6
                        HEX7,         //Hex display 7

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
assign LEDG[8] = reset_h;

parameter screenSizeX = 640;
parameter screenSizeY = 480;

logic [7:0] tankControl [2];

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
    .button_wire_export(KEY),
    .led_wire_export(),
    .switch_wire_export(SW),
    .game_control_export(swGameControl),
    .game_status_export ({14'b0, tankExists[1], tankExists[0]}),
    .tank_control_export({tankControl[1], tankControl[0]}),
    .terrain_id_export(swTerrainID),
    .terrain_spawn_pos_export(swTerrainSpawnPos),
    .terrain_spawn_radius_export(swTerrainSpawnRadius),
    .tank_0_spawn_pos_export(swTank0SpawnPos),
    .tank_1_spawn_pos_export(swTank1SpawnPos)
);

// SW-HW game interface signals
logic [15:0] swGameControl;
logic [1:0]  tankScoreCount [2];
logic terrainSigSpawn, terrainSigKill, tankSigSpawn, tankSigKill;
logic bulletSigKill, sigPause;
assign tankSigSpawn      = swGameControl[0];
assign tankSigKill       = swGameControl[1];
assign bulletSigKill     = swGameControl[1];
assign terrainSigSpawn   = swGameControl[2];
assign terrainSigKill    = swGameControl[3];
assign sigPause          = swGameControl[8];
assign tankScoreCount[0] = swGameControl[5:4];
assign tankScoreCount[1] = swGameControl[7:6];


logic [31:0] swTank0SpawnPos, swTank1SpawnPos;
POSITION tankSpawnPos[2];
assign tankSpawnPos[0].x = swTank0SpawnPos[ 9: 0];
assign tankSpawnPos[0].y = swTank0SpawnPos[25:16];
assign tankSpawnPos[1].x = swTank1SpawnPos[ 9: 0];
assign tankSpawnPos[1].y = swTank1SpawnPos[25:16];

logic [7:0] swTerrainID;

RECT terrainSpawnArea;
logic [31:0] swTerrainSpawnPos, swTerrainSpawnRadius;
assign terrainSpawnArea.center = '{x:swTerrainSpawnPos[9:0],    y:swTerrainSpawnPos[25:16]};
assign terrainSpawnArea.radius = '{x:swTerrainSpawnRadius[9:0], y:swTerrainSpawnRadius[25:16]};


// Interface between NIOS II and EZ-OTG chip
logic [1:0] hpi_addr;
logic [15:0] hpi_data_in, hpi_data_out;
logic hpi_r, hpi_w,hpi_cs;

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

// Score counters
logic [7:0] tankScore[2];
logic scoreReset;
assign scoreReset = reset_h | ~KEY[3];

generate
    for (i = 0; i < 2; i = i + 1) begin : scoreDisplayGeneration
        ScoreCounter (
            .clk(CLOCK_50), .reset_h(scoreReset),
            .up(tankScoreCount[i][0]), .down(tankScoreCount[i][1]),
            .count(tankScore[i])
        );
    end
endgenerate

HexDriver (.IN(tankScore[1][3:0]), .OUT(HEX4));
HexDriver (.IN(tankScore[1][7:4]), .OUT(HEX5));
HexDriver (.IN(tankScore[0][3:0]), .OUT(HEX6));
HexDriver (.IN(tankScore[0][7:4]), .OUT(HEX7));

// Signal for current pixel being drawn
POSITION pixelPos;
logic  [9:0] xPixel, yPixel;
assign xPixel = pixelPos.x;
assign yPixel = pixelPos.y;

logic frameClk;
assign frameClk = (sigPause | SW[0]) ? 1'b0 : VGA_VS;

// Main VGA controller for design
VGA_controller vga_controller_instance(
    .Clk(CLOCK_50), .Reset(reset_h),
    .VGA_HS, .VGA_VS,
    .VGA_CLK,
    .VGA_BLANK_N,
    .VGA_SYNC_N,
    .DrawX(pixelPos.x), .DrawY(pixelPos.y)
);

logic tankExists [1:0];
logic bulletExists [1:0];
logic tankKill [1:0];
logic bulletKill [1:0];
logic bulletHitTank0 [1:0];
logic bulletHitTank1 [1:0];

assign LEDR = {18{tankExists[0]}};
assign LEDG[7:0] = {8{tankExists[1]}};

logic bulletCollideTank0[1:0];
logic bulletCollideTank1[1:0];

logic bulletHitBullet;
logic [9:0] curTankPosX [1:0];
logic [9:0] curTankPosY [1:0];
logic [9:0] nextTankPosX [1:0];
logic [9:0] nextTankPosY [1:0];
logic [7:0] tankRadius, bulletRadius;

assign tankRadius = 10;
assign bulletRadius = 3;

RADIUS tankRadiusPos;
assign tankRadiusPos.x = tankRadius;
assign tankRadiusPos.y = tankRadius;

DIRECTION tankDir [1:0];
COLOR tankPixelColor[1:0];
COLOR bulletPixelColor[1:0];

POSITION curTankPos [2];
assign curTankPos[0].x = curTankPosX[0];
assign curTankPos[1].x = curTankPosX[1];
assign curTankPos[0].y = curTankPosY[0];
assign curTankPos[1].y = curTankPosY[1];

RECT curTankEntity [2];
assign curTankEntity[0].center = curTankPos[0];
assign curTankEntity[1].center = curTankPos[1];
assign curTankEntity[0].radius = tankRadiusPos;
assign curTankEntity[1].radius = tankRadiusPos;

POSITION nextTankPos [2];
assign nextTankPos[0].x = nextTankPosX[0];
assign nextTankPos[1].x = nextTankPosX[1];
assign nextTankPos[0].y = nextTankPosY[0];
assign nextTankPos[1].y = nextTankPosY[1];

RECT nextTankEntity [2];
assign nextTankEntity[0].center = nextTankPos[0];
assign nextTankEntity[1].center = nextTankPos[1];
assign nextTankEntity[0].radius = tankRadiusPos;
assign nextTankEntity[1].radius = tankRadiusPos;

parameter numTanks = 2;

assign tankKill[0] = bulletHitTank0.or() | tankSigKill | ~KEY[2];
assign tankKill[1] = bulletHitTank1.or() | tankSigKill | ~KEY[2];

logic tankSpawn;
assign tankSpawn = tankSigSpawn | ~KEY[1];

// Assumed to be 1 in most of the game logic
parameter bulletsPerTank = 1;

logic sigStop[numTanks];

generate
    for (i = 0; i < numTanks; i = i + 1) begin : tankSignalAssignment
        assign sigStop[i] = tankTankCollide | tankWallCollide[i] | tankHitWater[i];

        assign bulletHitTank0[i] = bulletCollideTank0[i] & bulletExists[i];
        assign bulletHitTank1[i] = bulletCollideTank1[i] & bulletExists[i];

        assign bulletKill[i] = bulletHitTank0[i] | bulletHitTank1[i] | tankSpawn |
            | bulletHitWall[i] | bulletHitBullet | bulletSigKill | ~KEY[2];
    end
endgenerate

// Control hardware for tank 0
Tank tank_0 (
    .frameClk, .reset_h,
    .playerNumber(0),
    .moveUp(tankControl[0][2]), .moveDown(tankControl[0][1]),
    .moveLeft(tankControl[0][3]), .moveRight(tankControl[0][0]),
    .sigKill(tankKill[0]), .sigSpawn(tankSpawn), .sigStop(sigStop[0]),
    .pixelPosX(xPixel), .pixelPosY(yPixel),
    .spawnPosX(tankSpawnPos[0].x), .spawnPosY(tankSpawnPos[0].y),
    .tankStep(2), .tankRadius, .turretWidth(3),
    .tankDir(tankDir[0]), .tankColor(tankPixelColor[0]), .tankExists(tankExists[0]),
    .curPosX(curTankPosX[0]), .curPosY(curTankPosY[0]), .nextPosX(nextTankPosX[0]), .nextPosY(nextTankPosY[0])
);

// Control hardware for tank 1
Tank tank_1 (
    .frameClk, .reset_h,
    .playerNumber(1),
    .moveUp(tankControl[1][2]), .moveDown(tankControl[1][1]),
    .moveLeft(tankControl[1][3]), .moveRight(tankControl[1][0]),
    .sigKill(tankKill[1]), .sigSpawn(tankSpawn), .sigStop(sigStop[1]),
    .pixelPosX(xPixel), .pixelPosY(yPixel),
    .spawnPosX(tankSpawnPos[1].x), .spawnPosY(tankSpawnPos[1].y),
    .tankStep(2), .tankRadius, .turretWidth(3),
    .tankDir(tankDir[1]), .tankColor(tankPixelColor[1]), .tankExists(tankExists[1]),
    .curPosX(curTankPosX[1]), .curPosY(curTankPosY[1]), .nextPosX(nextTankPosX[1]), .nextPosY(nextTankPosY[1])
);


logic [9:0] bulletPosX [1:0];
logic [9:0] bulletPosY [1:0];

POSITION bulletPos [numTanks];
RECT    bulletArea [numTanks];
generate
    for (i = 0; i < numTanks; i = i + 1) begin : bulletPosAssignment
        assign bulletPos[i].x = bulletPosX[i];
        assign bulletPos[i].y = bulletPosY[i];

        assign bulletArea[i].center = bulletPos[i];
        assign bulletArea[i].radius = '{bulletRadius, bulletRadius};
    end
endgenerate

logic bulletSpawn [numTanks];
generate
    for (i = 0; i < numTanks; i = i + 1) begin : bulletSpawnGeneration
        assign bulletSpawn[i] = tankControl[i][4] & tankExists[i];
    end
endgenerate

// NOTE: sigSpawn should only work when tank exists
Bullet bullet0_0 (
    .frameClk, .reset_h,
    .sigKill(bulletKill[0]), .sigSpawn(bulletSpawn[0]), .sigBounce(),
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
    .sigKill(bulletKill[1]), .sigSpawn(bulletSpawn[1]), .sigBounce(),
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
    .posX1(bulletPosX[0]), .posY1(bulletPosY[0]),
    .radiusX1(bulletRadius), .radiusY1(bulletRadius),
    .collide(bulletCollideTank0[0])
);

// Bullet 0 from tank 1 hitting tank 0 collision detection
EntityCollisionDetect bullet10_tank0 (
    .posX0(curTankPosX[0]), .posY0(curTankPosY[0]),
    .radiusX0(tankRadius), .radiusY0(tankRadius),
    .posX1(bulletPosX[1]), .posY1(bulletPosY[1]),
    .radiusX1(bulletRadius), .radiusY1(bulletRadius),
    .collide(bulletCollideTank0[1])
);

// Bullet 0 from tank 0 hitting tank 1 collision detection
EntityCollisionDetect bullet00_tank1 (
    .posX0(curTankPosX[1]), .posY0(curTankPosY[1]),
    .radiusX0(tankRadius), .radiusY0(tankRadius),
    .posX1(bulletPosX[0]), .posY1(bulletPosY[0]),
    .radiusX1(bulletRadius), .radiusY1(bulletRadius),
    .collide(bulletCollideTank1[0])
);

// Bullet 0 from tank 1 hitting tank 1 collision detection
EntityCollisionDetect bullet10_tank1 (
    .posX0(curTankPosX[1]), .posY0(curTankPosY[1]),
    .radiusX0(tankRadius), .radiusY0(tankRadius),
    .posX1(bulletPosX[1]), .posY1(bulletPosY[1]),
    .radiusX1(bulletRadius), .radiusY1(bulletRadius),
    .collide(bulletCollideTank1[1])
);

// Bullet-on-bullet collision detection
EntityCollisionDetect bullet00_bullet10 (
    .posX0(bulletPosX[0]), .posY0(bulletPosY[0]),
    .radiusX0(bulletRadius), .radiusY0(bulletRadius),
    .posX1(bulletPosX[1]), .posY1(bulletPosY[1]),
    .radiusX1(bulletRadius), .radiusY1(bulletRadius),
    .collide(bulletHitBullet)
);

logic tankTankCollide;
DetectCollision tank0_tank1 (
    .A(nextTankEntity[0]), .B(nextTankEntity[1]),
    .collision(tankTankCollide)
);


logic [9:0] bulletStartX [1:0];
logic [9:0] bulletStartY [1:0];

generate
    for (i = 0; i < numTanks; i = i + 1) begin : bulletStartPosGeneration
        BulletStartPos bullet1Start (
            .tankDir(tankDir[i]), .nextTankArea(nextTankEntity[i]),
            .bulletRadius(bulletArea[i].radius), .bulletStartPos('{bulletStartX[i], bulletStartY[i]})
        );
    end
endgenerate


parameter numWalls  = 20;
parameter numWater  = 10;
parameter numJungle = 10;

logic wallPixelValid   [numWalls];
logic waterPixelValid  [numWater];
logic junglePixelValid [numJungle];

COLOR wallPixelColor   [numWalls];
COLOR waterPixelColor  [numWater];
COLOR junglePixelColor [numJungle];

logic wallExists  [numWalls];
logic waterExists [numWater];

RECT wallArea  [numWalls];
RECT waterArea [numWater];

parameter logic [7:0] jungleTerrainID [numJungle] = '{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
parameter logic [7:0] waterTerrainID  [numWater]  = '{10,11,12,13,14,15,16,17,18,19};
parameter logic [7:0] wallTerrainID   [numWalls]  = '{20,21,22,23,24,25,26,27,28,29,
                                                      30,31,32,33,34,35,36,37,38,39};

generate
    genvar i;
    for (i = 0; i < numWalls; i = i + 1) begin : wallGeneration
        WallTerrain #(wallTerrainID[i]) wallTerrain (
            .clk(CLOCK_50), .reset_h,
            .sigSpawn(terrainSigSpawn), .sigKill(terrainSigKill), .terrainID(swTerrainID),
            .spawnArea(terrainSpawnArea), .pixelPos,
            .pixelValid(wallPixelValid[i]), .pixelColor(wallPixelColor[i]),
            .wallExists(wallExists[i]), .wallArea(wallArea[i])
        );
    end

    for (i = 0; i < numWater; i = i + 1) begin : waterGeneration
        WaterTerrain #(waterTerrainID[i]) waterTerrain (
            .clk(CLOCK_50), .reset_h,
            .sigSpawn(terrainSigSpawn), .sigKill(terrainSigKill), .terrainID(swTerrainID),
            .spawnArea(terrainSpawnArea), .pixelPos, .waterArea(waterArea[i]),
            .waterExists(waterExists[i]), .pixelValid(waterPixelValid[i]),
            .pixelColor(waterPixelColor[i])
        );
    end

    for (i = 0; i < numJungle; i = i + 1) begin : jungleGeneration
        JungleTerrain #(jungleTerrainID[i]) jungle (
            .clk(CLOCK_50), .reset_h,
            .sigSpawn(terrainSigSpawn), .sigKill(terrainSigKill),
            .terrainID(swTerrainID), .spawnArea(terrainSpawnArea),
            .pixelPos, .pixelValid(junglePixelValid[i]), .pixelColor(junglePixelColor[i])
        );
    end

    logic tankWallCollide [numTanks];
    logic bulletHitWall   [numTanks];
    logic tankHitWater    [numTanks];

    for (i = 0; i < numTanks; i = i + 1) begin : tankWallCollisionGeneration
        ObstacleCollisionDetect #(numWalls) tankOnWall (
            .sysClk(CLOCK_50), .frameClk, .reset_h,
            .entityArea(nextTankEntity[i]), .obstacleArea(wallArea),
            .obstacleExists(wallExists),
            .sigCollide(tankWallCollide[i]), .done()
        );

        ObstacleCollisionDetect #(numWater) tankOnWater (
            .sysClk(CLOCK_50), .frameClk, .reset_h,
            .entityArea(nextTankEntity[i]), .obstacleArea(waterArea),
            .obstacleExists(waterExists),
            .sigCollide(tankHitWater[i]), .done()
        );

        ObstacleCollisionDetect #(numWalls) bulletOnWall (
            .sysClk(CLOCK_50), .frameClk, .reset_h,
            .entityArea(bulletArea[i]), .obstacleArea(wallArea),
            .obstacleExists(wallExists), .sigCollide(bulletHitWall[i]), .done()
        );
    end
endgenerate

always_comb begin
    if (wallPixelValid[0]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[0];
    end else if (wallPixelValid[1]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[1];
    end else if (wallPixelValid[2]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[2];
    end else if (wallPixelValid[3]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[3];
    end else if (wallPixelValid[4]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[4];
    end else if (wallPixelValid[5]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[5];
    end else if (wallPixelValid[6]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[6];
    end else if (wallPixelValid[7]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[7];
    end else if (wallPixelValid[8]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[8];
    end else if (wallPixelValid[9]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[9];
    end else if (wallPixelValid[10]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[10];
    end else if (wallPixelValid[11]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[11];
    end else if (wallPixelValid[12]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[12];
    end else if (wallPixelValid[13]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[13];
    end else if (wallPixelValid[14]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[14];
    end else if (wallPixelValid[15]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[15];
    end else if (wallPixelValid[16]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[16];
    end else if (wallPixelValid[17]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[17];
    end else if (wallPixelValid[18]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[18];
    end else if (wallPixelValid[19]) begin
        {VGA_R, VGA_G, VGA_B} = wallPixelColor[19];
    end

    else if (junglePixelValid[0]) begin
        {VGA_R, VGA_G, VGA_B} = junglePixelColor[0];
    end else if (junglePixelValid[1]) begin
        {VGA_R, VGA_G, VGA_B} = junglePixelColor[1];
    end else if (junglePixelValid[2]) begin
        {VGA_R, VGA_G, VGA_B} = junglePixelColor[2];
    end else if (junglePixelValid[3]) begin
        {VGA_R, VGA_G, VGA_B} = junglePixelColor[3];
    end else if (junglePixelValid[4]) begin
        {VGA_R, VGA_G, VGA_B} = junglePixelColor[4];
    end else if (junglePixelValid[5]) begin
        {VGA_R, VGA_G, VGA_B} = junglePixelColor[5];
    end else if (junglePixelValid[6]) begin
        {VGA_R, VGA_G, VGA_B} = junglePixelColor[6];
    end else if (junglePixelValid[7]) begin
        {VGA_R, VGA_G, VGA_B} = junglePixelColor[7];
    end else if (junglePixelValid[8]) begin
        {VGA_R, VGA_G, VGA_B} = junglePixelColor[8];
    end else if (junglePixelValid[9]) begin
        {VGA_R, VGA_G, VGA_B} = junglePixelColor[9];
    end

    else if (bulletPixelColor[0] != BACKGROUND && bulletExists[0]) begin
        {VGA_R, VGA_G, VGA_B} = bulletPixelColor[0];
    end else if (bulletPixelColor[1] != BACKGROUND && bulletExists[1]) begin
        {VGA_R, VGA_G, VGA_B} = bulletPixelColor[1];

    end

    else if (waterPixelValid[0]) begin
        {VGA_R, VGA_G, VGA_B} = waterPixelColor[0];
    end else if (waterPixelValid[1]) begin
        {VGA_R, VGA_G, VGA_B} = waterPixelColor[1];
    end else if (waterPixelValid[2]) begin
        {VGA_R, VGA_G, VGA_B} = waterPixelColor[2];
    end else if (waterPixelValid[3]) begin
        {VGA_R, VGA_G, VGA_B} = waterPixelColor[3];
    end else if (waterPixelValid[4]) begin
        {VGA_R, VGA_G, VGA_B} = waterPixelColor[4];
    end else if (waterPixelValid[5]) begin
        {VGA_R, VGA_G, VGA_B} = waterPixelColor[5];
    end else if (waterPixelValid[6]) begin
        {VGA_R, VGA_G, VGA_B} = waterPixelColor[6];
    end else if (waterPixelValid[7]) begin
        {VGA_R, VGA_G, VGA_B} = waterPixelColor[7];
    end else if (waterPixelValid[8]) begin
        {VGA_R, VGA_G, VGA_B} = waterPixelColor[8];
    end else if (waterPixelValid[9]) begin
        {VGA_R, VGA_G, VGA_B} = waterPixelColor[9];
    end

    else if (tankPixelColor[0] != BACKGROUND && tankExists[0]) begin
        {VGA_R, VGA_G, VGA_B} = tankPixelColor[0];
    end else if (tankPixelColor[1] != BACKGROUND && tankExists[1]) begin
        {VGA_R, VGA_G, VGA_B} = tankPixelColor[1];
    end else begin
        {VGA_R, VGA_G, VGA_B} = BACKGROUND;
    end
end

endmodule
