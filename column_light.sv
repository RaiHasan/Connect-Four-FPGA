// Name: Raiyan Hasan
// Due Date: 3/15/2026
// Class: EE 271

// This module changes each collumns according to the player move

// Input:
//		- clk: Clock for this module
//		- reset: reset for this module
//		- turn: Players turn
//		- in: Input for player

// Output:
//		- redPixels [5:0]: led repersenting p2 token
//		- grnPixels [5:0]: led repersenting p1 token
//		- redDisplay[5:0]: the red leds for the display
//		- grnDisplay[5:0]: the green leds for the display
module column_light(clk, reset, redPixels, grnPixels, redDisplay, grnDisplay, turn, in);
	input logic clk, reset, turn, in;
	output logic [5:0] redPixels,  grnPixels;
	output logic [5:0] redDisplay,  grnDisplay;
	logic [2:0] count;
	logic  [2:0] fall_pos;
	logic falling;
	logic [24:0] timer; 
	logic prev_timer;
   logic timer_tick;
	logic falling_color;
	
	
	always_ff @(posedge clk) begin
        if(reset)
            timer <= 0;
        else
            timer <= timer + 1;
    end

	 
	 
    always_ff @(posedge clk) begin
        prev_timer <= timer[3];  
    end

    assign timer_tick = timer[3] & ~prev_timer; //switch on and off


    always_ff @(posedge clk) begin

        if(reset) begin
            count <= 3'd5;
            fall_pos <= 0;
            falling <= 0;
            redPixels <= 6'b0;
            grnPixels <= 6'b0;
        end

        else begin
            if(in && !falling && count <= 5) begin
                falling <= 1;
                fall_pos <= 0;
					 falling_color <= turn;   
            end
            if(falling && timer_tick) begin

                if(fall_pos < count)
                    fall_pos <= fall_pos + 1;
							
                else begin
                    case(falling_color)
                        1'b1: redPixels[count] <= 1'b1;
                        1'b0: grnPixels[count] <= 1'b1;
                    endcase
                    count <= count - 1;
						  falling <= 0;
                end

            end

        end
    end

    always_comb begin

        redDisplay = redPixels;
        grnDisplay = grnPixels;

        if(falling) begin
            if(falling_color)
                redDisplay[fall_pos] = 1'b1;
            else
                grnDisplay[fall_pos] = 1'b1;
        end

    end	

endmodule
	
	
	

module column_light_testbench();	
	logic CLOCK_50, reset, in, turn;
	logic [5:0] redPixels,  grnPixels;
	logic [5:0] redDisplay,  grnDisplay;
	
	parameter CLOCK_PERIOD=100;	
	initial begin	
		CLOCK_50 <= 0;	
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;	// Forever toggle the clock
	end	
		
	column_light dut (CLOCK_50,reset, redPixels, grnPixels, redDisplay, grnDisplay, turn, in);
		
	initial begin	
			repeat(1) @(posedge CLOCK_50);
			reset <= 1; repeat(1) @(posedge CLOCK_50);
			reset <= 0; in <= 1; turn <= 1; repeat(500) @(posedge CLOCK_50); //RED
			reset <= 1; in <= 0; repeat(2) @(posedge CLOCK_50);
			reset <= 0; in <= 1; turn <= 0; repeat(500) @(posedge CLOCK_50); //Green
			in <= 1; turn <= 1; repeat(3) @(posedge CLOCK_50); //Green
			reset <= 1; turn <= 0; repeat(1) @(posedge CLOCK_50);
			reset <= 0; in <= 1; turn <= 0; repeat(300) @(posedge CLOCK_50); //Green
			reset <= 0; in <= 1; turn <= 1; repeat(200) @(posedge CLOCK_50); //Red 
			
		$stop; // End the simulation.	
	end	
endmodule 