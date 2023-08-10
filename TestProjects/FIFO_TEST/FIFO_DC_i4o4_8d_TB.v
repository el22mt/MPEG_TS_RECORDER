`timescale 1 ns/100 ps

module FIFO_DC_i4o4_8d_TB;

reg R_CLOCK;
reg W_CLOCK;

reg RESET;

reg	[3:0]DATA_IN;
wire	[3:0]DATA_OUT;

reg READ_REQ;
reg WRITE_REQ;

wire R_EMPTY;
wire W_FULL;

FIFO_DC_i4o4_8d DUT(
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
		
#40	RESET = 1'b0;
end

always	begin

#10	W_CLOCK <= ~W_CLOCK;
end

always	begin

#20	R_CLOCK <= ~R_CLOCK;
end

initial	begin

		DATA_IN		= 4'd3;
		
#100	WRITE_REQ	= 1'b1;

#200	READ_REQ		= 1'b1;
		WRITE_REQ	= 1'b0;
		
#200	RESET			= 1'b1;
		READ_REQ		= 1'b0;
		
#50	RESET			= 1'b0;
		
#10	DATA_IN		= 4'd7;

#50	WRITE_REQ	= 1'b1;

#20	DATA_IN		= 4'd6;
#20	DATA_IN		= 4'd5;
#20	DATA_IN		= 4'd4;
#20	DATA_IN		= 4'd3;
#20	DATA_IN		= 4'd2;
#20	DATA_IN		= 4'd1;
#20	DATA_IN		= 4'd0;

#10	WRITE_REQ	= 1'b0;
#50	READ_REQ		= 1'b1;

#500	$stop;
end

endmodule
