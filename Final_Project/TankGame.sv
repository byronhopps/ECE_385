module TankGame (
    input               CLOCK_50,
    input        [3:0]  KEY,          //bit 0 is set up as Reset
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

// TODO: Add SOC to design


// Signal for current pixel being drawn
logic [9:0] xPixel, yPixel;
logic frameClk;
assign frameClk = VGA_VS;

// Main VGA controller for design
VGA_controller vga_controller_instance(
    .Clk, .Reset(Reset_h),
    .VGA_HS, .VGA_VS,
    .VGA_CLK,
    .VGA_BLANK_N,
    .VGA_SYNC_N,
    .DrawX(xPixel), .DrawY(yPixel)
);

// Control hardware for tank 0
TankEntity tank_0 (
    .frameClk, .tankReset(),
    .moveUp(), .moveDown(), .moveLeft(), .moveRight(),
    .tankStep(10), .tankDir(), .tankExists()
    .tankPosX(), .tankPosY(),
    .curPosX(), .curPosY(),
    .nextPosX(), .nextPosY()
);


endmodule
