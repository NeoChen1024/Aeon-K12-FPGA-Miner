`timescale 1ns/1ps
`define def_update_period (32'd100000 - 1) // Increment interval

module counter_test;

	reg [31:0] timer;
	reg [15:0] data;
	reg clock;

	always #500 clock = ~clock

	always @(posedge clk)
		if(timer == `def_update_period) begin
			timer <= 0;
			data <= data + 1;
		end
		else
			timer <= timer + 1'b1;
endmodule
