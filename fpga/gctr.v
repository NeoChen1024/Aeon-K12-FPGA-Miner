/* Global Nonce Counter */

module global_counter
(
	input wire clk,
	input wire rst,
	input wire en,
	output reg [63:0] q
);

always @(posedge clk or posedge rst) begin
	if(rst) begin
		q <= 0;
	else
		q <= q + 1;
end
