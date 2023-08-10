module TEST_ALGO_NW(
	
	input				CLOCK		,
	input				RESET		,
	
	input				WRITE_IN	,
	input				READ_IN	,
	
	input			[9 :0]DATA_IN,
	
	output reg	[1 :0]STATE	,
	
	output reg	[31:0]DATA_0	,
	output reg	[31:0]DATA_1	,
	output reg	[31:0]DATA_2	,
	output reg	[31:0]DATA_3	,
	output reg	[31:0]DATA_4	,
	output reg	[31:0]DATA_5	,
	output reg	[31:0]DATA_6	,
	output reg	[31:0]DATA_7	,
	output reg	[31:0]DATA_8	,
	output reg	[31:0]DATA_9	,
	output reg	[31:0]DATA_10	,
	
	output reg	[9 :0]DATA_OUT
);

localparam AVAILABLE	= 2'd0;
localparam NO_SPACE	= 2'd1;
localparam PARTIAL	= 2'd2;

localparam MSB		= 7'd32	;

localparam IDLE	= 2'd0	;
localparam WRITE	= 2'd1	;
localparam READ	= 2'd2	;

reg	[31:0]	DATA[0:20]	;

reg	[10:0]	TEMP			;
reg	[6 :0]	TEMP_INDEX	;

reg	[4 :0]	writeAddress;
reg	[4 :0]	readAddress	;

reg	[6 :0]	WRITE_LSB	;
reg	[6 :0]	READ_LSB		;

reg	[1 :0]	WRITE_FLAG	;
reg	[1 :0]	READ_FLAG	;

always	@(posedge CLOCK or posedge RESET)	begin
	
	if(RESET)	begin
		
		readAddress	<= 5'd0;
		writeAddress<= 5'd0;
		
		READ_LSB		<= 6'd0;
		WRITE_LSB	<= 6'd0;
		
		READ_FLAG	<= 2'd0;
		WRITE_FLAG	<= 2'd0;
		
		STATE			<= IDLE;
	end
	else	begin
		case(STATE)
			
			IDLE:	begin
				
				if(WRITE_IN || READ_IN)	begin
					
					if(WRITE_IN)	begin
					
						STATE	<= WRITE	;
					end
					
					if(READ_IN)	begin
						
						STATE	<= READ	;
					end
				end
				
				else	STATE	<= IDLE	;
			end
		/*	
			WRITE:	begin
				
				if(WRITE_FLAG == AVAILABLE)	begin
					
					DATA[writeAddress][WRITE_LSB +: 10]		<=	DATA_IN;
					WRITE_LSB	<= WRITE_LSB + 6 'd10;
					
					if(WRITE_LSB >= 6'd20)	begin
						
						WRITE_FLAG	<= NO_SPACE	;
						
						TEMP			<=	DATA_IN	;
					end
				end
				
				if(WRITE_FLAG == NO_SPACE)	begin
					
					DATA[writeAddress][WRITE_LSB +: MSB - WRITE_LSB]		<=	TEMP[0 +: MSB - WRITE_LSB];
					
					TEMP_INDEX		<=	MSB - WRITE_LSB		;
					
					writeAddress	<=	writeAddress + 4'd1	;
					
					WRITE_LSB		<=	10-(MSB - WRITE_LSB)	;
					
					WRITE_FLAG		<= PARTIAL					;
				end
				
				if(WRITE_FLAG == PARTIAL)	begin
					
					DATA[writeAddress][WRITE_LSB - 1 +: WRITE_LSB]		<=	TEMP[TEMP_INDEX +: 6 'd10 - TEMP_INDEX];
					
					WRITE_FLAG		<= AVAILABLE				;
				end
				
				STATE	<= IDLE	;
			end
			
			
			*/
			READ:	begin
				
				DATA_OUT		<=	DATA[readAddress][READ_LSB -: 10];
				
				READ_LSB		<= READ_LSB - 5 'd10;

				if(READ_LSB < 5'd20)	begin
				
					readAddress	<=	readAddress + 4'd1;
					READ_LSB		<=	5 'd31;
				end
				
				DATA_0	<=	DATA[0 ];
				DATA_1	<=	DATA[1 ];
				DATA_2	<=	DATA[2 ];
				DATA_3	<=	DATA[3 ];
				DATA_4	<=	DATA[4 ];
				DATA_5	<=	DATA[5 ];
				DATA_6	<=	DATA[6 ];
				DATA_7	<=	DATA[7 ];
				DATA_8	<=	DATA[8 ];
				DATA_9	<=	DATA[9 ];
				DATA_10	<=	DATA[10];
				
				STATE		<= IDLE	;
			end
		endcase
	end
end
endmodule
