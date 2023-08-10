`timescale 1 ns/100 ps

module TS_STATE_MACHINE_TB;

	reg CLOCK	;
	reg RESET	;
	
	reg PASS	;
	reg PLAY	;
	reg REC	;
	
	wire [1:0]	STATE	;
//	wire			OUT	;
	
TS_STATE_MACHINE DUT(
	
	.CLOCK	(CLOCK	),
	.RESET	(RESET	),
	
	.PASS		(PASS		),
	.PLAY		(PLAY		),
	.REC		(REC		),
	
	.STATE	(STATE	)
//	.OUT		(OUT		)
);

initial	begin
		CLOCK = 1'b0;
	
		RESET = 1'b1;
	
		PASS	= 1'b0;
		PLAY	= 1'b0;
		REC	= 1'b0;
	
#20	RESET	= 1'b0;	
end

always	#5 CLOCK <= ~CLOCK;

initial	begin

#30	REC	= 1'b1;
#10	REC	= 1'b0;
#10	PASS	= 1'b1;
#10	PASS	= 1'b0;

#10	PLAY	= 1'b1;
#10	PLAY	= 1'b0;
#10	PASS	= 1'b1;
#10	PASS	= 1'b0;

#10	PLAY	= 1'b1;
#10	PLAY	= 1'b0;
#10	REC	= 1'b1;
#10	REC	= 1'b0;
#10	PASS	= 1'b1;
#10	PASS	= 1'b0;

#10	REC	= 1'b1;
#10	REC	= 1'b0;
#10	PLAY	= 1'b1;
#10	PLAY	= 1'b0;
#10	PASS	= 1'b1;
#10	PASS	= 1'b0;
		
#50	$stop;
end
endmodule
