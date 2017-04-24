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
assign LEDG = 0;

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
    .OTG_DATA(OTG_DATA),
    .OTG_ADDR(OTG_ADDR),
    .OTG_RD_N(OTG_RD_N),
    .OTG_WR_N(OTG_WR_N),
    .OTG_CS_N(OTG_CS_N),
    .OTG_RST_N(OTG_RST_N)
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

logic moveUp, moveDown, moveLeft, moveRight, shoot;
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

assign moveUp = SW[1];
assign moveDown = SW[2];
assign moveLeft = SW[3];
assign moveRight = SW[4];

logic tankExists, bulletExists;
logic [9:0] curTankPosX, curTankPosY;
logic [9:0] nextTankPosX, nextTankPosY;
logic [7:0] tankRadius, bulletRadius;
assign tankRadius = 10;
assign bulletRadius = 3;

// Control hardware for tank 0
Tank tank_0 (
    .frameClk, .reset_h,
    .moveUp, .moveDown, .moveLeft, .moveRight,
    .sigKill(~KEY[2]), .sigSpawn(~KEY[1]), .sigStop,
    .pixelPosX(xPixel), .pixelPosY(yPixel),
    .spawnPosX(50), .spawnPosY(50),
    .tankStep(2), .tankRadius, .turretWidth(3),
    .tankDir, .tankColor(tankPixelColor), .tankExists,
    .curPosX(curTankPosX), .curPosY(curTankPosY), .nextPosX(nextTankPosX), .nextPosY(nextTankPosY)
);

logic sigStop;
always_comb begin
    sigStop = 0;

    if ((nextTankPosX <= tankRadius) || (nextTankPosX >= screenSizeX - tankRadius)) begin
        sigStop = 1;
    end

    if ((nextTankPosY <= tankRadius) || (nextTankPosY >= screenSizeY - tankRadius)) begin
        sigStop = 1;
    end
end

DIRECTION tankDir;
COLOR tankPixelColor, bulletPixelColor;

logic [9:0] bulletPosX, bulletPosY;

// NOTE: sigSpawn should only work when tank exists
Bullet bullet0_0 (
    .frameClk, .reset_h,
    // .sigSpawn(shoot)
    .sigKill(~KEY[3]), .sigSpawn(SW[0]), .sigBounce,
    .bulletStartDir(tankDir),
    .bulletRadius,
    .bulletStep(7), .bulletLife(2),
    .pixelPosX(xPixel), .pixelPosY(yPixel),
    .bulletStartX, .bulletStartY,
    .bulletExists,
    .bulletPosX, .bulletPosY,
    .bulletColor(bulletPixelColor)
);

logic sigBounce;
always_comb begin
    sigBounce = 0;

    if ((bulletPosX <= bulletRadius) || (bulletPosX >= screenSizeX - bulletRadius)) begin
        sigBounce = 1;
    end

    if ((bulletPosY <= bulletRadius) || (bulletPosY >= screenSizeY - bulletRadius)) begin
        sigBounce = 1;
    end
end

logic [9:0] bulletStartX, bulletStartY;
always_comb begin
    case (tankDir)
        UP: begin
            bulletStartX = curTankPosX;
            bulletStartY = curTankPosY - tankRadius - bulletRadius;
        end

        DOWN: begin
            bulletStartX = curTankPosX;
            bulletStartY = curTankPosY + tankRadius + bulletRadius;
        end

        LEFT: begin
            bulletStartX = curTankPosX - tankRadius - bulletRadius;
            bulletStartY = curTankPosY;
        end

        RIGHT: begin
            bulletStartX = curTankPosX + tankRadius + bulletRadius;
            bulletStartY = curTankPosY;
        end

        default: begin
            bulletStartX = 0;
            bulletStartY = 0;
        end
    endcase
end

always_comb begin
    if (bulletPixelColor != BACKGROUND && bulletExists) begin
        {VGA_R, VGA_G, VGA_B} = bulletPixelColor;
    end else if (tankExists) begin
        {VGA_R, VGA_G, VGA_B} = tankPixelColor;
    end else begin
        {VGA_R, VGA_G, VGA_B} = BACKGROUND;
    end
end

endmodule
