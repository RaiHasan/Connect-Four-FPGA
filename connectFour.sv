// Name: Raiyan Hasan
// Due Date: 3/15/2026
// Class: EE 271

// This module creates the connect four game and handels the input to make moves

// Input:
//		- reset: The reset for the game
// 	- clk: The clk for the game
// 	- in [6:0]: A 7 bit input that repersents each column

// Output:
//		- redPixels [6:0] [5:0] led repersenting p2 token
//		- grnPixels [6:0] [5:0] led repersenting p1 token
//    - hex(0-5): Displays the information of the game
//		- tie: on if game is tied
// 	- turn: 0 repersents player 1 turn, 1 player 2 turn
//		- win: on if game is won 
module connectFour (reset, clk, in, win, tie, turn, redPixels, grnPixels, hex0, hex1, hex2, hex3, hex4, hex5);
	input logic reset, clk;
	input logic [6:0] in;
	output logic [6:0] [5:0] redPixels,  grnPixels;
	output logic [6:0] hex0, hex1, hex2, hex3, hex4, hex5;
	output logic win;
	output logic tie;
	output logic turn; 
	logic [6:0] [5:0] redInternal,  grnInternal;
	logic player;
	logic [6:0] grnTop; 
	logic [6:0] redTop;
	player_turn playerTurn (.reset(reset), .clk(clk), 
		.in((in == 7'b0000001) || (in == 7'b0000010) || (in==7'b0000100) 
		|| (in==7'b0001000) || (in == 7'b0010000)
		|| (in == 7'b0100000) || (in == 7'b1000000)), .turn(turn));
	
	column_light collumnOne (.clk, .reset, .redPixels(redInternal[0]), .grnPixels( grnInternal[0]),
		.redDisplay(redPixels[0]), .grnDisplay(grnPixels[0]),
		.turn, .in(in == 7'b0000001));
		
	column_light collumnTwo (.clk, .reset, .redPixels(redInternal[1]), .grnPixels( grnInternal[1]),
		.redDisplay(redPixels[1]), .grnDisplay(grnPixels[1]),
		.turn, .in(in == 7'b0000010));
		
	column_light collumnThree (.clk, .reset, .redPixels(redInternal[2]), .grnPixels( grnInternal[2]),
		.redDisplay(redPixels[2]), .grnDisplay(grnPixels[2]),
		.turn, .in(in == 7'b0000100));
		
	column_light collumnFour (.clk, .reset, .redPixels(redInternal[3]), .grnPixels( grnInternal[3]),
		.redDisplay(redPixels[3]), .grnDisplay(grnPixels[3]),
		.turn, .in(in == 7'b0001000));
		
	column_light collumnFive (.clk, .reset, .redPixels(redInternal[4]), .grnPixels( grnInternal[4]),
		.redDisplay(redPixels[4]), .grnDisplay(grnPixels[4]),
		.turn, .in(in == 7'b0010000));

	column_light collumnSix (.clk, .reset, .redPixels(redInternal[5]), .grnPixels( grnInternal[5]),
		.redDisplay(redPixels[5]), .grnDisplay(grnPixels[5]),
		.turn, .in(in == 7'b0100000));

	column_light collumnSevem (.clk, .reset, .redPixels(redInternal[6]), .grnPixels( grnInternal[6]),
		.redDisplay(redPixels[6]), .grnDisplay(grnPixels[6]),
		.turn, .in(in == 7'b1000000));
	
	victoryConnectFour winCondition (.redPixels(redInternal), .grnPixels(grnInternal), .win, .player);
	
	assign redTop = {redInternal[6][0], redInternal[5][0], redInternal[4][0],
                 redInternal[3][0], redInternal[2][0], redInternal[1][0],
                 redInternal[0][0]};

	assign grnTop = {grnInternal[6][0], grnInternal[5][0], grnInternal[4][0],
                 grnInternal[3][0], grnInternal[2][0], grnInternal[1][0],
                 grnInternal[0][0]};
	
	tieChecker tieGame (.redPixels(redTop), .grnPixels(grnTop), .tie(tie), .win(win));
   
	always_comb begin
		if(win) begin
			hex5 = '1;
			hex4 = '1;
			hex3 = 7'b0010101;
			hex2 = 7'b1111001;
			hex1 = 7'b0101011;
			case (player)
            1'b0: hex0 = 7'b1111001; // 1
            1'b1: hex0 = 7'b0100100; // 2
            default:  hex0 = '1;
        endcase
		 end else if(tie) begin
			hex5 = '1;
			hex4 = '1;
			hex3 = 7'b0000111;
			hex2 = 7'b1111001;
			hex1 = 7'b0000110;
			hex0 = 7'b1000000;
		end else begin
			hex5 = 7'b0001100;
			hex3 = '1;
			hex2 = '1;
			hex1 = '1;
			hex0 = '1;
			case (turn)
				1'b0: hex4 = 7'b1111001; // 1
            1'b1: hex4 = 7'b0100100; // 2
			endcase
		end
    end
	
	
endmodule

// Tests win cases, ideal input to the game, and edge cases (multiple columns selected)
// Test if the array of pixels will turn on correctly
module connectFour_testbench();	
	logic reset, CLOCK_50, win, tie;
	logic [6:0] in, hex0, hex1, hex2, hex3, hex4, hex5;
	logic [6:0] [5:0] redPixels,  grnPixels;
	connectFour dut (reset, CLOCK_50, in, win, tie, redPixels, grnPixels, 
		hex0, hex1, hex2, hex3, hex4, hex5);
		
	// Set up a simulated clock.	
	parameter CLOCK_PERIOD=100;	
	initial begin	
		CLOCK_50 <= 0;	
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;	// Forever toggle the clock
	end	
		
	// Test the design.
	initial begin	
						repeat(1) @(posedge CLOCK_50);	
		in <= '0; reset <= 1; repeat(1) @(posedge CLOCK_50); // Always reset FSMs at start	
		     	in <= 7'b0000001; reset <= 0; repeat(700) @(posedge CLOCK_50); //GRGRGRGG		
		in <= 7'b0000010; repeat(600) @(posedge CLOCK_50); 
		in <= 7'b0000100; repeat(600) @(posedge CLOCK_50); 
		in <= 7'b0001000; repeat(600) @(posedge CLOCK_50); 
		in <= 7'b0010000; repeat(600) @(posedge CLOCK_50);
		in <= 7'b0100000; repeat(600) @(posedge CLOCK_50);
		in <= 7'b1000000; repeat(600) @(posedge CLOCK_50);	
		reset <= 1; in <= 7'b0000000;repeat(200) @(posedge CLOCK_50); 
		reset <= 0; in <= 7'b0000001; repeat(100) @(posedge CLOCK_50);//G
		in <= 7'b0001000;  repeat(100) @(posedge CLOCK_50);//R
		in <= 7'b0000100; repeat(100) @(posedge CLOCK_50);//G
		in <= 7'b0000110; repeat(200) @(posedge CLOCK_50); //player turn stays the same nothing occurs
		in <= 7'b0000100; in <= 7'b0000010; repeat(200) @(posedge CLOCK_50); 
		reset <= 1; @(posedge CLOCK_50); 
		reset <= 0; @(posedge CLOCK_50);
		in <= 7'b0000001; @(posedge CLOCK_50); //green
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000010; @(posedge CLOCK_50); // red
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000001; @(posedge CLOCK_50); //green
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000010; @(posedge CLOCK_50); //red
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000001; @(posedge CLOCK_50); //green
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000010; @(posedge CLOCK_50); //red
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000001; @(posedge CLOCK_50); //green
								@(posedge CLOCK_50);
		repeat(100) @(posedge CLOCK_50); 						
		reset <= 1; in <= 7'b0000000; @(posedge CLOCK_50); 
		reset <= 0; @(posedge CLOCK_50);
		

		
		
		in <= 7'b0000001; @(posedge CLOCK_50); ///G //1 lvl1
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000010; @(posedge CLOCK_50); ///R //2 lvl1
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0001000; @(posedge CLOCK_50); ///G //4 lvl1
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000100; @(posedge CLOCK_50); ///R //3 lvl1
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0010000; @(posedge CLOCK_50); ///G //5 lvl1
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0100000; @(posedge CLOCK_50); ///R //6 lvl1
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b1000000; @(posedge CLOCK_50); ///G //7 lvl1
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000001; @(posedge CLOCK_50); ///R //1 lvl2
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000100; @(posedge CLOCK_50); ///G //3 lvl2
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000010; @(posedge CLOCK_50); ///R //2 lvl2
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b1000000; @(posedge CLOCK_50); ///G //7 lvl2
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0001000; @(posedge CLOCK_50); ///R //4 lvl2
		repeat(100) @(posedge CLOCK_50); 
			
		in <= 7'b0000001; @(posedge CLOCK_50); ///G //1 lvl3
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0010000; @(posedge CLOCK_50); ///R //5 lvl2
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000010; @(posedge CLOCK_50); ///G //2 lvl3
		repeat(100) @(posedge CLOCK_50); 		
		in <= 7'b0100000; @(posedge CLOCK_50); ///R //6 //level 2 done
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0001000; @(posedge CLOCK_50); ///G //4 //lvl 3
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000100; @(posedge CLOCK_50); ///R //3 //lvl3
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0010000; @(posedge CLOCK_50); ///G //5 //lvl3
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0100000; @(posedge CLOCK_50); ///R //6 //level 3
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b1000000; @(posedge CLOCK_50); ///G //7 lvl3 done
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000001; @(posedge CLOCK_50); ///R //1 lvl4
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0001000; @(posedge CLOCK_50); ///G //4 //lvl 4
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000010; @(posedge CLOCK_50); ///R //2 lvl4
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0010000; @(posedge CLOCK_50); ///G //5 //lvl4
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000100; @(posedge CLOCK_50); ///R //3 //lvl4
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0100000; @(posedge CLOCK_50); ///G //6 //level 4
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b1000000; @(posedge CLOCK_50); ///R //7 lvl4 done
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000001; @(posedge CLOCK_50); ///G //1 lvl5
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000100; @(posedge CLOCK_50); ///R //3 //lvl5
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000010; @(posedge CLOCK_50); ///G //2 lvl5
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0010000; @(posedge CLOCK_50); ///R //5 lvl5
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0001000; @(posedge CLOCK_50); ///G //4 //lvl 5
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0100000; @(posedge CLOCK_50); ///R //6 //level 5
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b1000000; @(posedge CLOCK_50); ///G //7 lvl5 done
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000001; @(posedge CLOCK_50); ///R //1 lvl6
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000100; @(posedge CLOCK_50); ///G //3 lvl6
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0000010; @(posedge CLOCK_50); ///R //2 lvl6
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0010000; @(posedge CLOCK_50); ///G //5 //lvl6
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0001000; @(posedge CLOCK_50); ///R //4 lvl6
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b0100000; @(posedge CLOCK_50); ///G //6 //level 6
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b1000000; @(posedge CLOCK_50); ///R //7 lvl6 done
		repeat(100) @(posedge CLOCK_50); 

		in <= 7'b1000000; @(posedge CLOCK_50); ///R //7 lvl6 done
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b1000000; @(posedge CLOCK_50); ///R //7 lvl6 done
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b1000000; @(posedge CLOCK_50); ///R //7 lvl6 done
		repeat(100) @(posedge CLOCK_50); 
		in <= 7'b1000000; @(posedge CLOCK_50); ///R //7 lvl6 done
		repeat(100) @(posedge CLOCK_50); 		
		$stop; // End the simulation.	
	end	
endmodule
