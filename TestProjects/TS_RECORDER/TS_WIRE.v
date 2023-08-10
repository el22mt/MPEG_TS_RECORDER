module TS_WIRE(
	
	input					SYS_CLOCK		,
	
	input					RESET_IN			,
	
	input					PASS_IN			,
	input					RECORD_IN		,
	input					PLAY_IN			,
	
	input					TS_CLOCK_IN		,
	
	input					TS_VALID_IN		,
	input					TS_SYNC_IN		,
	input			[7 :0]TS_DATA_IN		,
	
	output				TS_CLOCK_OUT	,
	
	output				TS_VALID_OUT	,
	output				TS_SYNC_OUT		,
	output		[7 :0]TS_DATA_OUT		,
	
	output reg	[6 :0]HEX_0				,
	output reg	[6 :0]HEX_1				,
	output reg	[6 :0]HEX_2				,
	output reg	[6 :0]HEX_3				,
	output 		[6 :0]HEX_4				,
	output 		[6 :0]HEX_5					
);

	wire				SYS_RESET		;
	
ResetSynchroniser SYS_SYNC_R(

    .clock		(SYS_CLOCK		),
    .resetIn	(RESET_IN		),
    
    .resetOut	(SYS_RESET		)
);

	wire				TS_RESET			;
	
ResetSynchroniser TS_SYNC_R(

    .clock		(TS_CLOCK_IN	),
    .resetIn	(RESET_IN		),
    
    .resetOut	(TS_RESET		)
);

	wire				S_PASS			;
	wire				S_RECORD			;
	wire				S_PLAY			;
	
NBitSynchroniser #(

	.WIDTH(3)  // Number of bits wide
	)
	SYS_SYNC_IP(
	
		.clock	(SYS_CLOCK								),
		.asyncIn	({PASS_IN, RECORD_IN, PLAY_IN}	),
		.syncOut	({S_PASS, S_RECORD, S_PLAY}		)
);

	wire				PASS				;
	wire				RECORD			;
	wire				PLAY				;

BUTTON_REL_DET DET_IN(
  .CLOCK		(SYS_CLOCK							)	,          					// Input clock signal
  .RESET		(SYS_RESET							)	,          					// Input reset signal
  .BUTTONS	({S_PASS, S_RECORD, S_PLAY}	)	,        					// Input representing the current state of buttons
  .RELEASE	({PASS, RECORD, PLAY}			)          						// Output register representing the button release signals
);

TS_STATE_MACHINE SM(
	
	.SYS_CLOCK		(SYS_CLOCK		),
	.SYS_RESET		(SYS_RESET		),

	.TS_CLOCK_IN	(TS_CLOCK_IN	),
	.TS_RESET		(TS_RESET		),
	
	.PASS				(PASS				),
	.PLAY				(PLAY				),
	.REC				(RECORD			),
	
	.TS_VALID_IN	(TS_VALID_IN	),
	.TS_SYNC_IN		(TS_SYNC_IN		),
	.TS_DATA_IN		(TS_DATA_IN		),
	
	.TS_VALID_OUT	(TS_VALID_OUT	),
	.TS_SYNC_OUT	(TS_SYNC_OUT	),
	.TS_DATA_OUT	(TS_DATA_OUT	),
	
	.TS_CLOCK_OUT	(TS_CLOCK_OUT	),
	
	.STATE			(STATE			)
);

wire	[1:0]STATE;

//localparam Passthrough	= 2'b00;
//localparam Record			= 2'b01;
//localparam Replay			= 2'b10;
//
//localparam off	= 7'h7F;
//localparam dash= 7'h3F;
//
//localparam S 	= 7'h12;
//
//localparam P	= 7'h0C;
//localparam L	= 7'h47;
//localparam A	= 7'h08;
//localparam Y	= 7'h11;
//
//localparam r	= 7'h2F;
//localparam E	= 7'h06;
//localparam C	= 7'h46;
//
//assign	HEX_5 = S	;
//assign	HEX_4 = dash;
//
//always @(STATE)	begin
//	
//	case(STATE)
//		
//		Passthrough	:	begin
//		
//			HEX_3 <= P;
//			HEX_2 <= A;
//			HEX_1 <= S;
//			HEX_0 <= S;
//		end
//		
//		Record		:	begin
//			
//			HEX_3 <= r;
//			HEX_2 <= E;
//			HEX_1 <= C;
//			HEX_0 <= off;
//		end
//		
//		Replay		:	begin
//			
//			HEX_3 <= P;
//			HEX_2 <= L;
//			HEX_1 <= A;
//			HEX_0 <= Y;
//		end
//	endcase
//end

//BUFFER_COMB TS_BUFFER(
//	.CLOCK		(TS_CLOCK_IN										),
//	.RESET		(TS_RESET											),
//	.DATA_IN		({TS_VALID_IN, TS_SYNC_IN, TS_DATA_IN}		),
//	.DATA_OUT	({TS_VALID_OUT, TS_SYNC_OUT, TS_DATA_OUT}	)
//);

//assign	TS_CLOCK_OUT	= TS_CLOCK_IN	;

endmodule
