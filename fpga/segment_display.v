`timescale 1ns/1ps

// 4 Bit hexdecimal to 7 segment
module segment_encoder
(
	input clk,
	input rst,
	input [3:0] data,
	input dp,
	output reg [7:0] segment
);

	parameter
		_0 = 7'b100_0000,
		_1 = 7'b111_1001,
		_2 = 7'b010_0100,
		_3 = 7'b011_0000,
		_4 = 7'b001_1001,
		_5 = 7'b001_0010,
		_6 = 7'b000_0010,
		_7 = 7'b111_1000,
		_8 = 7'b000_0000,
		_9 = 7'b001_0000,
		_A = 7'b000_1000,
		_B = 7'b000_0011,
		_C = 7'b100_0110,
		_D = 7'b010_0001,
		_E = 7'b000_0110,
		_F = 7'b000_1110;

	always @(posedge clk or posedge rst) begin
		if(rst) begin
			segment <= 8'b1111_1111;
		end
		else begin
			case(data)
				4'h0:	segment = {dp, _0};
				4'h1:	segment = {dp, _1};
				4'h2:	segment = {dp, _2};
				4'h3:	segment = {dp, _3};
				4'h4:	segment = {dp, _4};
				4'h5:	segment = {dp, _5};
				4'h6:	segment = {dp, _6};
				4'h7:	segment = {dp, _7};
				4'h8:	segment = {dp, _8};
				4'h9:	segment = {dp, _9};
				4'hA:	segment = {dp, _A};
				4'hB:	segment = {dp, _B};
				4'hC:	segment = {dp, _C};
				4'hD:	segment = {dp, _D};
				4'hE:	segment = {dp, _E};
				4'hF:	segment = {dp, _F};
			endcase
		end
	end
endmodule

// Whole module
module segment_display
(
	input wire clk,
	input wire rst,
	input wire update,
	input wire [14:0] data,
	output wire [7:0] segment,
	output reg [2:0] select
);

	reg [14:0] display_data;
	reg [1:0] sel;
	reg [3:0] current_digit;
	reg current_dp;
	
	segment_encoder s0
	(
		.clk(clk),
		.rst(rst),
		.data(current_digit),
		.dp(current_dp),
		.segment(segment)
	);

	always @(posedge rst or posedge update) begin
		if(rst)
			display_data <= 0;
		else
			display_data <= data;
	end

	always @(posedge clk or posedge rst) begin
		if(rst) begin
			current_digit <= 0;
			current_dp <= 0;
			select <= 0;
			sel <= 0;
		end
		else begin
			sel <= sel + 1;
			case(sel)
				2'b00: begin
					current_digit <= display_data[3:0];
					current_dp <= ~display_data[12];
					select <= 3'b001;
				end
				2'b01: begin
					current_digit <= display_data[7:4];
					current_dp <= ~display_data[13];
					select <= 3'b010;
				end
				2'b10: begin
					current_digit <= display_data[11:8];
					current_dp <= ~display_data[14];
					select <= 3'b100;
				end
				2'b11: begin
					select <= 3'b000;
				end
			endcase
		end
	end
endmodule
