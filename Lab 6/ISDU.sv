//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Lab 6 Given Code - Incomplete ISDU
// Module Name:    ISDU - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//------------------------------------------------------------------------------

module ISDU (
    input logic Clk, Reset, Run, Continue,
    input logic [3:0] Opcode, 
    input logic IR_5, IR_11, BEN,

    output logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC,
    output logic LD_LED, // for PAUSE instruction
    output logic GatePC, GateMDR, GateALU, GateMARMUX,
    output logic [1:0] PCMUX,
    output logic DRMUX, SR1MUX, SR2MUX, ADDR1MUX,
    output logic [1:0] ADDR2MUX, ALUK,
    output logic Mem_CE, Mem_UB, Mem_LB, Mem_OE, Mem_WE
    );

   // Internal state logic
    enum logic [5:0] { Halted, PauseIR1, PauseIR2,
        S_00, S_04, S_06, S_07, S_16_1, S_16_2, S_12,
        S_13, S_18, S_20, S_22, S_23, S_25_1, S_25_2, S_27, S_33_1,
        S_33_2, S_35, S_32, S_01, S_05, S_09}   state, nextState;

    always_ff @ (posedge Clk)
    begin : Assign_Next_State
        if (Reset) 
            state <= Halted;
        else 
            state <= nextState;
    end

    always_comb begin 
        // Default next state is staying at current state
        nextState = state;
     
        unique case (state)

            // Stay in halted state until Run is asserted
            Halted : begin
                if (Run) 
                    nextState <= S_18;                      
            end

            S_18 : nextState <= S_33_1;

            // Any states involving SRAM require more than one clock cycles.
            // The exact number will be discussed in lecture.
            S_33_1 : nextState <= S_33_2;
            S_33_2 : nextState <= S_35;

            S_35 : nextState <= PauseIR1;

            // PauseIR1 and PauseIR2 are only for Week 1 such that TAs can see 
            // the values in IR. They should be removed in Week 2
            PauseIR1 : begin
                if (~Continue) 
                    nextState <= PauseIR1;
                else 
                    nextState <= PauseIR2;
            end

            PauseIR2 : begin
                if (Continue) 
                    nextState <= PauseIR2;
                else 
                    nextState <= S_18;
            end

            // Branch out from state 32 depending on the current opcode
            S_32 : begin
                case (Opcode)
                    OPCODE::ADD : nextState <= S_01;
                    OPCODE::AND : nextState <= S_05;
                    OPCODE::NOT : nextState <= S_09;
                    OPCODE::BR  : nextState <= S_00;
                    OPCODE::JMP : nextState <= S_12;
                    OPCODE::JSR : nextState <= S_04;
                    OPCODE::PSE : nextState <= S_13;
                    OPCODE::LDR : nextState <= S_06;
                    OPCODE::STR : nextState <= S_07;

                    // Raise warning for unimplemted opcode
                    default : begin
                        $warning("Unimplemented Opcode");
                        nextState <= S_18;
                    end
                endcase
            end

            // ADD instruction
            S_01 : nextState <= S_18;

            // AND instruction
            S_05 : nextState <= S_18;

            // NOT instruction
            S_09 : nextState <= S_18;

            // BR instruction
            S_22 : nextState <= S_18;
            S_00 : begin
                if (BEN == 1)
                    nextState <= S_22;
                else
                    nextState <= S_18;
            end

            // JMP instruction
            S_12 : nextState <= S_18;

            // JSR instruction
            S_04 : nextState <= S_20;
            S_20 : nextState <= S_18;

            // PSE instruction
            S_13 : nextState <= S_18;

            // LDR instruction
            S_06   : nextState <= S_25_1;
            S_25_1 : nextState <= S_25_2;
            S_25_2 : nextState <= S_27;
            S_27   : nextState <= S_18;

            // STR instruction
            S_07   : nextState <= S_23;
            S_23   : nextState <= S_16_1;
            S_16_1 : nextState <= S_16_2;
            S_16_2 : nextState <= S_18;

            // Raise warning if in invalid state
            default : begin
                $warning("Invalid state");
                nextState <= S_18;
            end

         endcase
    end
   
    always_comb begin 

        // default controls signal values; within a process, these can be
        // overridden further down (in the case statement, in this case)
        LD_MAR = 1'b0;
        LD_MDR = 1'b0;
        LD_IR = 1'b0;
        LD_BEN = 1'b0;
        LD_CC = 1'b0;
        LD_REG = 1'b0;
        LD_PC = 1'b0;
        LD_LED = 1'b0;
         
        GatePC = 1'b0;
        GateMDR = 1'b0;
        GateALU = 1'b0;
        GateMARMUX = 1'b0;
         
        ALUK = 2'b00;
         
        PCMUX = 2'b00;
        DRMUX = 1'b0;
        SR1MUX = 1'b0;
        SR2MUX = 1'b0;
        ADDR1MUX = 1'b0;
        ADDR2MUX = 2'b00;

        Mem_OE = 1'b1;
        Mem_WE = 1'b1;

        // Assign control signals based on current state
        case (state)

            // These states have no output
            Halted: ;
            PauseIR1 : ;
            PauseIR2 : ;
            S_00 : ;

            // State 18
            // MAR <= PC
            // PC  <= PC + 1
            S_18 : begin 
                GatePC = 1'b1;
                LD_MAR = 1'b1;
                PCMUX = PCMUX_PKG::PC_PLUS1;
                LD_PC = 1'b1;
            end

            // State 33
            // MDR <= M[MAR]
            S_33_1 : Mem_OE = 1'b0;
            S_33_2 : begin // TODO: Figure out how this works
                Mem_OE = 1'b0;
                LD_MDR = 1'b1;
            end

            // State 35
            // IR <= MDR
            S_35 : begin 
                GateMDR = 1'b1;
                LD_IR = 1'b1;
            end

            // State 32
            // BEN <= {IR[11] & N, IR[10] & Z, IR[9] & P}
            S_32 : LD_BEN = 1'b1;

            // State 1
            // DR <= SR1 + OP2
            // Set CC
            S_01 : begin 
                SR1MUX = SR1MUX_PKG::IR_8_6;

                case(IR_5)
                    1'b0 : SR2MUX = SR2MUX_PKG::SR2_OUT;
                    1'b1 : SR2MUX = SR2MUX_PKG::IR_SEXT;
                endcase

                DRMUX  = DRMUX_PKG::IR_11_9;
                ALUK   = ALU_OPS::ADD;
                GateALU = 1'b1;
                LD_REG = 1'b1;
                LD_CC  = 1'b1;
            end

            // State 5
            // DR <= SR1 & OP2
            // Set CC
            S_05 : begin
                SR1MUX = SR1MUX_PKG::IR_8_6;

                case(IR_5)
                    1'b0 : SR2MUX = SR2MUX_PKG::SR2_OUT;
                    1'b1 : SR2MUX = SR2MUX_PKG::IR_SEXT;
                endcase

                DRMUX  = DRMUX_PKG::IR_11_9;
                ALUK   = ALU_OPS::AND;
                GateALU= 1'b1;
                LD_REG = 1'b1;
                LD_CC  = 1'b1;
            end

            // State 9
            // DR <= NOT(SR)
            // Set CC
            S_09 : begin
                SR1MUX = SR1MUX_PKG::IR_8_6;
                DRMUX  = DRMUX_PKG::IR_11_9;
                ALUK   = ALU_OPS::NOT;
                GateALU= 1'b1;
                LD_REG = 1'b1;
                LD_CC  = 1'b1;
            end

            // State 22
            // PC <= PC + off9
            S_22 : begin
                PCMUX = PCMUX_PKG::ADDR_SUM;
                ADDR1MUX = ADDR1MUX_PKG::PC;
                ADDR2MUX = ADDR2MUX_PKG::OFF9;
                LD_PC = 1'b1;
            end

            // State 12
            // PC <= BaseR
            S_12 : begin
                SR1MUX = SR1MUX_PKG::IR_8_6;
                ADDR1MUX = ADDR1MUX_PKG::SR1;
                ADDR2MUX = ADDR2MUX_PKG::ZERO;
                PCMUX = PCMUX_PKG::ADDR_SUM;
                LD_PC = 1'b1;
            end

            // State 4
            // R7 <- PC
            S_04 : begin
                GatePC = 1'b1;
                DRMUX  = DRMUX_PKG::SEVEN;
                LD_REG = 1'b1;
            end

            // State 20
            // PC <- BaseR
            S_20 : begin
                SR1MUX = SR1MUX_PKG::BASE_R;
                ADDR1MUX = ADDR1MUX_PKG::SR1;
                ADDR2MUX = ADDR2MUX_PKG::ZERO;
                PCMUX = PCMUX_PKG::ADDR_SUM;
                LD_PC = 1'b1;
            end

            // State 13
            // LED <- ledVect12
            S_13 : LD_LED = 1'b1;

            // State 6
            // MAR <- B + off6
            S_06 : begin
                SR1MUX = SR1MUX_PKG::BASE_R;
                ADDR1MUX = ADDR1MUX_PKG::SR1;
                ADDR2MUX = ADDR2MUX_PKG::OFF6;
                GateMARMUX = '1;
                LD_MAR = '1;
            end

            // State 25
            // MDR <- M[MAR]
            S_25_1 : Mem_OE = '0;
            S_25_2 : begin
                Mem_OE = '0;
                LD_MDR = '1;
            end

            // State 27
            // DR <- MDR
            // Set CC
            S_27 : begin
                GateMDR = '1;
                DRMUX   = DRMUX_PKG::IR_11_9;
                LD_REG  = '1;
                LD_CC   = '1;
            end

            // State 7
            // MAR <- B + off6
            S_07 : begin
                SR1MUX = SR1MUX_PKG::BASE_R;
                ADDR1MUX = ADDR1MUX_PKG::SR1;
                ADDR2MUX = ADDR2MUX_PKG::OFF6;
                GateMARMUX = '1;
                LD_MAR = '1;
            end

            // State 23
            // MDR <- SR
            S_23 :  begin
                SR1MUX = SR1MUX_PKG::IR_11_9;
                ALUK   = ALU_OPS::PSA;
                GateALU = '1;
                Mem_OE  = '1;
                LD_MDR = '1;
            end

            // State 16
            // M[MAR] <- MDR
            S_16_1 : Mem_WE = '0;
            S_16_2 : Mem_WE = '0;

            default : ;
        endcase
    end 

     // These should always be active
    assign Mem_CE = 1'b0;
    assign Mem_UB = 1'b0;
    assign Mem_LB = 1'b0;
    
endmodule
