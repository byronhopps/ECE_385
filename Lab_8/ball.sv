//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  03-03-2017                               --
//    Spring 2017 Distribution                                           --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input         Reset, 
                             frame_clk,           // The clock indicating a new frame (~60Hz)
               input logic [15:0] keycode,
               output [9:0]  BallX, BallY, BallS, // Ball coordinates and size
               output logic [7:0] GLED
              );
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
    logic [7:0] GLEDnext;
     
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis
    parameter [9:0] Ball_Size=4;        // Ball size
    
    assign BallX = Ball_X_Pos;
    assign BallY = Ball_Y_Pos;
    assign BallS = Ball_Size;
    
    always_ff @ (posedge frame_clk) begin

        if (Reset) begin
            Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Center;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;
            GLED <= '0;
        end

        else begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
            GLED <= GLEDnext;
        end
    end
    

    always_comb begin

        case (keycode)

            // W key pressed
            26: begin
                Ball_X_Motion_in = 0;
                Ball_Y_Motion_in = -Ball_Y_Step;
                GLEDnext = 1;
            end

            // A key pressed
            4: begin
                Ball_X_Motion_in = -Ball_X_Step;
                Ball_Y_Motion_in = 0;
                GLEDnext = 2;
            end

            // S key pressed
            22: begin
                Ball_X_Motion_in = 0;
                Ball_Y_Motion_in = Ball_Y_Step;
                GLEDnext = 4;
            end

            // D key pressed
            7: begin
                Ball_X_Motion_in = Ball_X_Step;
                Ball_Y_Motion_in = 0;
                GLEDnext = 8;
            end

            // By default, keep motion unchanged
            default: begin
                Ball_X_Motion_in = Ball_X_Motion;
                Ball_Y_Motion_in = Ball_Y_Motion;
                GLEDnext = GLED;
            end
        endcase
        
        // Be careful when using comparators with "logic" datatype becuase compiler treats 
        //   both sides of the operator UNSIGNED numbers. (unless with further type casting)
        // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
        // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.

        if( Ball_Y_Pos + Ball_Size >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
            Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);  // 2's complement.  
        else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size )  // Ball is at the top edge, BOUNCE!
            Ball_Y_Motion_in = Ball_Y_Step;

        if( Ball_X_Pos + Ball_Size >= Ball_X_Max )  // Ball is at the bottom edge, BOUNCE!
            Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);  // 2's complement.  
        else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size )  // Ball is at the top edge, BOUNCE!
            Ball_X_Motion_in = Ball_X_Step;

        // Prevent the ball from moving in a diagonal direction
        if (Ball_X_Motion_in != 0 && Ball_Y_Motion_in != 0)
            Ball_X_Motion_in = 0;

        // Update the ball's position with its motion
        Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
        Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
        
    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #2/2:
          Notice that Ball_Y_Pos is updated using Ball_Y_Motion. 
          Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old? 
          What is the difference between writing
            "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and 
            "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
          How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
          Give an answer in your Post-Lab.
    **************************************************************************************/
        
    end
    
endmodule
