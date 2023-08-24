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

//reg 	[4:0]W_MSB		= 5'd31;
//reg 	[4:0]R_MSB		= 5'd31;

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
//	.rdempty	(RD_EMP_memToStb				),  //(replace ~read done later),(if fifo is empty i.e. no more data to read from memory), (try)
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

////////////////////////////////////////////////////////////// // RESET:
	if(SYS_RESET)	begin														// If the RESET button is pressed.
	
		STATE <= PASSTHROUGH;												// If the current state is PASSTHROUGH.
		
//		W_MSB	<= 5'd31;														// MSBs for Reading and Writing data are set to 31.
//		R_MSB	<= 5'd31;														// Used for testing algorithms.
		
		WR_REQ_stbToMem	<=	1'b0;											// Don't write to stbToMem FIFO.
		RD_REQ_stbToMem	<=	1'b0;											// Don't read from stbToMem FIFO.
		
		writeRequest     	<= 1'b0;											// Don't write to DDR Memory.
      writeAddress     	<= 24'h000000;									// Set write address to 0, only on reset, not when write done, to prevent accidental overwriting.
      writeData        	<= 32'h00000000;								// Set write data to 0.
      writeByteEn      	<= 4'hF;											// Write to all bytes of memory (can be set to 0 here, try).
      writeDone        	<= 1'b0;											// De-assert writeDone.
		
		readRequest      	<= 1'b0;											// Don't read from DDR Memory.
		readAddress      	<= 24'h000000;									// Set read address to 0, also when all the addresses are read from, to allow repeated playback.
		
		WR_REQ_memToStb	<= 1'b0;											// Don't write to memToStb FIFO.
		RD_REQ_memToStb	<= 1'b0;											// Don't read from memToStb FIFO.
		
	end
	else	begin
	
		case(STATE)																// Whenever the value of STATE changes.
		
////////////////////////////////////////////////////////////// // PASSTHROUGH state:		
			PASSTHROUGH:	begin
				
				if(PLAY || REC)	begin										// If PLAY or REC buttons are pressed, change STATE.
				
					if(REC	)	begin											// If REC button is pressed:
						
						STATE <= RECORD;										// Change STATE to RECORD.
						
						WR_REQ_stbToMem	<= 1'b1;							// Start writing to stbToMem FIFO.
						RD_REQ_stbToMem	<= 1'b1;							// Start reading from stbToMem FIFO.
						
						writeRequest		<= 1'b1;							// Start writing to DDR memory.
					end
					
					if(PLAY	)	begin											// If PLAY button is pressed:
					
						STATE <= REPLAY;										// Change STATE to REPLAY.
						
						RD_REQ_memToStb	<= 1'b1;							// Start reading from memToStb FIFO.
						
						readRequest			<= 1'b1;							// Start reading from DDR memory.
					end
					
				end
				else	STATE <= PASSTHROUGH;								// else, remain in PASSTHROUGH state.
				
				TEMP_VALID	<= B_VALID	;									// BUFFER_COMB receives data form BUFFER_IP.
				TEMP_SYNC	<= B_SYNC	;									// i.e. data from STB (demodulator) is sent back to STB (processor) for playback.
				TEMP_DATA	<= B_DATA	;									// STB (demodulator) --> BUFFER_IP --> BUFFER_COMB --> STB (processor).
			end
			
////////////////////////////////////////////////////////////// // RECORD state:			
			RECORD:	begin
			
				//STATE <= (PASS	)? PASSTHROUGH : RECORD;			// For testing.
				
				writeByteEn  <= 4'hF;										// Write to all bytes of memory.
				
				if(writeDone) begin											// If all the addresses were written to: 
					
					STATE <= PASSTHROUGH;									// change STATE to PASSTHROUGH.
				end
				else if(writeWait) begin									// If a write has been accepted by the memory, i.e. data is currently being written:
				
					writeRequest <= 1'b0;									// Don't write to DDR Memory.
					
					RD_REQ_stbToMem<= 1'b0;									// Don't read from stbToMem FIFO, otherwise data will be lost.
					
					STATE <= REC_WAIT;										// change STATE to REC_WAIT, wait for data to be written.
				end
				else if(!RD_EMP_stbToMem) begin							// If data is present in stbToMem FIFO:
				
				 if(writeRequest && !writeWait && !writeDone) begin// and, writeWait is 0, i.e. no data is being currently written to the memory
						
						writeAddress	<= writeAddress + 24'h1	;		// Increment Write Address.
						
						writeData	   <= {OUT_stbToMem, 22'd0};		// Write 10-bits of data to 10 MSBs of current Write Address. BUFFER_IP --> stbToMem FIFO --> DDR Memory.
						
						writeDone		<=	(writeAddress==24'hFFFFFF);// If value of writeAddress reaches the last available address, writeDone = 1;
					end
				end
				else STATE <= RECORD;										// else, remain in RECORD state.
				
				TEMP_VALID	<= B_VALID	;									// BUFFER_COMB receives data form BUFFER_IP.
				TEMP_SYNC	<= B_SYNC	;									// i.e. data from STB (demodulator) is sent back to STB (processor) for playback.
				TEMP_DATA	<= B_DATA	;									// Live video playback does not stop in this state.
			end
			
			
			REC_WAIT:	begin
				
				if(!writeWait && !RD_EMP_stbToMem)	begin				// if writeWait is 0, i.e. data has been written to the memory:
					
					RD_REQ_stbToMem<= 1'b1;									// Start reading from stbToMem FIFO.

					writeRequest 	<= 1'b1;									// Start writing to DDR memory.
					
					STATE <= RECORD;											// Change STATE to RECORD.
				end
				
				else	STATE <= REC_WAIT	;									// else, remain in REC_WAIT state, i.e. wait for data to be written to the memory.	
				
				TEMP_VALID	<= B_VALID	;									// BUFFER_COMB receives data form BUFFER_IP.
				TEMP_SYNC	<= B_SYNC	;									// i.e. data from STB (demodulator) is sent back to STB (processor) for playback.
				TEMP_DATA	<= B_DATA	;									// Live video playback does not stop in this state.
				
			end

////////////////////////////////////////////////////////////// // REPLAY state:				
			REPLAY:	begin
			
				STATE <= (PASS	)? PASSTHROUGH : REPLAY;				// Playback from DDR memory can be stopped by pressing the PASS button, this is not available in the RECORD state.
				
				if(!readWait)	begin											// If data is currently being read from the memory:
				  
					readRequest			<= 1'b0;								// Don't read from DDR Memory.
					
					WR_REQ_memToStb	<= 1'b1;								// Don't write to memToStb FIFO, otherwise data will be lost.
					
					STATE <= REP_WAIT;										// change STATE to REP_WAIT, wait for data to be read.
				end

				TEMP_VALID	<= OUT_memToStb[9];							// BUFFER_COMB receives data form DDR Memory.
				TEMP_SYNC	<= OUT_memToStb[8];							// i.e. data from DDR Memory is sent to STB (processor) for playback.
				TEMP_DATA	<= OUT_memToStb[7 : 0];						// DDR Memory --> memToStb FIFO --> BUFFER_COMB --> STB.
			end
			
			
			REP_WAIT:	begin
				
				if (readValid) begin											// if valid data has been read from the memory:
				  
					//DATA_OUT		<= readData[31 : 22];
					
					IN_memToStb	<= readData[31 : 22];					// 10 MSBs from the current readaddress of the memory are sent to the memToStb FIFO.
						
					readAddress	<= readAddress + 24'h1;					// Increment Read Address.
					
					WR_REQ_memToStb	<= 1'b0;								// Stop writing data to the memToStb FIFO (for next cycle).
				end
				
				if(!WR_FUL_memToStb)	begin									// if the memToStb FIFO is not full, i.e. data can still be written to it:
					
					readRequest <= 1'b1;										// Read data from DDR Memory.
						
					STATE <= REPLAY;											// change STATE to REPLAY.
				end
				else STATE <= REP_WAIT;										// else, remain in REP_WAIT state.
				
				if (readAddress == 24'hFFFFFF)	begin					// if all addresses have been read from:
				  
					readAddress <= 24'd0;									// Set readAddress to 0, allows user to read the data again. 
					
					STATE <= PASSTHROUGH;									// Change STATE to PASSTHROUGH.
				end
				
				DATA_OUT		<=	OUT_memToStb;								// Data displayed on LEDs is output of memToStb FIFO.
			
				TEMP_VALID	<= OUT_memToStb[9];							// BUFFER_COMB receives data form DDR Memory.
				TEMP_SYNC	<= OUT_memToStb[8];							// i.e. data from DDR Memory is sent to STB (processor) for playback.
				TEMP_DATA	<= OUT_memToStb[7 : 0];						// DDR Memory --> memToStb FIFO --> BUFFER_COMB --> STB.
			end
			
			default:	STATE	<=	PASSTHROUGH;								// Default state is PASSTHROUGH.
		endcase
	end
end



//External interface signals.

assign LED 							= DATA_OUT					;

assign TS_CLOCK_OUT				= TS_CLOCK_IN				;

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
