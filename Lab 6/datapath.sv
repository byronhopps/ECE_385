module datapath (
    input logic Clk, Reset,
    input logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED,
    input logic GatePC, GateMDR, GateALU, GateMARMUX,
    input logic [1:0] PCMUX, ADDR2MUX, ALUK,
    input logic DRMUX, SR1MUX, SR2MUX, ADDR1MUX,
    input logic [15:0] MDR_In,

    output logic [15:0] MDR, MAR, IR,
    output logic [11:0] LED,
    output logic BEN
);

    // ------------------
    // Signal Definitions
    // ------------------

    // Define registers and register inputs
    logic [15:0] PC, PCnext;
    logic [15:0] MDRnext;
    logic N, Z, P;

    // Define main data bus
    logic [15:0] mainBus;

    // Define and assign MARMUX
    logic [15:0] MARMUX, MARMUX1, MARMUX2;
    assign MARMUX = MARMUX1 + MARMUX2;

    // Define SR1, SR2, and DR mux outputs
    logic [3:0] DR;
    logic [2:0] SR1;
    logic [15:0] SR2MUX_OUT;

    // Define register file outputs
    logic [15:0] SR1_OUT, SR2_OUT;

    // Define ALU output
    logic [15:0] ALU_OUT;

    // ----------
    // Assertions
    // ----------

    // Assert that only one of the gates can be high at any time
    //assert property (!({GatePC, GateMDR, GateALU, GateMARMUX} & ({GatePC, GateMDR, GateALU, GateMARMUX} - 1)))
    //    else $error("Improper gateing of main CPU bus");

    // -------
    // Modules
    // -------

    regFile register_file (.Clk, .mainBus, .DR, .SR1, .SR2(IR[2:0]), .LD_REG, .SR1_OUT, .SR2_OUT);
    ALU ALU_MAIN (.A(SR1_OUT), .B(SR2MUX_OUT), .ALUK, .OUT(ALU_OUT));

    register_16 PCreg (.Clk, .Reset, .LD(LD_PC), .In(PCnext), .Out(PC));
    register_16 IRreg (.Clk, .Reset, .LD(LD_IR), .In(mainBus), .Out(IR));
    register_16 MDRreg (.Clk, .Reset, .LD(LD_MDR), .In(MDR_In), .Out(MDR));
    register_16 MARreg (.Clk, .Reset, .LD(LD_MAR), .In(mainBus), .Out(MAR));

    initial begin
        PC = 0;
        IR = 0;
        MAR = '1;
        LED = 0;
        BEN = 0;
    end

    // Update registers on clock edge when load is asserted
    always_ff @ (posedge Clk) begin

        // Update value of CC
        if (LD_CC == 1) begin
            // TODO: Verify this works
            P = (mainBus > 0);
            Z = (mainBus == 0);
            N = (mainBus < 0);
        end
        // Assuming that state is preserved

        // Update value of BEN
        if (LD_BEN == 1)
            BEN <= ((IR[11] & N) | (IR[10] & Z) | (IR[9] & P));
        else
            BEN <= BEN;

        if (LD_LED == 1)
            LED <= IR[11:0];
        else
            LED <= LED;
    end

    // Multiplexers for various functions
    always_comb begin

        // Data bus mux
        case ({GatePC, GateMDR, GateALU, GateMARMUX})
            4'b1000 : mainBus = PC;
            4'b0100 : mainBus = MDR;
            4'b0010 : mainBus = ALU_OUT;
            4'b0001 : mainBus = MARMUX;
            default : begin
                mainBus = '0;
                $error("Unspecified output on main bus");
            end
        endcase

        // PC mux
        case (PCMUX)
            PCMUX_PKG::PC_PLUS1 : PCnext = PC + 1'b1;
            PCMUX_PKG::ADDR_SUM : PCnext = MARMUX;
            PCMUX_PKG::DATA_BUS : PCnext = mainBus;
            default : begin
                PCnext = '0;
                $error("Unspecified output on PCMUX");
            end
        endcase

        // MARMUX 1
        case (ADDR1MUX)
            ADDR1MUX_PKG::SR1 : MARMUX1 = SR1_OUT;
            ADDR1MUX_PKG::PC  : MARMUX1 = PC;
        endcase

        // MARMUX 2
        case (ADDR2MUX)
            ADDR2MUX_PKG::ZERO  : MARMUX2 = 0;
            ADDR2MUX_PKG::IR_5  : MARMUX2 = $signed(IR[5:0]); //TODO: Verify this works
            ADDR2MUX_PKG::IR_8  : MARMUX2 = { {7{IR[8]}}, IR[8:0]}; //TODO: Verify this works
            ADDR2MUX_PKG::IR_10 : MARMUX2 = $signed(IR[10:0]);
        endcase

        // SR1mux
        case (SR1MUX)
            SR1MUX_PKG::IR_8_6  : SR1 = IR[8:6];
            SR1MUX_PKG::IR_11_9 : SR1 = IR[11:9];
        endcase

        // SR2mux
        case (SR2MUX)
            SR2MUX_PKG::SR2_OUT : SR2MUX_OUT = SR2_OUT;
            SR2MUX_PKG::IR_SEXT : SR2MUX_OUT = $signed(IR[4:0]); // TODO: Verify this works
        endcase

        // DRmux
        case (DRMUX)
            DRMUX_PKG::IR_11_9 : DR = IR[11:9];
            DRMUX_PKG::ONES    : DR = '1;
        endcase

    end

endmodule
