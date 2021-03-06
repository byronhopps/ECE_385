/*---------------------------------------------------------------------------
  --      aes_controller.sv                                                --
  --      Christine Chen                                                   --
  --      10/29/2013                                                       --
  --                                                                       --
  --      Modified by Po-Han Huang 03/09/2017                              --
  --                                                                       --
  --      For use with ECE 385 Experiment 9                                --
  --      Spring 2017 Distribution                                         --
  --      UIUC ECE Department                                              --
  ---------------------------------------------------------------------------*/

// AES controller module
// The actual AES computation is done in AES, not here.
module aes_controller(
                      input                  clk,
                      input                  reset_n,  // Active-low reset
                      input        [127:0]   msg_en,   // Encrypted message
                      input        [127:0]   key,      // Key
                      output logic [127:0]   msg_de,   // Decrypted message
                      input                  io_ready, // Ready for decryption
                      output logic           aes_ready // Decryption complete
       );

enum logic [1:0] {WAIT, START, COMPUTE, READY} state, next_state;
//logic [15:0] counter, counter_in;
logic runAES, AESdone;

// This instantiation is for week 1. For week 2, instantiate AES according to new interfaces.
AES aes0(.clk, .reset_n, .run(runAES),
        .key, .msg_en, .msg_de, .ready(AESdone)
    );

always_ff @ (posedge clk) begin
    if (reset_n == 1'b0) begin
        state <= WAIT;
    end
    else begin
        state <= next_state;
    end
end

always_comb begin
    // Next state logic
    next_state = state;

    case (state)

        // Wait until IO is ready.
        WAIT: if (io_ready == 1'b1) next_state = START;

        START: next_state = COMPUTE;

        // Wait for AES decryption until it is ready.
        // (The counter prevents getting stuck in this state.)
        COMPUTE: begin
            if (AESdone == 1)
                next_state = READY;
        end
        // AES decryption is finished.
        READY: begin
        end
    endcase

    // Control signals
    aes_ready = 1'b0;
    runAES = 0;
    case (state)
        START: runAES = 1;
        READY: aes_ready = 1'b1;
    endcase
end

endmodule
