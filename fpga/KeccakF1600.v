// From @Wolf9466 on Discord

`timescale 1ns / 1ps

`define IDX64(x)            ((x) << 6)+:64
`define ROTL64(x, y)		{x[63 - y : 0],x[63: 63 - y + 1]}

module KeccakF1600Perm(output wire [1599:0] OutState, input wire[1599:0] InState, input wire[63:0] RndConst);

	// It probably seems odd - why the wires used are structured like this,
	// as well as why the input/output states are 1600-bit vectors. The
	// less important reasoning is maintaining compatibility with Verilog at
	// least as far back as its 2001 spec (in contrast to SystemVerilog),
	// as it will not allow passing arrays to modules. The more important
	// is that it seems to produce my *intended* HW design over a large
	// variety of settings with Vivado - even over different versions of it.
	// It often will repeat work - instead of having the 5-input XOR values
	// done, then their XOR with one another only once (Theta) - it'll
	// instead re-do them as needed through Rho, Pi, and even occasionally
	// during Chi as well. The area becomes the relative size of Texas.

	wire [63:0] RoundMid[24:0];
	wire [63:0] Mid0, Mid1, Mid2, Mid3, Mid4, Mid5, Mid6, Mid7, Mid8;
	wire [63:0] Mid9, Mid10, Mid11, Mid12, Mid13, Mid14, Mid15, Mid16;
	wire [63:0] Mid17, Mid18, Mid19, Mid20, Mid21, Mid22, Mid23, Mid24;
	wire [63:0] InitXORVals0, InitXORVals1, InitXORVals2, InitXORVals3, InitXORVals4;
	wire [63:0] MainXORVals0, MainXORVals1, MainXORVals2, MainXORVals3, MainXORVals4;

	genvar x;

	// Theta
	assign InitXORVals0 = InState[`IDX64(0)] ^ InState[`IDX64(5)] ^ InState[`IDX64(10)] ^ InState[`IDX64(15)] ^ InState[`IDX64(20)];
	assign InitXORVals1 = InState[`IDX64(0 + 1)] ^ InState[`IDX64(5 + 1)] ^ InState[`IDX64(10 + 1)] ^ InState[`IDX64(15 + 1)] ^ InState[`IDX64(20 + 1)];
	assign InitXORVals2 = InState[`IDX64(0 + 2)] ^ InState[`IDX64(5 + 2)] ^ InState[`IDX64(10 + 2)] ^ InState[`IDX64(15 + 2)] ^ InState[`IDX64(20 + 2)];
	assign InitXORVals3 = InState[`IDX64(0 + 3)] ^ InState[`IDX64(5 + 3)] ^ InState[`IDX64(10 + 3)] ^ InState[`IDX64(15 + 3)] ^ InState[`IDX64(20 + 3)];
	assign InitXORVals4 = InState[`IDX64(0 + 4)] ^ InState[`IDX64(5 + 4)] ^ InState[`IDX64(10 + 4)] ^ InState[`IDX64(15 + 4)] ^ InState[`IDX64(20 + 4)];

	assign MainXORVals0 = InitXORVals0 ^ `ROTL64(InitXORVals2, 1);
	assign MainXORVals1 = InitXORVals1 ^ `ROTL64(InitXORVals3, 1);
	assign MainXORVals2 = InitXORVals2 ^ `ROTL64(InitXORVals4, 1);
	assign MainXORVals3 = InitXORVals3 ^ `ROTL64(InitXORVals0, 1);
	assign MainXORVals4 = InitXORVals4 ^ `ROTL64(InitXORVals1, 1);

	assign Mid1 = InState[`IDX64(6)] ^ MainXORVals0;
	assign RoundMid[1] = `ROTL64(Mid1, 44);
	assign Mid8 = InState[`IDX64(16)] ^ MainXORVals0;
	assign RoundMid[8] = `ROTL64(Mid8, 45);
	assign Mid10 = InState[`IDX64(1)] ^ MainXORVals0;
	assign RoundMid[10] = `ROTL64(Mid10, 1);
	assign Mid17 = InState[`IDX64(11)] ^ MainXORVals0;
	assign RoundMid[17] = `ROTL64(Mid17, 10);
	assign Mid24 = InState[`IDX64(21)] ^ MainXORVals0;
	assign RoundMid[24] = `ROTL64(Mid24, 2);

	assign Mid2 = InState[`IDX64(12)] ^ MainXORVals1;
	assign RoundMid[2] = `ROTL64(Mid2, 43);
	assign Mid9 = InState[`IDX64(22)] ^ MainXORVals1;
	assign RoundMid[9] = `ROTL64(Mid9, 61);
	assign Mid11 = InState[`IDX64(7)] ^ MainXORVals1;
	assign RoundMid[11] = `ROTL64(Mid11, 6);
	assign Mid18 = InState[`IDX64(17)] ^ MainXORVals1;
	assign RoundMid[18] = `ROTL64(Mid18, 15);
	assign Mid20 = InState[`IDX64(2)] ^ MainXORVals1;
	assign RoundMid[20] = `ROTL64(Mid20, 62);

	assign Mid3 = InState[`IDX64(18)] ^ MainXORVals2;
	assign RoundMid[3] = `ROTL64(Mid3, 21);
	assign Mid5 = InState[`IDX64(3)] ^ MainXORVals2;
	assign RoundMid[5] = `ROTL64(Mid5, 28);
	assign Mid12 = InState[`IDX64(13)] ^ MainXORVals2;
	assign RoundMid[12] = `ROTL64(Mid12, 25);
	assign Mid19 = InState[`IDX64(23)] ^ MainXORVals2;
	assign RoundMid[19] = `ROTL64(Mid19, 56);
	assign Mid21 = InState[`IDX64(8)] ^ MainXORVals2;
	assign RoundMid[21] = `ROTL64(Mid21, 55);

	assign Mid4 = InState[`IDX64(24)] ^ MainXORVals3;
	assign RoundMid[4] = `ROTL64(Mid4, 14);
	assign Mid6 = InState[`IDX64(9)] ^ MainXORVals3;
	assign RoundMid[6] = `ROTL64(Mid6, 20);
	assign Mid13 = InState[`IDX64(19)] ^ MainXORVals3;
	assign RoundMid[13] = `ROTL64(Mid13, 8);
	assign Mid15 = InState[`IDX64(4)] ^ MainXORVals3;
	assign RoundMid[15] = `ROTL64(Mid15, 27);
	assign Mid22 = InState[`IDX64(14)] ^ MainXORVals3;
	assign RoundMid[22] = `ROTL64(Mid22, 39);

	assign Mid0 = InState[`IDX64(0)] ^ MainXORVals4;
	assign RoundMid[0] = Mid0;
	assign Mid7 = InState[`IDX64(10)] ^ MainXORVals4;
	assign RoundMid[7] = `ROTL64(Mid7, 3);
	assign Mid14 = InState[`IDX64(20)] ^ MainXORVals4;
	assign RoundMid[14] = `ROTL64(Mid14, 18);
	assign Mid16 = InState[`IDX64(5)] ^ MainXORVals4;
	assign RoundMid[16] = `ROTL64(Mid16, 36);
	assign Mid23 = InState[`IDX64(15)] ^ MainXORVals4;
	assign RoundMid[23] = `ROTL64(Mid23, 41);

	// Chi / Iota
	assign OutState[`IDX64(0)] = RoundMid[0] ^ ((~RoundMid[1]) & RoundMid[2]) ^ RndConst;
	assign OutState[`IDX64(1)] = RoundMid[1] ^ ((~RoundMid[2]) & RoundMid[3]);
	assign OutState[`IDX64(2)] = RoundMid[2] ^ ((~RoundMid[3]) & RoundMid[4]);
	assign OutState[`IDX64(3)] = RoundMid[3] ^ ((~RoundMid[4]) & RoundMid[0]);
	assign OutState[`IDX64(4)] = RoundMid[4] ^ ((~RoundMid[0]) & RoundMid[1]);

	generate
		for(x = 5; x < 25; x = x + 5)
		begin : CHILOOP0
			assign OutState[`IDX64(0 + x)] = RoundMid[0 + x] ^ ((~RoundMid[1 + x]) & RoundMid[2 + x]);
			assign OutState[`IDX64(1 + x)] = RoundMid[1 + x] ^ ((~RoundMid[2 + x]) & RoundMid[3 + x]);
			assign OutState[`IDX64(2 + x)] = RoundMid[2 + x] ^ ((~RoundMid[3 + x]) & RoundMid[4 + x]);
			assign OutState[`IDX64(3 + x)] = RoundMid[3 + x] ^ ((~RoundMid[4 + x]) & RoundMid[0 + x]);
			assign OutState[`IDX64(4 + x)] = RoundMid[4 + x] ^ ((~RoundMid[0 + x]) & RoundMid[1 + x]);
		end
	endgenerate
endmodule
