`timescale 1 ns/100 ps

module TEST_ALGO_TB;
	
reg	CLOCK		;
reg	RESET		;
	
reg	WRITE_IN	;
reg	READ_IN	;
	
reg	[9:0]DATA_IN	;

wire	[1:0]STATE		;

wire	[5 :0]	WRITE_BITS_LEFT;
wire	[5 :0]	READ_BITS_LEFT	;

wire	[1 :0]	WRITE_FLAG		;
wire	[1 :0]	READ_FLAG		;

wire	[31:0]DATA_0	;
wire	[31:0]DATA_1	;
wire	[31:0]DATA_2	;
wire	[31:0]DATA_3	;
wire	[31:0]DATA_4	;
wire	[31:0]DATA_5	;
wire	[31:0]DATA_6	;
wire	[31:0]DATA_7	;
wire	[31:0]DATA_8	;
wire	[31:0]DATA_9	;
wire	[31:0]DATA_10	;

wire	[9:0]DATA_OUT	;

TEST_ALGO_2W DUT(
	
	.CLOCK	(CLOCK	),
	.RESET	(RESET	),
	
	.WRITE_IN(WRITE_IN),
	.READ_IN	(READ_IN	),
	
	.DATA_IN	(DATA_IN	),
	
//	.WRITE_BITS_LEFT(WRITE_BITS_LEFT	),
//	.READ_BITS_LEFT (READ_BITS_LEFT	),
	
//	.W_FLAG	(WRITE_FLAG	),
//	.R_FLAG	(READ_FLAG	),
	
	.STATE	(STATE	),
	
	.DATA_0	(DATA_0	),
	.DATA_1	(DATA_1	),
	.DATA_2	(DATA_2	),
	.DATA_3	(DATA_3	),
	.DATA_4	(DATA_4	),
	.DATA_5	(DATA_5	),
	.DATA_6	(DATA_6	),
	.DATA_7	(DATA_7	),
	.DATA_8	(DATA_8	),
	.DATA_9	(DATA_9	),
	.DATA_10	(DATA_10	),
	
	.DATA_OUT(DATA_OUT)
);

initial	begin
		CLOCK		<= 1 'b0;
		RESET		<= 1 'b1;
		
		WRITE_IN	<= 1 'b0;
		READ_IN	<= 1 'b0;
		
		DATA_IN	<=	10'd0;
		
#40	RESET		<=	1 'b0;
end

always	#5	CLOCK <= ~CLOCK;

integer i = 0;

initial	begin

#93	DATA_IN	=	10'b1000000000;

	for (i = 0; i <= 10; i = i+1)	begin
		
		#10	WRITE_IN	=	1'b1;
		#10	WRITE_IN	=	1'b0;
		
		#10	DATA_IN = DATA_IN >> 1;
		
		#10	READ_IN	=	1'b1;
		#10	READ_IN	=	1'b0;
	end

//	for (i = 0; i <= 10; i = i+1)	begin
//		
//		#10	WRITE_IN	=	1'b1;
//		#10	WRITE_IN	=	1'b0;
//		
//		#10	DATA_IN = DATA_IN << 1;
//		
//		//#10	READ_IN	=	1'b1;
//		//#10	READ_IN	=	1'b0;
//	end
//
//#40
//	
//	for (i = 0; i <= 22; i = i+1)	begin
//		
//		#10	READ_IN	=	1'b1;
//		#10	READ_IN	=	1'b0;
//	end

#100	$stop;
end
endmodule
