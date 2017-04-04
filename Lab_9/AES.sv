/*---------------------------------------------------------------------------
  --      AES.sv                                                           --
  --      Joe Meng                                                         --
  --      Fall 2013                                                        --
  --                                                                       --
  --      Modified by Po-Han Huang 03/09/2017                              --
  --                                                                       --
  --      For use with ECE 385 Experiment 9                                --
  --      Spring 2017 Distribution                                         --
  --      UIUC ECE Department                                              --
  ---------------------------------------------------------------------------*/

// AES decryption core.

// AES module interface with all ports, commented for Week 1
// module  AES ( input                 clk,
//                                     reset_n,
//                                     run,
//               input        [127:0]  msg_en,
//                                     key,
//               output logic [127:0]  msg_de,
//               output logic          ready);

// Partial interface for Week 1
// Splitting the signals into 32-bit ones for compatibility with ModelSim
module  AES ( input  logic         clk, reset_n, run,
              input  logic [127:0] key,
              input  logic [127:0] msg_en,
              output logic [127:0] msg_de,
              output logic         ready
          );

logic [1407:0] keyschedule;
logic [127:0] message, nextMessage;
logic [127:0] msgSubBytes;
logic [127:0] roundKey;
logic [3:0] round, nextRound;
logic [3:0] count, nextCount;

logic [127:0] invShiftRowsOut, addRoundKeyOut;
logic [31:0] invMixColsIn, invMixColsOut;

enum logic [4:0] {
    RESET, READY, KEY_EXPANSION, ADD_ROUND_KEY_I, INV_SHIFT_ROWS, INV_SUB_BYTES_1, INV_SUB_BYTES_2,
    ADD_ROUND_KEY, INV_MIX_COLUMNS_0, INV_MIX_COLUMNS_1, INV_MIX_COLUMNS_2, INV_MIX_COLUMNS_3, DONE
    } state, nextState;

KeyExpansion keyexpansion_0(.clk(clk), .Cipherkey(key), .KeySchedule(keyschedule));

InvSubBytes invSubBytes_0  (.clk, .in(message[  7:  0]), .out(msgSubBytes[  7:  0]));
InvSubBytes invSubBytes_1  (.clk, .in(message[ 15:  8]), .out(msgSubBytes[ 15:  8]));
InvSubBytes invSubBytes_2  (.clk, .in(message[ 23: 16]), .out(msgSubBytes[ 23: 16]));
InvSubBytes invSubBytes_3  (.clk, .in(message[ 31: 24]), .out(msgSubBytes[ 31: 24]));
InvSubBytes invSubBytes_4  (.clk, .in(message[ 39: 32]), .out(msgSubBytes[ 39: 32]));
InvSubBytes invSubBytes_5  (.clk, .in(message[ 47: 40]), .out(msgSubBytes[ 47: 40]));
InvSubBytes invSubBytes_6  (.clk, .in(message[ 55: 48]), .out(msgSubBytes[ 55: 48]));
InvSubBytes invSubBytes_7  (.clk, .in(message[ 63: 56]), .out(msgSubBytes[ 63: 56]));
InvSubBytes invSubBytes_8  (.clk, .in(message[ 71: 64]), .out(msgSubBytes[ 71: 64]));
InvSubBytes invSubBytes_9  (.clk, .in(message[ 79: 72]), .out(msgSubBytes[ 79: 72]));
InvSubBytes invSubBytes_10 (.clk, .in(message[ 87: 80]), .out(msgSubBytes[ 87: 80]));
InvSubBytes invSubBytes_11 (.clk, .in(message[ 95: 88]), .out(msgSubBytes[ 95: 88]));
InvSubBytes invSubBytes_12 (.clk, .in(message[103: 96]), .out(msgSubBytes[103: 96]));
InvSubBytes invSubBytes_13 (.clk, .in(message[111:104]), .out(msgSubBytes[111:104]));
InvSubBytes invSubBytes_14 (.clk, .in(message[119:112]), .out(msgSubBytes[119:112]));
InvSubBytes invSubBytes_15 (.clk, .in(message[127:120]), .out(msgSubBytes[127:120]));

InvMixColumns columnMixer (.in(invMixColsIn), .out(invMixColsOut));
InvShiftRows  rowShifter  (.in(message), .out(invShiftRowsOut));
AddRoundKey   keyAdder    (.msg(message), .key(roundKey), .out(addRoundKeyOut));

always_ff @ (posedge clk) begin
    if (reset_n == 1'b0) begin
        state <= RESET;
        message <= '0;
        round <= '0;
        count <= '0;
    end else begin
        state <= nextState;
        round <= nextRound;
        count <= nextCount;
        message <= nextMessage;
    end
end

// State transition logic
always_comb begin
    nextState = state;

    unique case(state)
        RESET: if (reset_n == 1'b1) nextState = READY;
        READY: if (run == 1'b1) nextState = KEY_EXPANSION;
        DONE: nextState = READY;

        KEY_EXPANSION: if (count >= 4'd5) nextState = ADD_ROUND_KEY_I;
        ADD_ROUND_KEY_I: nextState = INV_SHIFT_ROWS;
        INV_SHIFT_ROWS: nextState = INV_SUB_BYTES_1;
        INV_SUB_BYTES_1: nextState = INV_SUB_BYTES_2;
        INV_SUB_BYTES_2: nextState = ADD_ROUND_KEY;

        INV_MIX_COLUMNS_0: nextState = INV_MIX_COLUMNS_1;
        INV_MIX_COLUMNS_1: nextState = INV_MIX_COLUMNS_2;
        INV_MIX_COLUMNS_2: nextState = INV_MIX_COLUMNS_3;
        INV_MIX_COLUMNS_3: nextState = INV_SHIFT_ROWS;

        ADD_ROUND_KEY: begin
            if (round < 4'd10)
                nextState = INV_MIX_COLUMNS_0;
            else
                nextState = DONE;
        end
    endcase
end

// Count register logic
always_comb begin
    case (state)
        KEY_EXPANSION: nextCount = count + 1'b1;
        default: nextCount = count;
    endcase
end

// Round register logic
always_comb begin
    nextRound = round;
    if (nextState == DONE)
        nextRound = 0;
    else if (state == ADD_ROUND_KEY_I || state == ADD_ROUND_KEY)
        nextRound = round + 1'b1;
end

// Message register logic
always_comb begin
    unique case(state)
        READY: nextMessage = msg_en;
        ADD_ROUND_KEY_I: nextMessage = addRoundKeyOut;
        INV_SHIFT_ROWS: nextMessage = invShiftRowsOut;
        INV_SUB_BYTES_1: nextMessage = msgSubBytes;
        INV_SUB_BYTES_2: nextMessage = msgSubBytes;
        ADD_ROUND_KEY: nextMessage = addRoundKeyOut;

        INV_MIX_COLUMNS_0: nextMessage = {message[127:32], invMixColsOut};
        INV_MIX_COLUMNS_1: nextMessage = {message[127:64], invMixColsOut, message[31:0]};
        INV_MIX_COLUMNS_2: nextMessage = {message[127:96], invMixColsOut, message[63:0]};
        INV_MIX_COLUMNS_3: nextMessage = {invMixColsOut, message[95:0]};

        default: nextMessage = message;
    endcase
end

// Decrypted message output
always_ff @ (posedge clk) begin
    if (reset_n == 1'b0)
        msg_de <= 0;
    else if (state == DONE)
        msg_de <= message;
end

// InvMixColumns input selection
always_comb begin
    case(state)
        INV_MIX_COLUMNS_0: invMixColsIn = message[31:0];
        INV_MIX_COLUMNS_1: invMixColsIn = message[63:32];
        INV_MIX_COLUMNS_2: invMixColsIn = message[95:64];
        INV_MIX_COLUMNS_3: invMixColsIn = message[127:96];
        default: invMixColsIn = 32'd0;
    endcase
end

// Round key selection
always_comb begin
    case(round)
        0:  roundKey = keyschedule[ 127:   0]; 
        1:  roundKey = keyschedule[ 255: 128]; 
        2:  roundKey = keyschedule[ 383: 256]; 
        3:  roundKey = keyschedule[ 511: 384]; 
        4:  roundKey = keyschedule[ 639: 512]; 
        5:  roundKey = keyschedule[ 767: 640]; 
        6:  roundKey = keyschedule[ 895: 768]; 
        7:  roundKey = keyschedule[1023: 896]; 
        8:  roundKey = keyschedule[1151:1024]; 
        9:  roundKey = keyschedule[1279:1152]; 
        10: roundKey = keyschedule[1407:1280];
        11: roundKey = key;

        default: begin
            roundKey = '0;
            $error("Invalid round count");
        end
    endcase
end

// Ready status indicator
always_comb begin
    if (state == READY)
        ready = '1;
    else
        ready = '0;
end

endmodule
