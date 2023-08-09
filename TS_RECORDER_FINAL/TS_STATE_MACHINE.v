module TS_STATE_MACHINE(
	
	input SYS_CLOCK			,
	input SYS_RESET			,

	input TS_CLOCK_IN			,
	input TS_RESET				,
	
	input PASS					,
	input PLAY					,
	input REC					,
	
	input	 [9:0]SWITCH		,
	output [9:0]LED			,
	
	input			TS_VALID_IN	,
	input			TS_SYNC_IN	,
	input	 [7:0]TS_DATA_IN	,
	
	output		TS_VALID_OUT,
	output		TS_SYNC_OUT	,
	output [7:0]TS_DATA_OUT	,
	
	output 		TS_CLOCK_OUT,
	
	output reg [1:0] STATE	,
	
//
// DDR Write Interface
//
	output        ddr_write_clock,        //Clock for DDR3 Write Logic. Can be connected to "clock"
	input         ddr_write_reset,        //Reset for DDR3 Write Logic. If "ddr_read_clock" is connected to "clock", use "reset" for DDR write logic instead of this wire.
	output [23:0] ddr_write_address,      //64MB Chunk of DDR3. Word Address (unit of address is 32bit).  
	input         ddr_write_waitrequest,  //When wait request is high, write is ignored.
	output        ddr_write_write,        //Assert write for one cycle for each word of data to be written
	output [31:0] ddr_write_writedata,    //Write data should be valid when write is high.
	output [ 3:0] ddr_write_byteenable,   //Byte enable should be valid when write is high.
	
//
// DDR Read Interface
//
	output        ddr_read_clock,         //Clock for DDR3 Read Logic. Can be connected to "clock"
	input         ddr_read_reset,         //Reset for DDR3 Read Logic. If "ddr_read_clock" is connected to "clock", use "reset" for DDR read logic instead of this wire.
	output [23:0] ddr_read_address,       //64MB Chunk of DDR3. Word Address (unit of address is 32bit).
	input         ddr_read_waitrequest,   //When wait request is high, read is ignored.
	output        ddr_read_read,          //Assert read for one cycle for each word of data to be read.
	input         ddr_read_readdatavalid, //Read Data Valid will be high for each word of data read, but latency varies from read.
	input  [31:0] ddr_read_readdata       //Read Data should only be used if read data valid is high.
	

);

////////////////////////////////////	WRITE:
assign ddr_write_clock = SYS_CLOCK;

wire        writeWait;
reg         writeRequest;
reg  [23:0] writeAddress;
reg  [31:0] writeData;
reg  [ 3:0] writeByteEn;

//reg         writeDone; //All addresses written when high.

////////////////////////////////////	READ:
assign ddr_read_clock = SYS_CLOCK;
//
wire 			readValid;
reg         readRequest;
reg  [23:0] readAddress;
wire [31:0] readData;
wire        readWait;

reg [4:0]W_MSB		= 5'd0;
reg [4:0]R_MSB		= 5'd0;

reg  [9:0]	DATA_OUT;

wire			B_VALID	;
wire			B_SYNC	;
wire	[7:0]	B_DATA	;

BUFFER_IP #(
	.WIDTH		(10)
	)
	TS_BUFFER_IP(
	.CLOCK		(TS_CLOCK_IN										),
	.RESET		(TS_RESET											),
	.DATA_IN		({TS_VALID_IN, TS_SYNC_IN, TS_DATA_IN}		),
	.DATA_OUT	({B_VALID, B_SYNC, B_DATA}						)
);

reg			TEMP_VALID	;
reg			TEMP_SYNC	;
reg	[7:0]	TEMP_DATA	;

localparam PASSTHROUGH	= 2'b00;
localparam RECORD			= 2'b01;
localparam REPLAY			= 2'b10;

always @(posedge SYS_CLOCK or posedge SYS_RESET)	begin

	if(SYS_RESET)	begin
	
		STATE <= PASSTHROUGH;
		
		W_MSB	<= 5'd31;
		R_MSB	<= 5'd31;
		
		writeRequest     <= 1'b0;
      writeAddress     <= 24'h000000;
      writeData        <= 32'h00000000;
      writeByteEn      <= 4'hF;
      //writeDone        <= 1'b0;
		  
		readRequest      <= 1'b0;
		readAddress      <= 24'h000000;
	end
	else	begin
	
		case(STATE)
		
			PASSTHROUGH:	begin
				
				if(PLAY || REC)	begin
				
					if(REC	)	begin
						
						STATE <= RECORD;
						
						writeRequest	<= 1'b1;
					end
					
					if(PLAY	)	begin
					
						STATE <= REPLAY;
						
						readRequest		<= 1'b1;
					end
					
				end
				else	begin
				
					STATE <= PASSTHROUGH;
				end
				
				TEMP_VALID	= B_VALID	;
				TEMP_SYNC	= B_SYNC		;
				TEMP_DATA	= B_DATA		;
			end
			
			RECORD:	begin
			
				//STATE <= (PASS	)? PASSTHROUGH : RECORD;
				
				TEMP_VALID	= B_VALID	;
				TEMP_SYNC	= B_SYNC		;
				TEMP_DATA	= B_DATA		;
				
				writeByteEn  <= 4'hF;
				writeRequest <= 1'b0;
				  
				if (writeRequest && !writeWait) begin
						
					writeData[W_MSB -: 10]    <= SWITCH ;
					
					writeAddress	<= writeAddress + 24'h1;
				end
				  
				if (!writeWait)	begin
				  
					STATE <= PASSTHROUGH;
				end
			end
			
			REPLAY:	begin
			
				//STATE <= (PASS	)? PASSTHROUGH : REPLAY;
				
				
				if(!readWait)	begin
				  
					readRequest <= 1'b0;
				end
				  
				if (readValid) begin
				  
					DATA_OUT    <= readData[R_MSB -: 10];
						
					readAddress	<= readAddress + 24'h1;
						
					STATE <= PASSTHROUGH;
				end
				  
			end
		endcase
	end
end

BUFFER_COMB #(
	.WIDTH		(10)
	)
	TS_BUFFER_OP(
	.CLOCK		(TS_CLOCK_IN										),
	.RESET		(TS_RESET											),
	.DATA_IN		({TEMP_VALID, TEMP_SYNC, TEMP_DATA}			),
	.DATA_OUT	({TS_VALID_OUT, TS_SYNC_OUT, TS_DATA_OUT}	)
);

//External interface signals.

assign LED = DATA_OUT;

assign TS_CLOCK_OUT	= TS_CLOCK_IN	;

assign writeWait					= ddr_write_waitrequest	;
assign ddr_write_address 		= writeAddress				;
assign ddr_write_writedata		= writeData					;	
assign ddr_write_byteenable 	= writeByteEn				;
assign ddr_write_write 			= writeRequest				;

assign readWait 					= ddr_read_waitrequest	;
assign ddr_read_address 		= readAddress				;
assign readData		 			= ddr_read_readdata		;
assign ddr_read_read	 			= readRequest				;	
assign readValid 					= ddr_read_readdatavalid;

endmodule
