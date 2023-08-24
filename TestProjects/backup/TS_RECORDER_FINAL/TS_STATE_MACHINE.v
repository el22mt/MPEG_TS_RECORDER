module TS_STATE_MACHINE(
	
	input 		SYS_CLOCK	,												// 50 MHz clock signal for the State machine and DDR memory.
	input 		SYS_RESET	,												// Reset signal synchronised to 50 MHz SYS_CLOCK.

	input 		TS_CLOCK_IN	,												// 6 MHz clock signal input and output buffers.
	input 		TS_RESET		,												// Reset signal synchronised to 6 MHz TS_CLOCK_IN.
	
	input 		PASS			,												// Input to State Machine for transitioning to PASSTHROUGH State.
	input 		PLAY			,												// Input to State Machine for transitioning to PLAY State.
	input 		REC			,												// Input to State Machine for transitioning to RECORD State.
	
	input	 [9:0]SWITCH		,												// SWITCH input for testing the memory.
	output [9:0]LED			,												// LED output for displaying test data from the memory.
	
	input			TS_VALID_IN	,												// TS VALID input from STB.
	input			TS_SYNC_IN	,												// TS SYNC input from STB.
	input	 [7:0]TS_DATA_IN	,												// TS DATA input (8-bit) from STB.
	
	output		TS_VALID_OUT,												// TS VALID output to STB.
	output		TS_SYNC_OUT	,												// TS SYNC output to STB.
	output [7:0]TS_DATA_OUT	,												// TS DATA output (8-bit) to STB.
	
	output 		TS_CLOCK_OUT,												// 6 MHz TS CLOCK output to STB.
	
	output reg [2:0] STATE	,												// Register for storing the current state of the state machine.

// DDR Write Interface

	output        ddr_write_clock,										//Clock for DDR3 Write Logic. Can be connected to "clock"
	input         ddr_write_reset,										//Reset for DDR3 Write Logic. If "ddr_read_clock" is connected to "clock", use "reset" for DDR write logic instead of this wire.
	output [23:0] ddr_write_address,										//64MB Chunk of DDR3. Word Address (unit of address is 32bit).  
	input         ddr_write_waitrequest,								//When wait request is high, write is ignored.
	output        ddr_write_write,										//Assert write for one cycle for each word of data to be written
	output [31:0] ddr_write_writedata,									//Write data should be valid when write is high.
	output [ 3:0] ddr_write_byteenable,									//Byte enable should be valid when write is high.

// DDR Read Interface

	output        ddr_read_clock,											//Clock for DDR3 Read Logic. Can be connected to "clock"
	input         ddr_read_reset,											//Reset for DDR3 Read Logic. If "ddr_read_clock" is connected to "clock", use "reset" for DDR read logic instead of this wire.
	output [23:0] ddr_read_address,										//64MB Chunk of DDR3. Word Address (unit of address is 32bit).
	input         ddr_read_waitrequest,									//When wait request is high, read is ignored.
	output        ddr_read_read,											//Assert read for one cycle for each word of data to be read.
	input         ddr_read_readdatavalid,								//Read Data Valid will be high for each word of data read, but latency varies from read.
	input  [31:0] ddr_read_readdata										//Read Data should only be used if read data valid is high.
);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Connections for DDR3 Memory:

// DDR Read Interface:

assign ddr_write_clock = SYS_CLOCK;										//	Write Clock connected to 50 MHz Clock signal.

wire        writeWait;
reg         writeRequest;
reg  [23:0] writeAddress;
reg  [31:0] writeData;
reg  [ 3:0] writeByteEn;

reg         writeDone;														// All addresses written when high.

// DDR Write Interface:

assign ddr_read_clock = SYS_CLOCK;										//	Read Clock connected to 50 MHz Clock signal.

wire 			readValid;
reg         readRequest;
reg  [23:0] readAddress;
wire [31:0] readData;
wire        readWait;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// For testing Algorithms:

//reg [31:0]COUNTER;

//genvar W_COUNT;
//genvar R_COUNT;

reg 	[4:0]W_MSB		= 5'd31;
reg 	[4:0]R_MSB		= 5'd31;

reg  	[9:0]	DATA_OUT	;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Instantiation of Input Buffer:

wire			B_VALID	;														// TS VALID Signal triggered at rising edge of TS_CLOCK_IN.
wire			B_SYNC	;														// TS SYNC Signal triggered at rising edge of TS_CLOCK_IN.
wire	[7:0]	B_DATA	;														// TS DATA Lines triggered at rising edge of TS_CLOCK_IN.

BUFFER_IP #(																	// Positive edge triggered Input Buffer.
	.WIDTH		(10)															// 10 - bits wide.
	)
	TS_BUFFER_IP(
	.CLOCK		(TS_CLOCK_IN										),		// 6 MHz TS CLOCK Input.
	.RESET		(TS_RESET											),		// Reset signal synchronised to TS_CLOCK_IN.
	.DATA_IN		({TS_VALID_IN, TS_SYNC_IN, TS_DATA_IN}		),		// Inputs form STB Triggered at falling edge of TS_CLOCK_IN.
	.DATA_OUT	({B_VALID, B_SYNC, B_DATA}						)		// Output signals Triggered at rising edge of TS_CLOCK_IN.
);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Instantiation of Asynchronous FIFO for transferring Data from STB to DDR Memory (6 MHz to 50 MHz):

reg 			RD_REQ_stbToMem	;											// READ REQUEST: Read data form FIFO when 1.
wire 			RD_EMP_stbToMem	;											// READ EMPTY: 1 when FIFO is empty, no data to be read (underflow).

reg 			WR_REQ_stbToMem	;											// WRITE REQUEST: Write data to FIFO when 1.
wire 			WR_FUL_stbToMem	;											// WRITE FULL: 1 when FIFO is full, no space for more data (overflow).

wire [9 :0]	OUT_stbToMem		;											// Output of FIFO Clocked at 50 MHz.

FIFO_ASYNC stbToMem (

	.aclr		(TS_RESET						),
	.data		({B_VALID, B_SYNC, B_DATA}	),								// Data from Input Buffer triggered at rising edge of TS_CLOCK_IN.
	.rdclk	(SYS_CLOCK						),								// 50 MHz SYS_CLOCK reading data from FIFO.
	.rdreq	(RD_REQ_stbToMem				),
	.wrclk	(TS_CLOCK_IN					),								// 6 MHz TS_CLOCK_IN writing data to FIFO.
	.wrreq	(WR_REQ_stbToMem				),
	.q			(OUT_stbToMem					),
	.rdempty	(RD_EMP_stbToMem				)
//	.wrfull	(WR_FUL_stbToMem				)
);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Instantiation of Asynchronous FIFO for transferring Data from DDR Memory to STB (50 MHz to 6 MHz):

reg [9 :0]	IN_memToStb			;											// Input to FIFO Clocked at 50 MHz.

reg 			RD_REQ_memToStb	;											// READ REQUEST: Read data form FIFO when 1.
wire 			RD_EMP_memToStb	;											// READ EMPTY: 1 when FIFO is empty, no data to be read (underflow).

reg 			WR_REQ_memToStb	;											// WRITE REQUEST: Write data to FIFO when 1.
wire 			WR_FUL_memToStb	;											// WRITE FULL: 1 when FIFO is full, no space for more data (overflow).

wire [9 :0]	OUT_memToStb		;											// Output of FIFO Clocked at 6 MHz.

FIFO_ASYNC memToStb (

	.aclr		(SYS_RESET						),
	.data		(IN_memToStb					),
	.rdclk	(TS_CLOCK_IN					),								// 6 MHz TS_CLOCK_IN reading data from FIFO.
	.rdreq	(RD_REQ_memToStb				),
	.wrclk	(SYS_CLOCK						),								// 50 MHz SYS_CLOCK writing data to FIFO.
	.wrreq	(WR_REQ_memToStb				),
	.q			(OUT_memToStb					),
//	.rdempty	(RD_EMP_memToStb				),  //replace ~read done later
	.wrfull	(WR_FUL_memToStb				)
);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Instantiation of Output Buffer:

reg			TEMP_VALID	;													// TS VALID Signal triggered at falling edge of TS_CLOCK_IN.
reg			TEMP_SYNC	;													// TS SYNC Signal triggered at falling edge of TS_CLOCK_IN.
reg	[7:0]	TEMP_DATA	;													// TS DATA Signal triggered at falling edge of TS_CLOCK_IN.

BUFFER_COMB #(
	.WIDTH		(10)															// 10 - bits wide.
	)
	TS_BUFFER_OP(
	.CLOCK		(TS_CLOCK_IN										),		// 6 MHz TS CLOCK Input.
	.RESET		(TS_RESET											),		// Reset signal synchronised to TS_CLOCK_IN.
	.DATA_IN		({TEMP_VALID, TEMP_SYNC, TEMP_DATA}			),		// Inputs Triggered at rising edge of TS_CLOCK_IN.
	.DATA_OUT	({TS_VALID_OUT, TS_SYNC_OUT, TS_DATA_OUT}	)		// Outputs Triggered at falling edge of TS_CLOCK_IN.
);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Logic for TS_STATE_MACHINE, Writing and Reading from DDR memory.

localparam PASSTHROUGH	= 3'd0;
localparam RECORD			= 3'd1;
localparam REPLAY			= 3'd2;
localparam REC_WAIT		= 3'd3;
localparam REP_WAIT		= 3'd4;

always @(posedge SYS_CLOCK or posedge SYS_RESET)	begin

	if(SYS_RESET)	begin
	
		STATE <= PASSTHROUGH;
		
		W_MSB	<= 5'd31;
		R_MSB	<= 5'd31;
		
		WR_REQ_stbToMem	<=	1'b0;
		RD_REQ_stbToMem	<=	1'b0;
		
		writeRequest     	<= 1'b0;
      writeAddress     	<= 24'h000000;
      writeData        	<= 32'h00000000;
      writeByteEn      	<= 4'hF;
      writeDone        	<= 1'b0;
		
		WR_REQ_memToStb	<= 1'b0;
		RD_REQ_memToStb	<= 1'b0;
		  
		readRequest      	<= 1'b0;
		readAddress      	<= 24'h000000;
	end
	else	begin
	
		case(STATE)
		
			PASSTHROUGH:	begin
				
				if(PLAY || REC)	begin
				
					if(REC	)	begin
						
						STATE <= RECORD;
						
						WR_REQ_stbToMem	<= 1'b1;
						RD_REQ_stbToMem	<= 1'b1;
						
						writeRequest		<= 1'b1;
					end
					
					if(PLAY	)	begin
					
						STATE <= REPLAY;
						
						RD_REQ_memToStb	<= 1'b1;
						
						readRequest			<= 1'b1;
					end
					
				end
				else	begin
				
					STATE <= PASSTHROUGH;
				end
				
				TEMP_VALID	<= B_VALID	;
				TEMP_SYNC	<= B_SYNC	;
				TEMP_DATA	<= B_DATA	;
			end
			
			RECORD:	begin
			
				//STATE <= (PASS	)? PASSTHROUGH : RECORD;
				
				TEMP_VALID	<= B_VALID	;
				TEMP_SYNC	<= B_SYNC	;
				TEMP_DATA	<= B_DATA	;
				
				writeByteEn  <= 4'hF;
				
				if(writeDone) begin
					
					STATE <= PASSTHROUGH;
				end
				else if(writeWait) begin
				
					writeRequest <= 1'b0;
					
					RD_REQ_stbToMem<= 1'b0;
					
					STATE <= REC_WAIT;
				end
				else if(!RD_EMP_stbToMem) begin
				
					if (writeRequest && !writeWait && !writeDone) begin
						
						writeAddress	<= writeAddress + 24'h1	;
						
						writeData	   <= {OUT_stbToMem, 22'd0};
						
						writeDone		<=	(writeAddress == 24'hFFFFFF);
					end
				end
				else STATE <= RECORD;
			end
			
			REC_WAIT:	begin
			
				TEMP_VALID	<= B_VALID	;
				TEMP_SYNC	<= B_SYNC	;
				TEMP_DATA	<= B_DATA	;
				
				if(!writeWait && !RD_EMP_stbToMem)	begin
					
					RD_REQ_stbToMem<= 1'b1;

					writeRequest 	<= 1'b1;
					
					STATE <= RECORD;
				end
				
				else	STATE <= REC_WAIT;	
			end
		
			
			REPLAY:	begin
			
				STATE <= (PASS	)? PASSTHROUGH : REPLAY;
				
				if(!readWait)	begin
				  
					readRequest			<= 1'b0;
					
					WR_REQ_memToStb	<= 1'b1;
					
					STATE <= REP_WAIT;
				end

				TEMP_VALID	<= OUT_memToStb[9];
				TEMP_SYNC	<= OUT_memToStb[8];
				TEMP_DATA	<= OUT_memToStb[7 : 0];	
			end
			
			REP_WAIT:	begin
				
				if (readValid) begin
				  
					//DATA_OUT		<= readData[31 : 22];
					
					IN_memToStb	<= readData[31 : 22];
						
					readAddress	<= readAddress + 24'h1;
					
					WR_REQ_memToStb	<= 1'b0;
				end
				
				if(!WR_FUL_memToStb)	begin
					
					readRequest <= 1'b1;
						
					STATE <= REPLAY;
				end
				else STATE <= REP_WAIT;
				
				if (readAddress == 24'hFFFFFF)	begin
				  
					readAddress <= 24'd0;
					
					STATE <= PASSTHROUGH;
				end
				
				DATA_OUT		<=	OUT_memToStb;
			
				TEMP_VALID	<= OUT_memToStb[9];
				TEMP_SYNC	<= OUT_memToStb[8];
				TEMP_DATA	<= OUT_memToStb[7 : 0];
			end
			
			default:	STATE	<=	PASSTHROUGH;
		endcase
	end
end



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
