// Name: Raiyan Hasan
// Due Date: 3/15/2026
// Class: EE 271

// This module checks to see if the game is won horizontally

// Input:
//		- redPixels [6:0][5:0]: led repersenting p2 token
//		- grnPixels [6:0][5:0]: led repersenting p1 toke
//		

// Output:
//		- player: Which player won the game (0 for p1, 1 for p2)
//		- win: on if the game is won

module victoryHorizontal (redPixels, grnPixels, win, player);
	input logic [6:0] [5:0] redPixels,  grnPixels;
	output logic win, player;
	
	always_comb begin
		win = 0;
		player = 0;
		for(int r = 0; r < 6; r++)begin
			for(int c = 0; c < 4; c++) begin
				if(redPixels [c][r]
				&& redPixels [c+1][r]
				&& redPixels [c+2][r]
				&& redPixels [c+3][r])begin
					win = 1;
					player = 1;
				end
				
				else if(grnPixels [c][r]
						&& grnPixels [c+1][r]
						&& grnPixels [c+2][r]
						&& grnPixels [c+3][r])begin
							win = 1;
							player = 0;
				end
			end
		end
	end
endmodule

// Tests to see if game is won correctly 
// test middle and edge of board
// tests to see if correct player won
// tests both red and green tokens work in win check
module victoryHorizontal_testbench();	
	logic [6:0] [5:0] redPixels,  grnPixels;	
	logic win, player;
	
	victoryHorizontal dut (redPixels, grnPixels, win, player);
	
	initial begin	
		redPixels = '0; #10;
		grnPixels = '0; #10;
		redPixels [1] [0] = 1; #10;
		redPixels [2] [0] = 1; #10;
		redPixels [3] [0] = 1; #10;
		redPixels [4] [0] = 1; #10; //player1win
		redPixels = '0;
		grnPixels [1] [0] = 1; #10;
		grnPixels [2] [0] = 1; #10;
		grnPixels [3] [0] = 1; #10;
		grnPixels [4] [0] = 1; #10; //player0 win
		grnPixels = '0;
		grnPixels [1] [0] = 1; #10;
		redPixels [1] [0] = 1; #10;
		grnPixels [1] [0] = 1; #10;
		redPixels [1] [0] = 1; #10; //no player wins 
		redPixels = '0; #10;
		grnPixels = '0; #10;
		redPixels[2][0] = 1;  #10;
		grnPixels[2][1] = 1; #10;
		redPixels[2][1] = 1; #10;
		grnPixels[3][1] = 1;#10;
		redPixels[6][0] = 1;#10;
		grnPixels[4][1] = 1;#10;
		redPixels[6][1] = 1;#10;
		grnPixels[5][1] = 1;#10;
		redPixels[3][2] = 1;#10;
		
	end
endmodule 
	
	

						
				
	