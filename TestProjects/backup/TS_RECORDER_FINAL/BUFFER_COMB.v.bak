module BUFFER_COMB #(
	parameter WIDTH = 10
	)(
	input							CLOCK		,
	input							RESET		,
	input		  [WIDTH-1 : 0]DATA_IN	,
	output 	  [WIDTH-1 : 0]DATA_OUT
);
	wire 		  [WIDTH-1 : 0]W			;

BUFFER_IP #(
	.WIDTH 		(WIDTH		)
	)
	B_IP(
	.CLOCK		(CLOCK		),
	.RESET		(RESET		),
	.DATA_IN		(DATA_IN		),
	.DATA_OUT	(W				)
);

BUFFER_OP #(
	.WIDTH 		(WIDTH		)
	)
	B_OP(
	.CLOCK		(CLOCK		),
	.RESET		(RESET		),
	.DATA_IN		(W				),
	.DATA_OUT	(DATA_OUT	)
);

endmodule
