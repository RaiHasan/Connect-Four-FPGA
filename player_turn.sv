// Name: Raiyan Hasan
// Due Date: 3/15/2026
// Class: EE 271

// This module controls which player turn it is.

// Input:
//		- clk: Clock for this module
//		- reset: reset for this module
//    - in: on if there is an input

// Output:
//		- turn: 0 repersents player 1 turn, 1 repersents player 2 turn 
module player_turn (reset, clk, in, turn);
	input logic reset, clk, in;
	output logic turn;
	enum {p1,p2} ns, ps;
	
	always_comb begin
		case(ps)
			p1: if(in) ns = p2;
				 else ns = p1;
				 
			p2: if(in) ns = p1;
				 else ns = p2;
		endcase
	end
	
	assign turn = (ps == p2);
	
	always_ff @(posedge clk) begin
		if(reset)
			ps <= p1;
		else
			ps <= ns;
	end
endmodule

module player_turn_testbench();
	logic reset, clk, in, turn;
	
	player_turn dut (reset, clk, in, turn);
	
	parameter CLOCK_PERIOD=100;	
	initial begin	
		clk <= 0;	
		forever #(CLOCK_PERIOD/2) clk <= ~clk;	// Forever toggle the clock
	end	
	
	initial begin
		reset <= 1; in <= 0; @(posedge clk);
		reset <= 0; in <=1; repeat(3) @(posedge clk); //0,1,0;
		reset <= 1; in <= 1; repeat(2) @(posedge clk); //0;
		reset <= 0; in <= 1; repeat(1) @(posedge clk); //1
		reset <= 1; in <= 1; repeat(1) @(posedge clk); //0
	$stop;
	end
endmodule 
		
		
		
		

	