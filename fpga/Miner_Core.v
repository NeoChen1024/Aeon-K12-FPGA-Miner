module Miner_Core
(
	input wire uart_rx,
	output wire uart_tx,
	input wire xtal_osc,
	input wire reset_button,
	output wire led,
	output wire [7:0] segment,
	output wire [2:0] sel
);

	wire pll_locked;
	wire clk_lf;	// 1MHz
	wire clk_hf;	// 100MHz
	wire clk_llf;	// 2kHz
	wire reset;

	wire [14:0] display;

	// UART signals
	wire transmit;	// Signal to transmit
	wire transmitting;
	wire received;	// Received byte
	wire receiving;
	wire [7:0] rx_data;
	wire [7:0] tx_data;
	wire recv_error;

	// FIFO signals
	wire fifo_empty;
	wire fifo_full;
	wire fifo_wr;
	wire fifo_rd;
	wire [63:0] nonce_bus;
	wire [63:0] nonce_sr_in;

	assign fifo_rd = nonce_sr_load;

	// Controller bus
	wire load;
	wire halt;
	wire [575:0] blob;
	wire [63:0] nonce;

	wire [639:0] job_bus; // High 72 bytes: blob, low 8 bytes: target

	assign reset = ~reset_button;

	// Display Format:
	// Digits: 0 1 2
	// DP[0] is FIFO full
	assign display = {fifo_full, 2'b00, nonce_bus[63:52]};

	// LED indicator
	assign led = halt;	// low-active

	// 7 segment display driver
	segment_display disp0
	(
		.clk(clk_lf),
		.rst(reset),
		.update(fifo_wr),
		.data(display),
		.segment(segment),
		.select(sel)
	);

	// PLL clock generation
	pll pll0
	(
		.areset(reset),
		.inclk0(xtal_osc),
		.c0(clk_hf),
		.c1(clk_lf),
		.c2(clk_llf),
		.locked(pll_locked)
	);

	// UART
	uart uart0
	(
		.clk(clk_hf),
		.rst(reset),
		.rx(uart_rx),
		.tx(uart_tx),
		.transmit(transmit),
		.tx_byte(tx_data),
		.received(received),
		.rx_byte(rx_data),
		.is_receiving(receiving),
		.is_transmitting(transmitting),
		.recv_error(recv_error)
	);

	job_sr job_sr0
	(
		.clk(received), // UART received
		.rst(rst),
		.data_in(rx_data),
		.data_out(job_bus)
	);

	ifsm ifsm0
	(
		.clk(clk_hf),
		.rst(rst),
		.uart_recv(received),
		.receiving(halt),
		.received(load)
	);

	ofsm ofsm0
	(
		.clk(clk_hf),
		.rst(rst),
		.avail(~fifo_empty),
		.tx_idle(~transmitting),
		.transmit(transmit),
		.load(nonce_sr_load)
	);

	nonce_sr nonce_sr0
	(
		.clk(clk_hf),
		.rst(rst),
		.en(transmit),
		.load(nonce_sr_load),
		.nonce(nonce_sr_in),
		.data_out(tx_data)
	);

	controller
	#(
		.NCORE(2)
	) c0
	(
		.clk(clk_hf),
		.rst(rst),
		.load(load),
		.halt(halt),
		.job(job_bus),
		.nonce_bus(nonce_bus),
		.nonce_bus_wr(fifo_wr)
	);

	nonce_fifo	nonce_fifo0
	(
		.aclr (rst),
		.clock (clk_hf),
		.data (nonce_bus),
		.rdreq (fifo_rd),
		.wrreq (fifo_wr),
		.empty (fifo_empty),
		.full (fifo_full),
		.q (nonce_sr_in),
		//.usedw()
	);
endmodule
