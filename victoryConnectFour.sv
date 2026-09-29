// Name: Raiyan Hasan
// Due Date: 3/15/2026
// Class: EE 271

// This module checks to see if the game is won

// Input:
//		- redPixels [6:0][5:0]: led repersenting p2 token
//		- grnPixels [6:0][5:0]: led repersenting p1 toke
//		

// Output:
//		- player: Which player won the game (0 for p1, 1 for p2)
//		- win: on if the game is won


module victoryConnectFour (redPixels, grnPixels, win, player);
	input logic [6:0] [5:0] redPixels,  grnPixels;
	output logic win, player;
	logic winVert, winDiag, winHoriz;
	logic playerVert,playerDiag, playerHoriz;
	
	victoryDiagonal caseOne (.redPixels, .grnPixels, .win(winDiag), .player(playerDiag));
	victoryVertical caseTwo (.redPixels, .grnPixels, .win(winVert), .player(playerVert));
	victoryHorizontal caseThree (.redPixels, .grnPixels, .win(winHoriz), .player(playerHoriz));
	
	assign win = winVert | winDiag | winHoriz;
	assign player = playerVert | playerDiag | playerHoriz;
endmodule



// Tests for all win cases diagnol, vertical, horiztonal
// tests to see if middle and edge of the board can still detect game play.
// tests to see if player is correct
module victoryConnectFour_testbench();	
	logic [6:0] [5:0] redPixels,  grnPixels;	
	logic win, player;
	
	victoryConnectFour dut (redPixels, grnPixels, win, player);
	
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
		redPixels[3][2] = 1;#10;;
		//Horizontal
		redPixels = '0; #10;
		grnPixels = '0; #10;
		redPixels [0] [1] = 1; #10;
		redPixels [0] [2] = 1; #10;
		redPixels [0] [3] = 1; #10;
		redPixels [0] [4] = 1; #10; //player1win
		redPixels = '0;
		grnPixels [0] [1] = 1; #10;
		grnPixels [0] [2] = 1; #10;
		grnPixels [0] [3] = 1; #10;
		grnPixels [0] [4] = 1; #10; //player0 win
		grnPixels = '0;
		grnPixels [0] [1] = 1; #10;
		redPixels [0] [2] = 1; #10;
		grnPixels [0] [3] = 1; #10;
		redPixels [0] [4] = 1; #10; //no player wins 
		redPixels = '0; #10;
		grnPixels = '0; #10;
		redPixels[1][1] = 1;  #10;
		grnPixels[0][1] = 1; #10;
		redPixels[3][3] = 1; #10;
		grnPixels[0][2] = 1;#10;
		redPixels[6][1] = 1;#10;
		grnPixels[0][3] = 1;#10;
		redPixels[6][1] = 1;#10;
		grnPixels[0][4] = 1;#10;
		redPixels[2][0] = 1;#10; //slightly sparatic board should test win
		redPixels = '0; #10;
		grnPixels = '0; #10;
		redPixels [6] [2] = 1; #10;
		redPixels [6] [3] = 1; #10;
		redPixels [6] [4] = 1; #10;
		redPixels [6] [5] = 1; #10;  //Extreme index should win 1
		//Vertical
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
		//Diagonal
		
	end
endmodule 

