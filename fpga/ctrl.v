`define HASH_CYCLE	14

module controller
#(
	parameter NCORE = 2
)
(
	input wire rst,
	input wire clk,
	input wire load,
	input wire halt,
	input wire [639:0] job,
	output wire [63:0] nonce_bus,
	output wire nonce_bus_wr
);

// Pipeline selector
reg [13:0] select;
wire [(NCORE - 1):0] write;

assign nonce_bus_wr =| write;

always @(posedge clk or posedge rst or posedge load) begin
	if(rst | load)
		select <= 7'b0000001;
	else begin
		if(halt)
			select <= 0;
		else begin
			if(select == 0)
				select <= 1;
			else
				select <= {select[12:0],select[13]};
		end
	end
end

generate
	genvar i;

	for(i = 0; i < NCORE; i = i + 1) begin : PoW_Cores
		K12_PoW
		#(
			.CORE(i),
			.NCORE(NCORE)
		) PoW_Core
		(
			.clk(clk),
			.rst(rst | halt),
			.start(select[(`HASH_CYCLE / NCORE) * i]),
			.load(load),
			.target(job[0+:64]),
			.blob(job[64+:576]),
			.nonce(nonce_bus),
			.store(write[i])
		);
	end
endgenerate

endmodule
