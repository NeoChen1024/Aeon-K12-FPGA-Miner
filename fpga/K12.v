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
(
	input wire clk,
	input wire rst,
	input wire load,
	input wire [63:0] target,
	input wire [63:0] nonce,
	input wire [575:0] blob,
	output reg [255:0] outputhash,	// Tri-state
	output reg store		// Store into FIFO
);

wire valid;
wire [1599:0] hashinput;
wire [255:0] hashoutput;

K12_Hash hasher
(
	.clk(clk),
	.rst(rst),
	.start(load),
	.data(hashinput),
	.hash(hashoutput),
	.valid(valid)
);

assign hashinput = {256'h0, 64'h8000000000000000, 576'h0, 64'h700, blob[575:312], nonce, blob[311:0]};

// Check if hash is small than target
always @(posedge clk) begin
	if(valid) begin
		if(hashoutput[255-:64] < target) begin
			outputhash <= hashoutput;
			store <= 1;
		end
		else begin
			store <= 0;
		end
	end
	else begin
		outputhash <= {255{1'bZ}};
		store <= 0;
	end
end

always @(posedge clk or posedge rst or posedge load) begin
	if(rst | load) begin
		outputhash <= {255{1'bZ}};
		store <= 0;
	end
end
endmodule
