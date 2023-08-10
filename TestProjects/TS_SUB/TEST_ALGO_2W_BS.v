module TEST_ALGO_2W_BS(
	
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

localparam	LOAD	= 2'd0	;
localparam	SELECT= 2'd1	;
localparam	SHIFT	= 2'd2	;

localparam	IDLE	= 2'd0	;
localparam	WRITE	= 2'd1	;
localparam	READ	= 2'd2	;

reg	[31:0]	TEMP;

reg	[31:0]	DATA[0:20]	;

reg	[31:0]	writeData	;
reg	[31:0]	readData		;

reg	[4 :0]	writeAddress;
reg	[4 :0]	readAddress	;


always	@(posedge CLOCK or posedge RESET)	begin
	
	if(RESET)	begin
		
		readAddress	<= 5 'd0	;
		writeAddress<= 5 'd0	;
		
		READ_BITS_LEFT		<= 6 'd32;
		WRITE_BITS_LEFT	<= 6 'd32;
		
		W_FLAG			<= SELECT;
		R_FLAG			<= LOAD	;
		
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
				
				if(W_FLAG == SELECT)	begin
					
					DATA[writeAddress][9:0]	<=	DATA_IN;
					
					W_FLAG			<= SHIFT;
					STATE				<= WRITE;
				end
				
				if(W_FLAG == SHIFT)	begin
					
					DATA[writeAddress]	<=	DATA[writeAddress] << 10;
					WRITE_BITS_LEFT		<=	WRITE_BITS_LEFT - 6'd10	;
					
					W_FLAG			<= SELECT;
					STATE				<= IDLE	;
				end
				
				if(WRITE_BITS_LEFT <= 6'd20)	begin
				
					writeAddress		<=	writeAddress + 4'd1;
					WRITE_BITS_LEFT	<=	6 'd32;
				end
			end
			
			READ:	begin
			
				if(R_FLAG == LOAD)	begin
					
					TEMP		<=	DATA[readAddress];
					
					R_FLAG			<= SELECT;
					STATE				<= READ	;
				end
				
				if(R_FLAG == SELECT)	begin
					
					DATA_OUT	<=	DATA[readAddress][29:20];
					DATA_OUT	<=	TEMP[29:20];
					
					R_FLAG			<= SHIFT	;
					STATE				<= READ	;
				end
				
				if(R_FLAG == SHIFT)	begin
					
					DATA[readAddress]	<=	DATA[readAddress] << 10	;
					
					TEMP					<=	TEMP	<<	10;
					READ_BITS_LEFT		<=	READ_BITS_LEFT - 6'd10	;
					
					R_FLAG			<= SELECT;
					STATE				<= IDLE	;
				end
			
				if(READ_BITS_LEFT <= 6'd20)	begin
				
					readAddress		<=	readAddress + 4'd1;
					READ_BITS_LEFT	<=	6 'd32;
					
					R_FLAG			<= LOAD	;
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
				
				STATE		<= IDLE;
			end
		endcase
	end
end
endmodule
