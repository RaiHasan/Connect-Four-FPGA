// Name: Raiyan Hasan
// Due Date: 2/28/2026
// Class: EE 271

// This module plays the connect four through the DE1_SOC board.
// SW 7-1 repersent where the token to be placed
// KEY[0] places the token in selected colum
// When one player gets four in a row in diagnol, horizontal, vertical
// They win and the led board indicators will show all yellows indicating game is over
// The hex will display which player won, and the game needs to be reset to start over
// if a tie occurs the hex will display so
// player 1 goes first with green token
// player 2 goes second with red token

// Input:
//		- KEY 0-3: KEY[0] places token
//		- SW(0-9): SW[9] is the reset button SW[8:0] controls the difficulty
//		- CLOCK_50: 50Mhz clock 
// Output:
//		- HEX(0-5): Information about the game of who won or which player turn it is
//		- GPIO_1: The LED board that shows the state of the game
//    - LEDR [7:1]: shows selction

module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, GPIO_1, CLOCK_50);
    output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	 output logic [9:0]  LEDR;
    input  logic [3:0]  KEY;
    input  logic [9:0]  SW;
    output logic [35:0] GPIO_1;
    input logic CLOCK_50;

	 
	 
	 /* Set up system base clock to 1526 Hz (50 MHz / 2**(14+1))
	    ===========================================================*/
	 logic [31:0] div_clk;
	 //logic SYSTEM_CLOCK;
	 
	//assign SYSTEM_CLOCK = clk[14]; // 1526 Hz clock signal
	parameter whichClock = 14;
	clock_divider cdiv (.clock(CLOCK_50),	
                       .reset(SW[9]),	
                       .divided_clocks(div_clk));		
	
	// Clock selection; allows for easy switching between sim and board clocks
	logic clkSelect;

	// Detect when we're in Quartus and use the divided clock,
	// otherwise assume we're in ModelSim and use the fast clock
	`ifdef ALTERA_RESERVED_QIS
	    assign clkSelect = div_clk[whichClock]; // for board
	`else
	    assign clkSelect = CLOCK_50; // for simulation
	`endif
	
	 /* If you notice flickering, set SYSTEM_CLOCK faster.
	    However, this may reduce the brightness of the LED board. */
	
	 
	 /* Set up LED board driver
	
	    ================================================================== */

	 logic [15:0][15:0]RedPixels; // 16 x 16 array representing red LEDs
    logic [15:0][15:0]GrnPixels; // 16 x 16 array representing green LEDs
	 logic [6:0] [5:0] redPixels;
	 logic [6:0] [5:0] grnPixels;
	 logic [6:0] up;
	 logic [6:0] d;
	 logic [6:0] in;
	 logic win;
	 
	 
	 //led driver
	LEDDriver Driver (.CLK(clkSelect), .RST(SW[9]), .EnableCount(1'b1), .RedPixels, .GrnPixels, .GPIO_1);
	logic [15:0][15:0] boardRed;
	logic [15:0][15:0] boardGrn;
	logic [15:0][15:0] selectorRed;
	logic [15:0][15:0] selectorGrn;
	logic [15:0][15:0] borderRed;	
	logic [15:0][15:0] borderGrn;
	
	always_comb begin
		 boardRed = '0;
		 boardGrn = '0;
		 for (int c = 0; c < 7; c++) begin
			  for (int r = 0; r < 6; r++) begin
					boardRed[r+5][c+4] = redPixels[c][r];
					boardGrn[r+5][c+4] = grnPixels[c][r];
			  end
		 end
	end
	
	 logic [6:0] selectorRedPixels;
	 logic [6:0] selectorGrnPixels;
	 
	 always_comb begin
		selectorRed = '0;
		selectorGrn = '0;
		for(int c = 0; c < 7; c++) begin
			selectorRed[2][c+4] = selectorRedPixels[c];
			selectorGrn[2][c+4] = selectorGrnPixels[c];
		end
	 end
	 
	 
	 logic d_in;
	 logic d_out;
	 logic button;
	 always_ff @(posedge clkSelect) begin
		if(SW[9]) begin
			d_in <= 0;
			d_out <= 0;
			d[6:0] <= 0;
			up[6:0] <= 0;
		end else begin
			d[6:0] <= SW[7:1];
			up[6:0] <= d[6:0];
			d_in <= ~KEY[0];
			d_out <= d_in;
		end
	end 
	
	always_comb begin
		if (in[6:0] != 7'b1111111)
			LEDR[7:1] = up[6:0];
		else 
			LEDR[7:1] = in[6:0];
	end
	
	always_comb begin
		RedPixels = '0;
		GrnPixels = '0;
		RedPixels = boardRed | selectorRed | borderRed;
		GrnPixels = boardGrn | selectorGrn | borderGrn;	
	end 
	
	logic tie;
	logic turn;
	user_Input press (.out(button), .in(d_out), .clk(clkSelect), .reset(SW[9]));
	tokenPlacer user_select(.column(in[6:0]), .in(button), .sw(up[6:0]), .win(win));
	connectFour game (.reset(SW[9]), .clk(clkSelect), .in(in[6:0]), .win(win), .tie(tie), .turn(turn), .redPixels(redPixels),
		.grnPixels(grnPixels), .hex0(HEX0), .hex1(HEX1), .hex2(HEX2), .hex3(HEX3), .hex4(HEX4), .hex5(HEX5));
		
	columnIndicator hud (.redPixels(selectorRedPixels), .grnPixels(selectorGrnPixels),
		.in(up[6:0]), .win(win), .tie(tie), .turn(turn));
		
	border gameOutline (.RedPixels(borderRed),
		.GrnPixels(borderGrn));
	
	 
endmodule

// Tests all win cases 
// test edge cases (When no column is selected, multiple, and tie)
module DE1_SoC_testbench();	
	 logic         CLOCK_50; 	
	 logic  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 		
	 logic  [9:0]  LEDR; 		
	 logic  [3:0]  KEY;
	 logic  [9:0]  SW; 
	 logic  [35:0] GPIO_1;
	
	DE1_SoC dut (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, GPIO_1, CLOCK_50);	
		
	// Set up a simulated clock.	
	parameter CLOCK_PERIOD=100;	
	initial begin	
		CLOCK_50 <= 0;	
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;	// Forever toggle the clock
	end	
		
	// Test the design.
	assign SW[0] = 0;
	assign SW[8] = 0;
	assign KEY[3:1] = 0;
	initial begin	
				SW[9] <= 1; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50);
			   SW[9] <= 0; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50);
				for(int i = 0; i < 20; i++) begin
					SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50);
					SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
					SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
					repeat(100) @(posedge CLOCK_50);
				end // Checking to see if button works 
				SW[9] <= 1; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50);
			   SW[9] <= 0; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50);
				for(int i = 0; i < 8; i++) begin
					SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50);
					SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
					SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
					repeat(100) @(posedge CLOCK_50);
					SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50);
					SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
					SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
					repeat(100) @(posedge CLOCK_50);
				end //green wins vertical
				SW[9] <= 1; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50);
			   SW[9] <= 0; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50);
				for(int i = 0; i < 3; i++) begin
					SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50);
					SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
					repeat(100) @(posedge CLOCK_50);
					SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50);
					SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
					repeat(100) @(posedge CLOCK_50);
				end 
				SW[7:1] <= 7'b0100000; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b0100000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50); //Red vertical
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0100000; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b0100000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[9] <= 1; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50);
			   SW[9] <= 0; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50);
				for(int i = 0; i < 3; i++) begin
					SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50);
					SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
					repeat(100) @(posedge CLOCK_50);
					SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50);
					SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
					repeat(100) @(posedge CLOCK_50);
				end 
				
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0100000; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0100000; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);	//Green win horizontal
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[9] <= 1; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50);
			   SW[9] <= 0; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50); 
				
				SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b0100000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b0100000; KEY[0] <= 1; @(posedge CLOCK_50); //Red wins vertical 
				repeat(100) @(posedge CLOCK_50);
				
				SW[9] <= 1; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50);
			   SW[9] <= 0; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50); 
				
				SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50); //G
				SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); //R
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); //G
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50); //R
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50); //G
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); //R
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50); //G
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); //R
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); //G
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); //R
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); //G
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);	
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); //r
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); //G Diagonal green wins upward
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				
				SW[9] <= 1; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50);
			   SW[9] <= 0; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); //G
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); //R
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); //G
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);		
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); //R
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50); //G
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50); //R
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); //G
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50); //R
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);	
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); //G
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);	
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); //R
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); //G
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 0; @(posedge CLOCK_50); //R
				SW[7:1] <= 7'b0010000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); //G 
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50); //Diagonal red wins downward
				repeat(100) @(posedge CLOCK_50);
				SW[9] <= 1; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50);
			   SW[9] <= 0; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				
				SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50); ///G //1 lvl1
				SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); ///R //2 lvl1
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //4 lvl1
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50); ///R //3 lvl1
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //5 lvl1
				SW[7:1] <= 7'b0010000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0100000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //6 lvl1
				SW[7:1] <= 7'b0100000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //7 lvl1
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50); ///R //1 lvl2
				SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50); ///G //3 lvl2
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); ///R //2 lvl2
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //7 lvl2
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //4 lvl2
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				
				
				SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50); ///G //1 lvl3
				SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //5 lvl2
				SW[7:1] <= 7'b0010000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); ///G //2 lvl3
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50); 
				SW[7:1] <= 7'b0100000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //6 //level 2 done
				SW[7:1] <= 7'b0100000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //4 //lvl 3
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50); ///R //3 //lvl3
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //5 //lvl3
				SW[7:1] <= 7'b0010000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0100000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //6 //level 3 
				SW[7:1] <= 7'b0100000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //7 lvl3 done
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50); ///R //1 lvl4
				SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //4 //lvl 4
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); ///R //2 lvl4
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //5 //lvl4
				SW[7:1] <= 7'b0010000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50); ///R //3 //lvl4
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0100000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //6 //level 4
				SW[7:1] <= 7'b0100000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //7 lvl4 done
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50); ///G //1 lvl5
				SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50); ///R //3 //lvl5
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); ///G //2 lvl5
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //5 lvl5
				SW[7:1] <= 7'b0010000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //4 //lvl 5
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0100000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //6 //level 5 
				SW[7:1] <= 7'b0100000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //7 lvl5 done
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50); ///R //1 lvl6
				SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50); ///G //3 lvl6
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); ///R //2 lvl6
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //5 //lvl6
				SW[7:1] <= 7'b0010000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //4 lvl6
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0100000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //6 //level 6
				SW[7:1] <= 7'b0100000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //7 lvl6 done
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); 
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); 
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); //buffers
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				
				SW[9] <= 1; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50);
			   SW[9] <= 0; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50);
				
				SW[7:1] <= 7'b1000111; KEY[0] <= 0; @(posedge CLOCK_50); 
				SW[7:1] <= 7'b1000100; KEY[0] <= 1; @(posedge CLOCK_50); //Nothing not valid input
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); //only one
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				
				SW[9] <= 1; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50);
			   SW[9] <= 0; SW[7:1] <= 7'b0000000;@(posedge CLOCK_50);
				
				SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50); ///G //1 lvl1
				SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); ///R //2 lvl1
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //4 lvl1
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50); ///R //3 lvl1
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //5 lvl1
				SW[7:1] <= 7'b0010000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0100000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //6 lvl1
				SW[7:1] <= 7'b0100000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //7 lvl1
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50); ///R //1 lvl2
				SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50); ///G //3 lvl2
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); ///R //2 lvl2
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //7 lvl2
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //4 lvl2
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				
				repeat(100) @(posedge CLOCK_50);
				
				SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50); ///G //1 lvl3
				SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //5 lvl2
				SW[7:1] <= 7'b0010000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); ///G //2 lvl3
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0100000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //6 //level 2 done
				SW[7:1] <= 7'b0100000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //4 //lvl 3
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50); ///R //3 //lvl3
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //5 //lvl3
				SW[7:1] <= 7'b0010000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0100000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //6 //level 3 
				SW[7:1] <= 7'b0100000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //7 lvl3 done
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50); ///R //1 lvl4
				SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //4 //lvl 4
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); ///R //2 lvl4
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //5 //lvl4
				SW[7:1] <= 7'b0010000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50); ///R //3 //lvl4
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0100000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //6 //level 4
				SW[7:1] <= 7'b0100000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //7 lvl4 done
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50); ///G //1 lvl5
				SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50); ///R //3 //lvl5
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); ///G //2 lvl5
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //5 lvl5
				SW[7:1] <= 7'b0010000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //4 //lvl 5
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0100000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //6 //level 5 
				SW[7:1] <= 7'b0100000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //7 lvl5 done
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000001; KEY[0] <= 0; @(posedge CLOCK_50); ///R //1 lvl6
				SW[7:1] <= 7'b0000001; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //7 lvl6
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000010; KEY[0] <= 0; @(posedge CLOCK_50); ///R //2 lvl6
				SW[7:1] <= 7'b0000010; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				
				SW[7:1] <= 7'b0100000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //6 lvl6
				SW[7:1] <= 7'b0100000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0000100; KEY[0] <= 0; @(posedge CLOCK_50); ///R //3 lvl6
				SW[7:1] <= 7'b0000100; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0010000; KEY[0] <= 0; @(posedge CLOCK_50); ///G //5 lvl6
				SW[7:1] <= 7'b0010000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //4 lvl6 //Red wins
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //4 lvl6
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b0001000; KEY[0] <= 0; @(posedge CLOCK_50); ///R //4 lvl6
				SW[7:1] <= 7'b0001000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				
				
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); 
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); 
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				repeat(100) @(posedge CLOCK_50);
				SW[7:1] <= 7'b1000000; KEY[0] <= 0; @(posedge CLOCK_50); //buffers
				SW[7:1] <= 7'b1000000; KEY[0] <= 1; @(posedge CLOCK_50);
				
				
				


		$stop; // End the simulation.	
	end	
endmodule