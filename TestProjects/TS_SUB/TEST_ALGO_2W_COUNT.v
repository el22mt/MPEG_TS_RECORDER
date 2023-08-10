module TEST_ALGO_2W_COUNT(
	
	input				CLOCK		,
	input				RESET		,
	
	input				WRITE_IN	,
	input				READ_IN	,
	
	input			[9 :0]DATA_IN,
	
	output reg	[1 :0]STATE	,
	
	output reg	[5 :0]WRITE_BITS_LEFT,
	output reg	[5 :0]READ_BITS_LEFT,
	
	output reg	[1 :0]W_FLAG	,
	output reg	[1 :0]R_FLAG	,
	
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

localparam IDLE	= 2'd0	;
localparam WRITE	= 2'd1	;
localparam READ	= 2'd2	;

reg	[31:0]	DATA[0:20]	;

reg	[31:0]	writeData	;
reg	[31:0]	readData		;

reg	[4 :0]	writeAddress;
reg	[4 :0]	readAddress	;

reg	[5 :0]	WRITE_LSB	;
reg	[5 :0]	READ_LSB		;

reg	[1 :0]	WRITE_COUNT	;
reg	[1 :0]	READ_COUNT	;

always	@(posedge CLOCK or posedge RESET)	begin
	
	if(RESET)	begin
		
		readAddress	<= 5 'd0	;
		writeAddress<= 5 'd0	;
		
		READ_LSB		<= 5 'd0;
		WRITE_LSB	<= 5 'd0;
		
		WRITE_COUNT	<= 2 'd0	;
		READ_COUNT	<= 2 'd0	;
		
		STATE			<= IDLE	;
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
			
			WRITE:	begin
				
				DATA[writeAddress][WRITE_LSB +: 10]		<=	DATA_IN;
				
				WRITE_LSB	<= WRITE_LSB + 5 'd10;
				WRITE_COUNT	<=	WRITE_COUNT + 2'd1;
				
				
				if(WRITE_COUNT > 2'd2)	begin
				//if(WRITE_LSB >= 5'd20)	begin
				
					writeAddress	<=	writeAddress + 4'd1;
					WRITE_LSB		<=	5 'd0;
				 WRITE_COUNT		<=	2 'd0;
				end
				
				STATE	<= IDLE	;
			end
			
			READ:	begin
				
				DATA_OUT		<=	DATA[readAddress][READ_LSB +: 10];
				
				READ_LSB		<= READ_LSB + 5 'd10;
			 READ_COUNT	<=	READ_COUNT + 2'd1;
				
				if(WRITE_COUNT > 2'd2)	begin
			//	if(READ_LSB >= 5'd20)	begin
				
					readAddress	<=	readAddress + 4'd1;
					READ_LSB		<=	5 'd0;
					READ_COUNT	<=	2 'd0;
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
