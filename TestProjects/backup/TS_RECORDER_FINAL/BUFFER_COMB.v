module BUFFER_COMB #(
	parameter WIDTH = 10									// 10-bit wide buffer by default.
	)(
	input							CLOCK		,				// Clock signal for the buffer.
	input							RESET		,				// Reset signal.
	input		  [WIDTH-1 : 0]DATA_IN	,				// Input data, WIDTH-bits wide.
	output 	  [WIDTH-1 : 0]DATA_OUT					// Output data, WIDTH-bits wide.
);
	wire 		  [WIDTH-1 : 0]DATA		;				// Wire for transferring data from positive edge triggered buffer to negative edge triggered buffer.

BUFFER_IP #(												// Input Buffer:
	.WIDTH 		(WIDTH		)
	)
	B_IP(
	.CLOCK		(CLOCK		),							// Synchronous clock.
	.RESET		(RESET		),
	.DATA_IN		(DATA_IN		),
	.DATA_OUT	(DATA			)							// Output triggered at rising edge of CLOCK, input to BUFFER_OP.
);

BUFFER_OP #(												// Output Buffer:
	.WIDTH 		(WIDTH		)
	)
	B_OP(
	.CLOCK		(CLOCK		),							// Synchronous clock.
	.RESET		(RESET		),
	.DATA_IN		(DATA			),							// Output from BUFFER_IP.
	.DATA_OUT	(DATA_OUT	)							// Output triggered at falling edge of CLOCK.
);

endmodule
