// Name: Raiyan Hasan
// Due Date: 3/15/2026
// Class: EE 271

// This module handels input of selector values and input

// Input:
//		- in: A button or single inpyt value to indicate placing token
//		- sw[6:0]: selector for column
//		- win: if game is won

// Output:
//		- column [6:0]: output of the column that is selected and token will be placed 
module tokenPlacer (column, in, sw, win);
	input logic in, win;
	input logic [6:0] sw;
	output logic [6:0] column;
	
	always_comb begin
		if(in && ~win) begin
			case(sw)
				7'b0000001: column = 7'b0000001;
				7'b0000010: column = 7'b0000010;
				7'b0000100: column = 7'b0000100;
				7'b0001000: column = 7'b0001000;
				7'b0010000: column = 7'b0010000;
				7'b0100000: column = 7'b0100000;
				7'b1000000: column = 7'b1000000;
				default: column = 7'b1111111;
			endcase 
		end else if(win) begin
			column = 7'b1111111;
		end else begin
			column = 7'b0000000;
		end
	end
endmodule


// Tests edge cases if selectors is multple collumns
// test to see if input is when game is one
// tests to see ouput follows selector and inputs
module tokenPlacer_testbench();	
	logic in, win;
	logic [6:0] sw;
	logic [6:0] column;
	
	tokenPlacer dut (column, in, sw, win);
	
	initial begin	
		sw = '0; in = 0; win = 0; #10;
		sw = 7'b0000001; in = 1; win = 0; #10;
		sw = 7'b0000010; in = 1; win = 0; #10;
		sw = 7'b0000100; in = 1; win = 0; #10;
		sw = 7'b0001000; in = 1; win = 0; #10;
		sw = 7'b0010000; in = 1; win = 0; #10;
		sw = 7'b0100000; in = 1; win = 0; #10;
		sw = 7'b1000000; in = 1; win = 0; #10;
		sw = 7'b1110000; in = 1; win = 0; #10; //0
		sw = 7'b1000000; in = 1; win = 1; #10; //11111111
		sw = 7'b0000100; in = 1; win = 1; #10; //11111111
		sw = 7'b0000100; in = 0; win = 1; #10; //11111111
		sw = 7'b1111111; in = 1; win = 0; #10; //0
		sw = 7'b1101101; in = 1; win = 0; #10; //0
		sw = 7'b0000000; in = 0; win = 0; #10;
	end
endmodule 