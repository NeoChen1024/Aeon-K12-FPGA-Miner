module job_sr	// Serial in, Parallel out
(
	input wire rst,
	input wire load,
	input wire [7:0] data_in,
	output reg [639:0] data_out	// Blob & Target
);

always @(posedge load or posedge rst) begin
	if(rst) begin
		data_out <= 0;
	end
	else begin
		data_out <= {data_out, data_in};
	end
end
endmodule

/* ========================================================================== */

module nonce_sr		// Parallel in, Serial out
(
	input wire rst,
	input wire out,
	input wire load,
	input wire [63:0] nonce,	// Result hash & nonce
	output reg [7:0] data_out
);

reg [63:0] shiftreg;

always @(posedge out or posedge rst or posedge load) begin
	if(rst) begin
		data_out <= 0;
		shiftreg <= 0;
	end
	else if(load) begin
		{data_out, shiftreg} <= {nonce, 8'h00};
	end
	else begin
			{data_out, shiftreg} <= {shiftreg, 8'h00};
	end
end
endmodule
