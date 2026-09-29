// Name: Raiyan Hasan
// Due Date: 3/15/2026
// Class: EE 271

// This module checks to see if the game is tied

// Output:
//		- redPixels [15:0][15:0]: creates the border around the game board
//		- grnPixels [15:0][15:0]: creates the border aorund the game board
module border (RedPixels, GrnPixels);
	output logic [15:0][15:0] RedPixels;
   output logic [15:0][15:0] GrnPixels;	
	
	always_comb begin
		RedPixels = '0;
		GrnPixels = '0;

		//top
		for(int c = 3; c <= 11; c++) begin
			RedPixels[4][c] = 1;
			GrnPixels[4][c] = 1;
		end

		// bottom
		for(int c = 3; c <= 11; c++) begin
			RedPixels[11][c] = 1;
			GrnPixels[11][c] = 1;
		end

		// left
		for(int r = 4; r <= 11; r++) begin
			RedPixels[r][3] = 1;
			GrnPixels[r][3] = 1;
		end

		// right
		for(int r = 4; r <= 11; r++) begin
			RedPixels[r][11] = 1;
			GrnPixels[r][11] = 1;
		end
	end
endmodule
	
//tests to see if the border is created 
module border_testbench();	
	logic [15:0][15:0] redPixels,  grnPixels;
	
	border dut (redPixels, grnPixels);
		
	initial begin	
		#100;

			
	end	
endmodule

			
	