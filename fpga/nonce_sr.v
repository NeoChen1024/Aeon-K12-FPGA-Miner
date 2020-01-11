module nonce_sr
(
	input wire rst,
	input wire clk,
	input wire en,
	input wire [7:0] data_in,
	output reg [1599:0] data_out
);

always @(posedge clk or posedge rst) begin
	if(rst) begin
		data_out <= 0;
	end
	else begin
		if(en) begin
			data_out <= {data_out, data_in};
		end
	end
end
endmodule
