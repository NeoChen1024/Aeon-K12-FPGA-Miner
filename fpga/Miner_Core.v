module Miner_Core #(
	parameter cores=1
)
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
	wire reset;
	wire [14:0] display;	// High 3 bits is dp
	reg [14:0] display_reg;

	// UART signals
	reg transmit;	// Signal to transmit
	wire transmitting;
	wire received;	// Received byte
	wire receiving;
	wire [7:0] rx_data;
	reg [7:0] tx_data;
	wire recv_error;

	assign display = display_reg;
	assign led = ~(receiving | transmitting);	// low-active
	assign reset = ~reset_button;

	// 7 segment display driver
	segment_display disp0
	(
		.clk(clk_lf),
		.rst(reset),
		.data(display[11:0]),
		.dp(display[14:12]),
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
		.locked(pll_locked)
	);

	// UART
	uart uart0(
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

	// UART loopback
	always @(posedge clk_hf or posedge reset) begin
		if(reset)
			display_reg <= 0;
		else begin
			if(!transmitting)
				transmit <= 0;
			if(received) begin
				display_reg <= display_reg + rx_data;
				tx_data <= rx_data;
				transmit <= received;
			end
		end
	end
endmodule
