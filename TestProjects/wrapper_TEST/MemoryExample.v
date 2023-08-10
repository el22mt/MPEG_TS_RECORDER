module MemoryExample (

    //
    // Application Clock
    //
    input        clock,                  //Main application clock signal
    
    //
    // Application Reset
    //
    input        reset,                  //Application Reset from LT24 - Use For All Logic Clocked with "clock"

	 input		  WRITE	,
	 input		  READ	,
	 input	[9:0]SWITCH ,
	 output	[9:0]LED		,

    //
    // DDR Read Interface
    //
    output        ddr_read_clock,         //Clock for DDR3 Read Logic. Can be connected to "clock"
    input         ddr_read_reset,         //Reset for DDR3 Read Logic. If "ddr_read_clock" is connected to "clock", use "reset" for DDR read logic instead of this wire.
    output [23:0] ddr_read_address,       //64MB Chunk of DDR3. Word Address (unit of address is 32bit).
    input         ddr_read_waitrequest,   //When wait request is high, read is ignored.
    output        ddr_read_read,          //Assert read for one cycle for each word of data to be read.
    input         ddr_read_readdatavalid, //Read Data Valid will be high for each word of data read, but latency varies from read.
    input  [31:0] ddr_read_readdata,      //Read Data should only be used if read data valid is high.

    //
    // DDR Write Interface
    //
    output        ddr_write_clock,        //Clock for DDR3 Write Logic. Can be connected to "clock"
    input         ddr_write_reset,        //Reset for DDR3 Write Logic. If "ddr_read_clock" is connected to "clock", use "reset" for DDR write logic instead of this wire.
    output [23:0] ddr_write_address,      //64MB Chunk of DDR3. Word Address (unit of address is 32bit).  
    input         ddr_write_waitrequest,  //When wait request is high, write is ignored.
    output        ddr_write_write,        //Assert write for one cycle for each word of data to be written
    output [31:0] ddr_write_writedata,    //Write data should be valid when write is high.
    output [ 3:0] ddr_write_byteenable    //Byte enable should be valid when write is high.    
);

reg	[5 :0]WRITE_BITS_LEFT;
reg	[5 :0]READ_BITS_LEFT;
	
reg	[1 :0]W_FLAG	;
reg	[1 :0]R_FLAG	;

localparam	LOAD	= 2'd0	;
localparam	SELECT= 2'd1	;
localparam	SHIFT	= 2'd2	;

reg	[31:0]	TEMP;

localparam IDLE_STATE	= 2'd0;
localparam WRITE_STATE	= 2'd1;
localparam READ_STATE	= 2'd2;

reg [1:0] CURRENT_STATE;

reg [4:0]W_MSB		= 5'd0;
reg [4:0]R_MSB		= 5'd0;

reg [1:0]r_count	= 2'd0;
reg [1:0]w_count	= 2'd0;

////////////////////////////////////	WRITE:
assign ddr_write_clock = clock;

wire        writeWait;
reg         writeRequest;
reg  [23:0] writeAddress;
reg  [31:0] writeData;
reg  [ 3:0] writeByteEn;

//reg         writeDone; //All addresses written when high.

////////////////////////////////////	READ:
assign ddr_read_clock = clock;
//
wire 			readValid;
reg         readRequest;
reg  [23:0] readAddress;
wire [31:0] readData;
wire        readWait;

reg  [9:0]	DATA_OUT;

always @ (posedge clock or posedge reset) begin //use "reset" for DDR write logic as single clock domain. If using multiple clocks, should use ddr_write_reset instead.
    if (reset) begin
        writeRequest     <= 1'b0;
        writeAddress     <= 24'h000000;
        writeData        <= 32'h00000000;
        writeByteEn      <= 4'hF;
        //writeDone        <= 1'b0;
		  
		  readRequest      <= 1'b0;
		  readAddress      <= 24'h000000;
		  
		  W_MSB	<= 5'd31;
		  R_MSB	<= 5'd31;
		  
		  //r_count <= 2'd0;
		  //w_count <= 2'd0;
		  
		  CURRENT_STATE 	 <= IDLE_STATE;
    end
	 else	begin
		case(CURRENT_STATE)
			
			IDLE_STATE:	begin
			
			if(WRITE || READ)	begin
			
				if(WRITE)	begin
				
					writeRequest	<= 1'b1;
					CURRENT_STATE	<= WRITE_STATE	;
				end
				
				if(READ)	begin
				
					readRequest		<= 1'b1;
					CURRENT_STATE	<= READ_STATE	;
				end
			end
			
			else	CURRENT_STATE	<= IDLE_STATE	;
			end
			
			WRITE_STATE:begin
			
				  writeByteEn  <= 4'hF;
				  writeRequest <= 1'b0;
				  
				  if (writeRequest && !writeWait) begin
						
						writeData[W_MSB -: 10]    <= SWITCH ;
						
						W_MSB	<= W_MSB - 5'd10;
				  end
				  
				  if (W_MSB == 5'd21)	begin
				  
						writeAddress	<= writeAddress + 24'h1;
						W_MSB				<= 5'd31;
				  end
				  
				  if (!writeWait)	begin
				  
						CURRENT_STATE <= IDLE_STATE;
				  end
				  
			end
			
			READ_STATE:	begin
			
				  if(!readWait)	begin
				  
						readRequest <= 1'b0;
				  end
				  
				  if (readValid) begin
				  
						DATA_OUT    <= readData[R_MSB -: 10];
						
						R_MSB	<= R_MSB - 5'd10;
						
						CURRENT_STATE <= IDLE_STATE;
				  end
				  
				  if (R_MSB == 5'd21)	begin
				  
						readAddress		<= readAddress + 24'h1;
						R_MSB				<= 5'd31;
				  end
			end
			
		endcase
	 end
end
	 
//External interface signals.
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

assign LED = DATA_OUT;

endmodule

//always @ (posedge clock or posedge reset) begin //use "reset" for DDR write logic as single clock domain. If using multiple clocks, should use ddr_write_reset instead.
//    if (reset) begin
//        writeRequest     <= 1'b0;
//        writeAddress     <= 24'h000000;
//        writeData        <= 32'h00000000;
//        writeByteEn      <= 4'hF;
//        //writeDone        <= 1'b0;
//		  
//		  readRequest      <= 1'b0;
//		  readAddress      <= 24'h000000;
//		  
//		  r_lsb	<= 5'd0;
//		  w_lsb	<= 5'd0;
//		  
//		  //r_count <= 2'd0;
//		  //w_count <= 2'd0;
//		  
//		  CURRENT_STATE 	 <= IDLE_STATE;
//    end
//	 else	begin
//		case(CURRENT_STATE)
//			
//			IDLE_STATE:	begin
//			
//			if(WRITE || READ)	begin
//			
//				if(WRITE)	begin
//				
//					writeRequest	<= 1'b1;
//					CURRENT_STATE	<= WRITE_STATE	;
//				end
//				
//				if(READ)	begin
//				
//					readRequest		<= 1'b1;
//					CURRENT_STATE	<= READ_STATE	;
//				end
//			end
//			
//			else	CURRENT_STATE	<= IDLE_STATE	;
//			end
//			
//			WRITE_STATE:begin
//			
//				  writeByteEn  <= 4'hF;
//				  writeRequest <= 1'b0;
//				  
//				  if (writeRequest && !writeWait) begin
//						
//						writeData[w_lsb +: 10]    <= SWITCH;
//						w_lsb	<= w_lsb + 5'd10;
//						//w_count <= w_count + 2'd1;
//						
//						if(w_lsb >= 5'd20)	begin
//						
//							writeAddress <= writeAddress + 24'h1;
//							w_lsb	<= 5'd0;
//							//w_count <= 2'd0;
//						end
//				  end
//				  
//				  if (!writeWait)	begin
//				  
//						CURRENT_STATE <= IDLE_STATE;
//				  end
//				  
//			end
//			
//			READ_STATE:	begin
//			
//				  if(!readWait)	begin
//				  
//						readRequest <= 1'b0;
//				  end
//				  
//				  if (readValid) begin
//				  
//						DATA_OUT    <= readData[r_lsb +: 10];
//						r_lsb	<= r_lsb + 5'd10;
//						//r_count <= r_count + 2'd1;
//				  
//						if(r_lsb >= 5'd20)	begin
//							
//							readAddress <= readAddress + 24'h1;
//							r_lsb	<= 5'd0;
//							//r_count <= 2'd0;
//						end
//						
//						CURRENT_STATE <= IDLE_STATE;
//				  end
//			end
//			
//		endcase
//	 end
//end
