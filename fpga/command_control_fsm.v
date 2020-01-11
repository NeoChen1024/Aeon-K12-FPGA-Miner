module control_fsm
(
	input wire clk,
	input wire rst,
	input wire rx_avail,
	input wire [7:0] fifo_rx,
	output reg tx_transmit,
	output reg [7:0] fifo_tx,
	output reg [255:0] nonce,
	output reg start_scan_nonce,
	input wire [63:0] nonce_result,
	input wire nonce_done
);
