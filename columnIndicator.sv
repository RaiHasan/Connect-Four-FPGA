// Name: Raiyan Hasan
// Due Date: 3/15/2026
// Class: EE 271

// This module lets the LED board indicate which column is on and which token is placed
// The indicator hovers above the board and indicated which collumns the token will be placed
// It will show yellow over all collums once the game is won or tied

// Input:
//		- in [6:0]: 7'input value that repersents which collumn is being shown
//		- turn: Players turn to change indicator color
//		- win and tie: if the game is won or tied

// Output:
//		- redPixels [6:0]: led repersenting p2 token or yellow
//		- grnPixels [6:0]: led repersenting p1 token or yellow

module columnIndicator (redPixels, grnPixels, in, win, tie, turn);
	input logic [6:0] in;
	input logic win, tie, turn;
	output logic [6:0] redPixels, grnPixels;
	
	always_comb begin
		redPixels = '0;
		grnPixels = '0;
		if(~win && ~tie) begin
			case(in)
				7'b0000001: begin
					if(turn) begin
						redPixels = 7'b0000001; 
						grnPixels = 7'b0000000;
					end else begin
						redPixels = 7'b0000000; 
						grnPixels = 7'b0000001;
					end
				end 7'b0000010: begin
					if(turn) begin
						redPixels = 7'b0000010; 
						grnPixels = 7'b0000000;
					end else begin
						redPixels = 7'b0000000; 
						grnPixels = 7'b0000010;
					end
				end 7'b0000100: begin
					if(turn) begin
						redPixels = 7'b0000100; 
						grnPixels = 7'b0000000;
					end else begin
						redPixels = 7'b0000000; 
						grnPixels = 7'b0000100;
					end
				end 7'b0001000: begin 
					if(turn) begin
						redPixels = 7'b0001000; 
						grnPixels = 7'b0000000;
					end else begin
						redPixels = 7'b0000000; 
						grnPixels = 7'b0001000;
					end
				end 7'b0010000: begin
					if(turn) begin
						redPixels = 7'b0010000; 
						grnPixels = 7'b0000000;
					end else begin
						redPixels = 7'b0000000; 
						grnPixels = 7'b0010000;
					end
				end 7'b0100000: begin 
					if(turn) begin
						redPixels = 7'b0100000; 
						grnPixels = 7'b0000000;
					end else begin
						redPixels = 7'b0000000; 
						grnPixels = 7'b0100000;
					end
				end 7'b1000000: begin 
					if(turn) begin
						redPixels = 7'b1000000; 
						grnPixels = 7'b0000000;
					end else begin
						redPixels = 7'b0000000; 
						grnPixels = 7'b1000000;
					end
				end default: begin
					redPixels = 7'b0000000; 
					grnPixels = 7'b0000000;
				end
			endcase
		end else if((win || tie)) begin
			redPixels = '1; 
			grnPixels = '1;
		end else begin
			redPixels = '0; 
			grnPixels = '0;
		end
	end
endmodule

// Tests to see if the collumn indicator works appropriatly with win, tie, and turn
module columnIndicator_testbench();	
	logic [6:0] redPixels,  grnPixels;
	logic [6:0] in;
	logic win, tie, turn;
	
	
	
	columnIndicator dut (redPixels, grnPixels, in, win, tie, turn);
		
	initial begin	
			in = 7'b0000000; win = 0; tie = 0; turn = 0; #10;
			in = 7'b0000000; #10;
			in = 7'b1110000; #10;
			in = 7'b0000001; #10;
			in = 7'b0000010; #10;
			in = 7'b0000100; #10;
			in = 7'b0001000; #10;
			in = 7'b0010000; #10;
			in = 7'b0100000; #10;
			in = 7'b1000000; #10;
			
			in = 7'b0000000; turn = 1; #10; 
			in = 7'b1110000; #10;
			in = 7'b0000001; #10;
			in = 7'b0000010; #10;
			in = 7'b0000100; #10;
			in = 7'b0001000; #10;
			in = 7'b0010000; #10;
			in = 7'b0100000; #10;
			in = 7'b1000000; #10;
		   in = 7'b1000000; win = 1; #10;
			in = 7'b1000000; win = 0; tie <= 1; turn = 1; #10;
			in = 7'b1000000; win = 1; tie <= 1;  turn = 0;#10;
	end	
endmodule 

