// Name: Raiyan Hasan
// Due Date: 2/21/2026
// Class: EE 271

// This module converts a button hold to a press
// Turns on when the button is unpressed

// Input:
//		- clk: Clock for this module
//		- reset: reset for this module
//		- in: input for this module
// Output:
//    - out: output signal for this module
module user_Input (out, in, clk, reset);
	input logic in, clk, reset;
	output logic out;
	logic in_d;
	
	always_ff @(posedge clk) begin	
		if (reset) begin	
			in_d <= 0;
			out <= 0;
		end else	begin
			in_d <= in;
			out <= in & ~in_d;	
		end
	end
		
endmodule

// Checks to see if in is on for a while that the output will be on for one cycle
// Checks to see if it can still react to on and off instantly 
module user_Input_testbench();	
	logic  clk, reset, in, out;
	
	user_Input dut (out, in, clk, reset);	
		
	// Set up a simulated clock.	
	parameter CLOCK_PERIOD=100;	
	initial begin	
		clk <= 0;	
		forever #(CLOCK_PERIOD/2) clk <= ~clk;	// Forever toggle the clock
	end	
		
	// Set up the inputs to the design.  Each line is a clock cycle.	
	initial begin	
		          reset <= 1;@(posedge clk);	
									@(posedge clk); // Always reset FSMs at start	
		reset <= 0; in <= 0; @(posedge clk); 	
		                    @(posedge clk); 
		                    @(posedge clk);	
						in <= 1;	@(posedge clk);
						in <= 0;	@(posedge clk);
						in <= 1;	@(posedge clk);
									@(posedge clk);
									@(posedge clk);
						in <= 0;	@(posedge clk);
									@(posedge clk);
									@(posedge clk);
			in <= 1; reset <=1;@(posedge clk);
									@(posedge clk);
									@(posedge clk);
								  
		$stop; // End the simulation.	
	end	
endmodule					
