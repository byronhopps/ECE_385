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
module  AES ( input                clk,
              input        [31:0]  key_0, key_1, key_2, key_3,
              output logic [31:0]  keyschedule_out_0, keyschedule_out_1, keyschedule_out_2, keyschedule_out_3 );

logic [1407:0] keyschedule;

KeyExpansion keyexpansion_0(.clk(clk),
                            .Cipherkey({key_0, key_1, key_2, key_3}),
                            .KeySchedule(keyschedule)
                            );

assign {keyschedule_out_0, keyschedule_out_1, keyschedule_out_2, keyschedule_out_3} = keyschedule[127:0];

// For week 2, write your own state machine here for AES decryption process.

endmodule
