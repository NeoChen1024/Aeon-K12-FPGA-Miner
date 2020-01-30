/*===============================*\
|| K12 Hash Finite State Machine ||
\*===============================*/

module K12_Hash
(
	input wire clk,
	input wire rst,
	input wire start,
	input wire [1599:0] data,
	output reg [255:0] hash,
	output reg valid
);

wire [1599:0] roundoutput;

reg [63:0] rndconst;	// RndConst Vaule
reg [1599:0] imm;	// Intermediate value

// FSM states
parameter	//	(Reset)	Start
		_R0	= 0,
		_R1	= 1,
		_R2	= 2,
		_R3	= 3,
		_R4	= 4,
		_R5	= 5,
		_R6	= 6,
		_R7	= 7,
		_R8	= 8,
		_R9	= 9,
		_R10	= 10,
		_R11	= 11,	// Valid Output
		_END	= 12;

parameter
	_RND0	= 64'h000000008000808b,
	_RND1	= 64'h800000000000008b,
	_RND2	= 64'h8000000000008089,
	_RND3	= 64'h8000000000008003,
	_RND4	= 64'h8000000000008002,
	_RND5	= 64'h8000000000000080,
	_RND6	= 64'h000000000000800a,
	_RND7	= 64'h800000008000000a,
	_RND8	= 64'h8000000080008081,
	_RND9	= 64'h8000000000008080,
	_RND10	= 64'h0000000080000001,
	_RND11	= 64'h8000000080008008;

KeccakF1600Perm keccakF1600_compute
(
	.InState(imm),
	.OutState(roundoutput),
	.RndConst(rndconst)
);

reg [3:0] state; // FSM state register

always @(posedge clk or posedge start or posedge rst) begin
	if(start || rst) begin
		if(rst)
			state <= _END;
		else
			state <= _R0;
		imm <= data;
		rndconst <= _RND0;
		valid <= 0;
	end
	else if(state <= _R11) begin
		case(state)
			_R0: begin
				rndconst <= _RND1;
			end
			_R1: begin
				rndconst <= _RND2;
			end
			_R2: begin
				rndconst <= _RND3;
			end
			_R3: begin
				rndconst <= _RND4;
			end
			_R4: begin
				rndconst <= _RND5;
			end
			_R5: begin
				rndconst <= _RND6;
			end
			_R6: begin
				rndconst <= _RND7;
			end
			_R7: begin
				rndconst <= _RND8;
			end
			_R8: begin
				rndconst <= _RND9;
			end
			_R9: begin
				rndconst <= _RND10;
			end
			_R10: begin
				rndconst <= _RND11;
			end
			_R11: begin
				hash <= roundoutput[255:0];
				valid <= 1;
			end
			default:
				;	// No-op
		endcase
		state <= state + 1;
		imm <= roundoutput; // Feedback
	end
end

endmodule

module K12_PoW
#(
	parameter CORE=0,	// Index number of this core
	parameter NCORE=1	// Total number of cores
)
(
	input wire clk,		// Clock
	input wire rst,		// Reset
	input wire start,	// Increment counter & start hash
	input wire load,	// Signal to load blob and restart counter
	input wire [63:0] target,	// Target
	input wire [575:0] blob,	// Blob
	output reg [63:0] nonce,	// Tri-state nonce output
	output reg store		// Store into FIFO
);

wire valid;
wire [1599:0] hashinput;
wire [255:0] hashoutput;

reg [63:0] _nonce;	// Internal Nonce Counter
reg [63:0] _lastnonce;	// Last Nonce
reg [63:0] _target;	// Internal one, to reduce latency

K12_Hash hasher
(
	.clk(clk),
	.rst(rst),
	.start(start),
	.data(hashinput),
	.hash(hashoutput),
	.valid(valid)
);

// Combine nonce & blob
assign hashinput = {256'h0, 64'h8000000000000000, 576'h0, 64'h700, blob[575:312], nonce, blob[311:0]};

// Check if hash is smaller than target
always @(posedge clk or posedge rst) begin
	if(rst) begin
		nonce <= {64{1'bZ}};
		store <= 0;
	end
	else begin
		if(valid && (hashoutput[255-:64] < _target)) begin
			nonce <= _lastnonce;
			store <= 1;
		end
		else begin
			nonce <= {64{1'bZ}};
			store <= 0;
		end
	end
end

always @(posedge rst or posedge load or posedge start) begin
	if(rst || load) begin
		_nonce <= CORE;
		_target <= target;
	end
	else if(start) begin
		_nonce <= _nonce + NCORE;	// Increment for every start
		_lastnonce <= _nonce;
	end
end

endmodule
