/*Inputs
S – logic [7:0]
Clk, Reset, Run, ClearA_LoadB – logic
Outputs
AhexU, AhexL, BhexU, BhexL – logic [6:0]
Aval, Bval – logic [7:0]
X –logic*/

typedef enum logic [3:0] {ready, reset, clrA_ldB, count, add, shift, done} state;

module multiplier_8bit (input logic  Clk, Reset, ClearA_LoadB, Run,
                        input  logic [7:0]  S,
                        output logic [7:0]  Aval,    Bval,
                        output logic        X, M,
                        output logic [6:0]  AhexL, AhexU, BhexL, BhexU);

    // Declare variables for the current and next states
    state curState, nextState;

    // Declare A, B, and C registers as well as their next value
    logic [7:0] A, Anext, B, Bnext;
    logic [3:0] C, Cnext;

endmodule


module stateSelector (input logic        Clk, Reset, ClearA_LoadB, Run, C, M,
                      input state curState,
                      output state nextState);

//enum logic [3:0] {ready, reset, clrA_ldB, count, add, shift, done} curState, nextState;

    // Assign outputs based on state
    always_comb begin

        // Default to staying in the current state
        nextState = curState;

        // Logic for switching state
        case (curState)

            // Ready state
            ready: begin
                if (Run == 1'b1)
                    nextState = count;
                else if (ClearA_LoadB == 1'b1)
                    nextState = clrA_ldB;
            end

            // Reset state
            reset: begin
                if (Reset == 1'b0)
                    nextState = ready;
            end

            // ClearA_LoadB state
            clrA_ldB: nextState = ready;

            // Count state
            count: begin
                case (M)
                    1'b1: nextState = add;
                    1'b0: nextState = shift;
                endcase
            end

            // Add state
            add: nextState = shift;

            // Shift state
            shift: begin
                case (C)
                    1'b1: nextState = done;
                    1'b0: nextState = count;
                endcase
            end

            // Done state
            done: begin
                if (Run == 1'b0)
                    nextState = ready;
            end
        endcase
    end

endmodule
