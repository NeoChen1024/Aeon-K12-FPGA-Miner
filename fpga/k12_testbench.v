`timescale 10ns/1ps

module k12_testbench;
	reg clk, rst, start;
	reg [575:0] blob;
	reg [63:0] nonce;
	reg [63:0] target;
	wire [255:0] hash;
	wire store;

K12_PoW hasher0
(
	.clk(clk),
	.rst(rst),
	.load(start),
	.target(target),
	.blob(blob),
	.nonce(nonce),
	.outputhash(hash),
	.store(store)
);

always #5 clk <= ~clk;

initial begin
	clk <= 0;
	rst <= 0;
	start <= 0;
	target <= 64'h0000000024a67fcd;
	blob <= 576'h03b224cbed8b20cec1ff6c918f9783388c225fdf33c6510374f7ec56198b968b3610f384789f32c09424884a75bec322a3e5ae78db7e1c9219e3ad14118581975105f18782980808;
	nonce <= 64'h00000002c9146afa;
	#40	start <= 1;
	#1	start <= 0;
	#320	$stop;
end
endmodule
