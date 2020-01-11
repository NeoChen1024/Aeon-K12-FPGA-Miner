`timescale 1ns/1ps

module k12_testbench;
	reg clk, rst, start;
	reg [1599:0] data;
	wire [255:0] hash;
	wire valid;

K12_Hash hasher0
(
	.clk(clk),
	.rst(rst),
	.start(start),
	.data(data),
	.hash(hash),
	.valid(valid)
);

always #1 clk <= ~clk;

initial begin
	clk <= 0;
	rst <= 0;
	start <= 0;
	data <= {{4{64'h0000000000000000}}, 64'h8000000000000000, {19{64'h0000000000000000}}, 64'h0000000000070000};
	#40	start <= 1;
	#8	start <= 0;
end
endmodule
