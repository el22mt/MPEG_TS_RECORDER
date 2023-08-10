`timescale 1 ns/100 ps

module FIFO_DC_i1o1_4b_TB;

reg R_CLOCK;
reg W_CLOCK;

reg RESET;

reg	DATA_IN;
wire	DATA_OUT;

reg READ_REQ;
reg WRITE_REQ;

wire R_EMPTY;
wire W_FULL;

FIFO_DC_i1o1_4b DUT(
	.aclr		(RESET		),	//	reset
	.data		(DATA_IN		),	//	1-bit test data IN
	.rdclk	(R_CLOCK		),	//	R_CLOCK
	.rdreq	(READ_REQ	),	//	data becomes available after readreq is asserted
	.wrclk	(W_CLOCK		),	//	W_CLOCK
	.wrreq	(WRITE_REQ	),	//	
	.q			(DATA_OUT	),	//	1-bit test data OUT
	.rdempty	(R_EMPTY		),	// read empty
	.wrfull	(W_FULL		)	//	write full
);
	
initial	begin

		R_CLOCK = 1'b0;
		W_CLOCK = 1'b0;
		
		READ_REQ		= 1'b0;
		WRITE_REQ	= 1'b0;
		RESET = 1'b1;
		
#40	READ_REQ		= 1'b1;
		WRITE_REQ	= 1'b1;
		RESET = 1'b0;

#1000	$stop;
end

always	begin

#10	W_CLOCK <= ~W_CLOCK;
end

always	begin

#20	R_CLOCK <= ~R_CLOCK;
end

initial	begin

		DATA_IN = 1'b1;
#44	DATA_IN = 1'b1;
#19	DATA_IN = 1'b1;
#19	DATA_IN = 1'b1;

#19	DATA_IN = 1'b1;
#19	DATA_IN = 1'b0;
#19	DATA_IN = 1'b1;
#19	DATA_IN = 1'b0;

#19	DATA_IN = 1'b0;
#19	DATA_IN = 1'b1;
#19	DATA_IN = 1'b0;
#19	DATA_IN = 1'b1;

#19	DATA_IN = 1'b0;
#19	DATA_IN = 1'b0;
#19	DATA_IN = 1'b0;
#19	DATA_IN = 1'b0;
		
end

endmodule
