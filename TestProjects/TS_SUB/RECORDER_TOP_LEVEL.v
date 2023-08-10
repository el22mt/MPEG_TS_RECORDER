module RECORDER_TOP_LEVEL(
	input 		TS_CLOCK_IN	,
	
	input 		CLOCK	,
	input 		RESET	,
	
	input 		PASS	,
	input 		PLAY	,
	input 		REC	,
	
	input			TS_VALID_IN	,
	input			TS_SYNC_IN	,
	input	 [7:0]TS_DATA_IN	,
	
	output		TS_VALID_OUT,
	output		TS_SYNC_OUT	,
	output [7:0]TS_DATA_OUT	,
	
	output 		TS_CLOCK_OUT,
	
	output [6:0]HEX4	,
	output [6:0]HEX5	
);

wire		 S_RESET	;

ResetSynchroniser RS0(
    .clock		(CLOCK	),
    .resetIn	(RESET	),
    
    .resetOut	(S_RESET	)
);


wire		 R_PASS	;
wire		 R_PLAY	;
wire		 R_REC	;

BUTTON_REL_DET BRD0(
  .CLOCK		(CLOCK						),
  .RESET		(S_RESET						),
  .BUTTONS	({PASS,	 PLAY,	REC  }),
  .RELEASE	({R_PASS, R_PLAY, R_REC})
);

wire		 S_PASS	;
wire		 S_PLAY	;
wire		 S_REC	;

NBitSynchroniser #(
    .WIDTH(3)
	 )
	 SYNC0(
	 .clock		(CLOCK						),
    .asyncIn	({R_PASS, R_PLAY, R_REC}),
    .syncOut	({S_PASS, S_PLAY, S_REC})
);

wire [1:0]STATE	;

assign TS_CLOCK_OUT	= TS_CLOCK_IN	;
assign TS_VALID_OUT	= TS_VALID_IN	;
assign TS_SYNC_OUT	= TS_SYNC_IN	;
assign TS_DATA_OUT	= TS_DATA_IN	;


//TS_STATE_MACHINE SM0(
//	
//	.TS_CLOCK_IN(TS_CLOCK_IN),
//	
//	.CLOCK(CLOCK	),
//	.RESET(S_RESET	),
//	
//	.PASS	(S_PASS	),
//	.PLAY	(S_PLAY	),
//	.REC	(S_REC	),
//	
//	.TS_VALID_IN(TS_VALID_IN),
//	.TS_SYNC_IN	(TS_SYNC_IN	),
//	.TS_DATA_IN	(TS_DATA_IN	),
//	
//	.TS_VALID_OUT(TS_VALID_OUT),
//	.TS_SYNC_OUT (TS_SYNC_OUT ),
//	.TS_DATA_OUT (TS_DATA_OUT ),
//	
//	.TS_CLOCK_OUT(TS_CLOCK_OUT),
//	
//	.STATE(STATE	)
//);

DECODER_7SEGMENT D0(
  .IN		(4'd5	),
  .DISP	(HEX5	)
);

DECODER_7SEGMENT D1(
  .IN		(STATE),
  .DISP	(HEX4	)
);

endmodule
