/* Input FSM */

module ifsm
(
	input wire clk,
	input wire rst,
	input wire uart_recv,
	output reg receiving,	// To stop other component during receiving
	output reg received	// To nonce controller
);

// States
parameter IDLE	= 0;
parameter RECV	= 1;
parameter RECD	= 2;
parameter CLR	= 3;
parameter DONE	= 4;

// There's 80 bytes to pull from UART

reg [6:0] ctr;
reg [2:0] state;
reg clr;

always @(posedge uart_recv or posedge rst or posedge clr) begin
	if(rst)
		ctr <= 0;
	else begin
		if(clr)
			ctr <= 0;
		else
			ctr <= ctr + 1'b1;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		state <= 0;
	end
	else begin
		if (clk) begin
			case(state)
				IDLE: begin
					if(ctr != 0) begin
						state <= RECV;
						receiving <= 1;
					end
				end
				RECV: begin
					if(ctr == 7'd80)
						state <= RECD;
				end
				RECD: begin
					receiving <= 0;
					received <= 1;
					state <= CLR;
				end
				CLR: begin
					received <= 0;
					clr <= 1;
					state <= DONE;
				end
				DONE: begin
					clr <= 0;
					state <= IDLE;
				end
			endcase
		end
	end
end

endmodule

/* ========================================================================== */

module ofsm
(
	input wire clk,
	input wire rst,
	input wire avail,	// There's data in FIFO
	input wire tx_idle,	// TX is idle now
	output reg transmit,
	output reg load	// Load from FIFO to Shift Register
);

// States
parameter IDLE = 0;
parameter TRAN = 1;
parameter TXED = 2;
parameter WAIT = 3;
parameter DONE = 4;

reg [3:0] ctr;	// One additional bit to indicate that we tx'ed 8 bytes
reg [2:0] state;

always @(posedge clk) begin
	if(rst) begin
		ctr <= 0;
		state <= 0;
	end
	else begin
		case(state)
			IDLE: begin
				if(avail && tx_idle) begin
					state <= TRAN;
					load <= 1;
				end
			end
			TRAN: begin
				load <= 0;
				if(ctr[3])
					state <= DONE;
				else begin
					transmit <= 1;
				end
			end
			TXED: begin
				ctr <= ctr + 1'b1;
				transmit <= 0;
				state <= WAIT;
			end
			WAIT: begin
				if(tx_idle)
					state <= TRAN;
			end
			DONE: begin
				ctr <= 0;
				state <= IDLE;
			end
		endcase
	end
end
endmodule
