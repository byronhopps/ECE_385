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
    enum logic [3:0] { Halted, PauseIR1, PauseIR2,
        S_00, S_04, S_12, S_13, S_18, S_20, S_22, S_33_1,
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

                    // Raise warning for unimplemted opcode
                    default : begin
                        $warning("Unimplemented Opcode");
                        nextState <= S_18;
                    end
                endcase
            end

            // ADD instruction
            S_01 : nextState <= S_18;

            // Raise warning if in invalid state
            default : begin
                $warning("Invalid state");
                nextState <= S_18;
            end

         endcase
    end
   
    always_comb
    begin 
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
            // State 18
            // MAR <= PC
            // PC  <= PC + 1
            S_18 : begin 
                GatePC = 1'b1;
                LD_MAR = 1'b1;
                PCMUX = PCMUX::PC_PLUS1;
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
            S_32 : LD_BEN = 1'b1; // TODO: Implement BEN

            // State 1
            // DR <= SR1 + OP2
            // Set CC
            S_01 : begin 
                SR1MUX = SR1MUX::IR_8_6;

                case(IR[5])
                    1'b0 : SR2MUX = SR2MUX::SR2_OUT;
                    1'b1 : SR2MUX = SR2MUX::IR_SEXT;
                endcase

                DRMUX  = DRMUX::IR_11_9;
                ALUK   = ALU_OPS::ADD;
                GateALU = 1'b1;
                LD_REG = 1'b1;
                LD_CC  = 1'b1;
            end


            default : ;
        endcase
    end 

     // These should always be active
    assign Mem_CE = 1'b0;
    assign Mem_UB = 1'b0;
    assign Mem_LB = 1'b0;
    
endmodule
