`timescale 1ns/1ps
`define def_update_period (32'd10000000 - 1) // Increment interval

module counter_testbench;
	reg [31:0] timer;
	reg [15:0] data;
	reg clock;
	reg reset;
	wire [7:0] display;
	wire [2:0] select;

	segment_display d0
	(
		.clk(clock),
		.rst(reset),
		.data(data[11:0]),
		.segment(display),
		.dp(data[14:12]),
		.select(select)
	);

	initial begin
		#0 timer <= 0;
		#0 data <= 0;
		#0 clock <= 0;
		#0 reset <= 0;
		#8 reset <= 1;
		#16 reset <= 0;
	end

	always #1 clock = ~clock;

	always @(posedge clock) begin
		if(timer == `def_update_period) begin
			timer <= 0;
			data <= data + 1;
		end
		else
			timer <= timer + 1'b1;
	end
endmodule
