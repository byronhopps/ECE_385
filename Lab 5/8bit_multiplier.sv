/*Inputs
S – logic [7:0]
Clk, Reset, Run, ClearA_LoadB – logic
Outputs
AhexU, AhexL, BhexU, BhexL – logic [6:0]
Aval, Bval – logic [7:0]
X –logic*/

typedef enum logic [3:0] {ready, reset, clrA_ldB, count, add, shift, done} state;

module multiplier_8bit (input  logic        Clk, Reset, ClearA_LoadB, Run,
                        input  logic [7:0]  S,
                        output logic [7:0]  Aval, Bval,
                        output logic        X, M,
                        output logic [6:0]  AhexL, AhexU, BhexL, BhexU);

    // Declare variables for the current and next states
    state curState, nextState;

    // Declare A, B, and C registers as well as their next value
    logic [7:0] A, Anext, B, Bnext;
    logic [3:0] C, Cnext;

    // Update register values on clock edge
    always_ff @ (posedge Clk)
    begin
        if (Reset)
            curState <= reset;
        else
            curState <= nextState;
            A <= Anext;
            B <= Bnext;
            C <= Cnext;
    end

    always_comb begin

        // Default register values is current value
        Anext = A;
        Bnext = B;
        Cnext = C;

        // Change register values depending on state
        case (curState)

            // Reset: Store zero in all registers
            reset: begin
                Anext = 0;
                Bnext = 0;
                Cnext = 0;
            end

            // ClearA_LoadB: Store 0 in A and load value in S to B
            clrA_ldB: begin
                Anext = 0;
                Bnext = S;
            end

            // Count: Store C+1 in C
            count: begin
                Cnext = Cinc;
            end

            // Add: Store A+S in A (or A-S in some cases)
            // The logic for A-S is handled elsewhere
            add: begin
                Anext = Asum;
            end

            // Shift: Store XAB >> 1 in A and B
            shift: begin
                Anext = Ashift;
                Bnext = Bshift;
            end
        endcase
    end


endmodule


module stateSelector (input  logic Clk, Reset, ClearA_LoadB, Run, C, M,
                      input  state curState,
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
