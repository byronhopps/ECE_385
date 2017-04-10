/*---------------------------------------------------------------------------
  --      lab9.sv                                                          --
  --      Christine Chen                                                   --
  --      10/23/2013                                                       --
  --                                                                       --
  --      For use with ECE 298 Experiment 9                                --
  --      UIUC ECE Department                                              --
  ---------------------------------------------------------------------------*/
// Top-level module that integrates the Nios II system with the rest of the hardware

module lab9_profile(  input               CLOCK_50,
              input        [1:0]  KEY,
              input        [17:0] SW,
              output logic [7:0]  LEDG,
              output logic [17:0] LEDR,
              output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
              output logic [12:0] DRAM_ADDR,
              output logic [1:0]  DRAM_BA,
              output logic        DRAM_CAS_N,
              output logic        DRAM_CKE,
              output logic        DRAM_CS_N,
              inout  wire  [31:0] DRAM_DQ,
              output logic [3:0]  DRAM_DQM,
              output logic        DRAM_RAS_N,
              output logic        DRAM_WE_N,
              output logic        DRAM_CLK
              );

logic  [127:0] msg_en;
logic  [127:0] key;
logic  [127:0] msg_de;
logic          AESready;
logic          reset_n;
logic  [63:0] count, nextCount;

assign LEDG[7] = AESready;
assign reset_n = KEY[1];
assign clk = CLOCK_50;

assign msg_en = {4{32'hece298dc}};
assign key    = 128'h000102030405060708090a0b0c0d0e0f;

AES aes_0 (.clk, .reset_n, .ready(AESready), .run(1'b1),
    .msg_en, .key, .msg_de
);

logic [31:0] hexDisp;
always_comb begin
    case (SW[2:0])
        3'b000: hexDisp = {msg_en[127:112], msg_en[15:0]};
        3'b001: hexDisp = {key[127:112], key[15:0]};
        3'b010: hexDisp = {msg_de[127:112], msg_de[15:0]};
        3'b011: hexDisp = count[31: 0];
        3'b111: hexDisp = count[63:32];
        default: hexDisp = '0;
    endcase
end

always_ff @ (posedge clk) begin
    if (reset_n == 1'b0)
        count <= '0;
    else
        count <= nextCount;
end

always_comb begin 
    if (AESready == 1'b1)
        nextCount = count + 64'd1;
    else
        nextCount = count;
end

// Displays the first 4 and the last 4 digits of the received message
HexDriver Hex0 (.IN(hexDisp[ 3: 0]), .OUT(HEX0) );
HexDriver Hex1 (.IN(hexDisp[ 7: 4]), .OUT(HEX1) );
HexDriver Hex2 (.IN(hexDisp[11: 8]), .OUT(HEX2) );
HexDriver Hex3 (.IN(hexDisp[15:12]), .OUT(HEX3) );
HexDriver Hex4 (.IN(hexDisp[19:16]), .OUT(HEX4) );
HexDriver Hex5 (.IN(hexDisp[23:20]), .OUT(HEX5) );
HexDriver Hex6 (.IN(hexDisp[27:24]), .OUT(HEX6) );
HexDriver Hex7 (.IN(hexDisp[31:28]), .OUT(HEX7) );

endmodule
