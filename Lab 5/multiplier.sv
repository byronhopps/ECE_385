/*Inputs
S – logic [7:0]
Clk, Reset, Run, ClearA_LoadB – logic
Outputs
AhexU, AhexL, BhexU, BhexL – logic [6:0]
Aval, Bval – logic [7:0]
X –logic*/

module multiplier (input logic  Clk,    			// Internal
										  Reset,  			// Push button 0
									     ClearA_LoadB    // Push button 1
										  Run  			   // Push button 2
                                
					    input  logic [7:0]  S     	// input data
					    output logic [7:0]  Aval,    
												   Bval,
					    output logic [0:0]	X,
													M,
					    output logic [6:0]  AhexL,
							  					   AhexU,
												   BhexL,
												   BhexU);
														 
				//assign S = -8'h3A; //2's complement of 58 (-59): = 11000101 as bits(8);
														 
enum logic [3:0] {A,B,C,D,E,F,G,H,I,J} curr_state, next_state;

	always_ff @ (posedge Clk)  
    begin
        if (Reset)
            curr_state <= A;
        else 
            curr_state <= next_state;
    end

    // Assign outputs based on state
	always_comb
    begin
        
		  next_state  = curr_state;	
        unique case (curr_state) 

            A :    if (Run)
                       next_state = B;
            B :    next_state = C;
            C :    next_state = D;
            D :    next_state = E;
            E :    next_state = F;
				F :	 next_state = G;
				G :    next_state = H;
				H :    next_state = I;
				I :    next_state = J;
				J :    if (~Run) 
                       next_state = A;
							  
        endcase
   
		  // Assign outputs based on ‘state’
        case (curr_state) 
	   	   A: 
	         begin
                assign S = 8'h07;
					 Aval = 0;
                Bval = S;
                X = 1'b0;
					 assign S = -8'h3A;
		      end
	   	   B: 
		      begin
					if ((8'h01 && Bval) = 1)
                M = 1'b1;
					else M = 1'b0;
               /*XA <= A + M*S;*/
		      end
				C: 
		      begin
					if ((8'h01 && Bval) = 1)
                M = 1'b1;
					else M = 1'b0;
               /*XA <= A + M*S;*/
		      end
				D: 
		      begin
					if ((8'h01 && Bval) = 1)
                M = 1'b1;
					else M = 1'b0;
               /*XA <= A + M*S;*/
		      end
				E:
		      begin
					if ((8'h01 && Bval) = 1)
                M = 1'b1;
					else M = 1'b0;
               /*XA <= A + M*S;*/
		      end
				F: 
		      begin
					if ((8'h01 && Bval) = 1)
                M = 1'b1;
					else M = 1'b0;
               /*XA <= A + M*S;*/
		      end
				G:
		      begin
					if ((8'h01 && Bval) = 1)
                M = 1'b1;
					else M = 1'b0;
               /*XA <= A + M*S;*/
		      end
				H: 
		      begin
					if ((8'h01 && Bval) = 1)
                M = 1'b1;
					else M = 1'b0;
               /*XA <= A + M*S;*/
		      end
				I: 
		      begin
					if ((8'h01 && Bval) = 1)
                M = 1'b1;
					else M = 1'b0;
               /*XA <= A + M*S;*/
		      end
				J: 
		      begin
					if ((8'h01 && Bval) = 1)
                M = 1'b1;
					else M = 1'b0;
               /*XA <= A + M*S;*/
		      end
	   	/*   default:  //default case, can also have default assignments for Ld_A and Ld_B before case
		      begin 
                Ld_A = 1'b0;
                Ld_B = 1'b0;
                Shift_En = 1'b1;
		      end
			*/
        endcase
    end

endmodule
							  
endmodule




