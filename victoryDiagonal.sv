// Name: Raiyan Hasan
// Due Date: 3/15/2026
// Class: EE 271

// This module checks to see if the game is won diagnoaly

// Input:
//		- redPixels [6:0][5:0]: led repersenting p2 token
//		- grnPixels [6:0][5:0]: led repersenting p1 toke
//		

// Output:
//		- player: Which player won the game (0 for p1, 1 for p2)
//		- win: on if the game is won
module victoryDiagonal (redPixels, grnPixels, win, player);
	input logic [6:0] [5:0] redPixels,  grnPixels;
	output logic win, player;


	always_comb begin
		win = 0;
		player = 0;
		for(int r = 0; r < 3; r++)begin
			for(int c = 0; c < 4; c++) begin
				if(redPixels [c][r]
				&& redPixels [c+1][r+1]
				&& redPixels [c+2][r+2]
				&& redPixels [c+3][r+3])begin
					win = 1;
					player = 1;
				end
				
				else if(grnPixels [c][r]
						&& grnPixels [c+1][r+1]
						&& grnPixels [c+2][r+2]
						&& grnPixels [c+3][r+3])begin
							win = 1;
							player = 0;
				end
			end
		end
		for(int r = 3; r < 6; r++)begin
			for(int c = 0; c < 4; c++) begin
				if(redPixels [c][r]
				&& redPixels [c+1][r-1]
				&& redPixels [c+2][r-2]
				&& redPixels [c+3][r-3])begin
					win = 1;
					player = 1;
				end
				
				else if(grnPixels [c][r]
						&& grnPixels [c+1][r-1]
						&& grnPixels [c+2][r-2]
						&& grnPixels [c+3][r-3])begin
							win = 1;
							player = 0;
				end
			end
		end
	end
endmodule

// Tests for diagonal in the upward direction
// and downward direction
// test for both red and green tokens
// tests to see if player is correct
module victoryDiagonal_testbench();	
	logic [6:0] [5:0] redPixels,  grnPixels;	
	logic win, player;
	
	victoryDiagonal dut (redPixels, grnPixels, win, player);
	
	initial begin	
		redPixels = '0; #10;
		grnPixels = '0; #10;
		redPixels [1] [1] = 1; #10;
		redPixels [2] [2] = 1; #10;
		redPixels [3] [3] = 1; #10;
		redPixels [4] [4] = 1; #20;	//player1win
		redPixels = '0;
		grnPixels [1] [1] = 1; #10;
		grnPixels [2] [2] = 1; #10;
		grnPixels [3] [3] = 1; #10;
		grnPixels [4] [4] = 1; #10; //player0 win
		grnPixels = '0;
		grnPixels [0] [3] = 1; #10;
		grnPixels [1] [2] = 1; #10;
		grnPixels [2] [1] = 1; #10;
		grnPixels [3] [0] = 1; #10; //diagonal  
		redPixels [6][5] = 1; #10;
		redPixels [5][6] = 1; #10;
		redPixels = '0; #10;
		grnPixels = '0; #10;
		redPixels[2][0] = 1;  #10;
		grnPixels[2][5] = 1; #10;
		redPixels[2][1] = 1; #10;
		grnPixels[3][4] = 1;#10;
		redPixels[6][0] = 1;#10;
		grnPixels[4][3] = 1;#10;
		redPixels[0][1] = 1;#10;
		grnPixels[5][2] = 1;#10;
		redPixels[1][0] = 1;#10; //Green
		
	end
endmodule
	
