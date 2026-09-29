// Name: Raiyan Hasan
// Due Date: 3/15/2026
// Class: EE 271

// This module checks to see if the game is tied

// Input:
//		- redPixels [6:0]: led repersenting p2 token top row
//		- grnPixels [6:0]: led repersenting p1 token top row
//		- win: If the game is won (This is to prevent tie and win happening at the same time)

// Output:
//		- tie: on if the game is tied
module tieChecker (redPixels, grnPixels, tie, win);
	input logic [6:0] redPixels, grnPixels;
	input logic win;
	output logic tie;
	always_comb begin
		if(win) begin 
			tie = 0;
		end else begin
			tie = 1;
			for(int i = 0; i < 7; i++) begin
				if((redPixels[i] == 0) && (grnPixels[i] == 0)) begin
					tie = 0;
				end
			end
		end 
	end
endmodule 


// Checks to see if module correctly checks for a tie
// checks to see if module correctly is off when the game is won
module tieChecker_testbench();	
	logic [6:0] redPixels, grnPixels;
	logic tie, win;
	tieChecker dut (redPixels, grnPixels, tie, win);
	initial begin
		win = 0; #10;
		redPixels = '0; #10;
		grnPixels = '0; #10;
		
		redPixels[0] = 1; #10;
		grnPixels[1] = 1; #10;
		redPixels[2] = 1; #10;
		grnPixels[3] = 1; #10;
		redPixels[4] = 1; #10;
		grnPixels[5] = 1; #10;
		redPixels[6] = 1; #10; //tie
		
		redPixels = '0; #10;
		grnPixels = '0; #10;
		win = 0; #10;
		redPixels = '1; //tie
		redPixels = '0; #10;
		grnPixels = '0; #10;
		win = 0; #10;
		redPixels = '1; #10; //tie
		win = 1; #10; //0;
		redPixels = '0; #10;
		grnPixels = '1; #10; //0	
	end
endmodule 
	