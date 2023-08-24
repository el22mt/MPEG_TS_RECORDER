/*
 * Mini-Project Example Top-Level Module
 * -------------------------------------
 *
 * This is an example top-level module which you can use for your mini-projects
 * to add functionality for using the HPSWrapper core. This wrapper provides
 * access to the DDR3 memory and the the USB-UART connection.
 *
 * There are a series of `define statements which are used to select which bits
 * of the functionality of the HPS Wrapper you want included.
 *
 * USE_HPS_WRAPPER
 * ---------------
 * If uncommented: Design will make use the the full HPSWrapper core. (default)
 * If commented:   Just the LT24 controller will be instantiated.
 *
 * USE_DDR3_MEMORY
 * ---------------
 * If 1: You can use 64MB of DDR3 memory in your design. (default)
 * If 0: There is no access to this memory.
 *
 * USE_SDMMC_SAVE_INTERFACE
 * ------------------------
 * If 1: An interface to allow DDR3 to be saved to SD Card (default)
 * If 0: No such interface.
 *
 * USE_UART_INTERFACE
 * ------------------
 * If 1: You can use the USB-UART connector (mini-USB). (default)
 * If 0: You cannot access these pins.
 *
 */

//Comment this line out if HPSWrapper not required
`define USE_HPS_WRAPPER
//-------------------------------------------

//Change this from 1 to 0 if DDR3 not required
`define USE_DDR3_MEMORY 1
//-------------------------------------------

//Change this from 1 to 0 if Save not required
`define USE_SDMMC_SAVE_INTERFACE 0
//-------------------------------------------

//Change this from 1 to 0 if UART not required
`define USE_UART_INTERFACE 0
//-------------------------------------------

module ExampleTopLevel (
/*
 *    --------->>>>   DO NOT CHANGE BETWEEN HERE
 */
`ifdef USE_HPS_WRAPPER
    //If we are using the HPS wrapper, and we are not simulating,
    //add the HPS top-level pins.
    //You do NOT need to connect these pins in your test-bench designs!!
    inout         hps_io_hps_io_sdio_inst_CMD     , // hps_io.hps_io_sdio_inst_CMD
    inout         hps_io_hps_io_sdio_inst_D0      , //       .hps_io_sdio_inst_D0
    inout         hps_io_hps_io_sdio_inst_D1      , //       .hps_io_sdio_inst_D1
    output        hps_io_hps_io_sdio_inst_CLK     , //       .hps_io_sdio_inst_CLK
    inout         hps_io_hps_io_sdio_inst_D2      , //       .hps_io_sdio_inst_D2
    inout         hps_io_hps_io_sdio_inst_D3      , //       .hps_io_sdio_inst_D3
    inout         hps_io_hps_io_i2c0_inst_SDA     , //       .hps_io_i2c0_inst_SDA
    inout         hps_io_hps_io_i2c0_inst_SCL     , //       .hps_io_i2c0_inst_SCL
    inout         hps_io_hps_io_gpio_inst_GPIO48  , //       .hps_io_gpio_inst_GPIO48
    inout         hps_io_hps_io_gpio_inst_GPIO53  , //       .hps_io_gpio_inst_GPIO53
    inout         hps_io_hps_io_gpio_inst_GPIO54  , //       .hps_io_gpio_inst_GPIO54
    inout         hps_io_hps_io_gpio_inst_LOANIO49, //       .hps_io_gpio_inst_LOANIO49
    inout         hps_io_hps_io_gpio_inst_LOANIO50, //       .hps_io_gpio_inst_LOANIO50
    output [14:0] memory_mem_a                    , // memory.mem_a
    output [ 2:0] memory_mem_ba                   , //       .mem_ba
    output        memory_mem_ck                   , //       .mem_ck
    output        memory_mem_ck_n                 , //       .mem_ck_n
    output        memory_mem_cke                  , //       .mem_cke
    output        memory_mem_cs_n                 , //       .mem_cs_n
    output        memory_mem_ras_n                , //       .mem_ras_n
    output        memory_mem_cas_n                , //       .mem_cas_n
    output        memory_mem_we_n                 , //       .mem_we_n
    output        memory_mem_reset_n              , //       .mem_reset_n
    inout  [31:0] memory_mem_dq                   , //       .mem_dq
    inout  [ 3:0] memory_mem_dqs                  , //       .mem_dqs
    inout  [ 3:0] memory_mem_dqs_n                , //       .mem_dqs_n
    output        memory_mem_odt                  , //       .mem_odt
    output [ 3:0] memory_mem_dm                   , //       .mem_dm
    input         memory_oct_rzqin                , //       .oct_rzqin
`endif
/*
 *   <<<<<--------- AND HERE
 */
 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Input and Output ports for Transport Stream Recorder:

	input					clock				,					 // 50 MHz clock input for the system.
	
	input					RESET_IN			,					 // Reset input for the system.
	
	input					PASS_IN			,					 // PASS button input.
	input					RECORD_IN		,					 // RECORD button input.
	input					PLAY_IN			,					 // PLAY button input.
	
	input					TS_CLOCK_IN		,					 // 6 MHz TS CLOCK input from STB.
	
	input					TS_VALID_IN		,					 // TS VALID input from STB.
	input					TS_SYNC_IN		,					 // TS SYNC input from STB.
	input			[7 :0]TS_DATA_IN		,					 // TS DATA input (8-bit) from STB.
	
	input			[9 :0]SWITCH			,					 // SWITCH input for testing the memory.
	output		[9 :0]LED				,					 // LED output for displaying test data from the memory.
	
	output				TS_CLOCK_OUT	,					 // 6 MHz TS CLOCK output to STB.
	
	output				TS_VALID_OUT	,					 // TS VALID output to STB.
	output				TS_SYNC_OUT		,					 // TS SYNC output to STB.
	output		[7 :0]TS_DATA_OUT		,					 // TS DATA output (8-bit) to STB.
	
	output reg	[6 :0]HEX_0				,					 // 7 - Segment Display HEX 0 (displays multiple values).
	output reg	[6 :0]HEX_1				,					 // 7 - Segment Display HEX 1 (displays multiple values).
	output reg	[6 :0]HEX_2				,					 // 7 - Segment Display HEX 2 (displays multiple values).
	output reg	[6 :0]HEX_3				,					 // 7 - Segment Display HEX 3 (displays multiple values).
	output 		[6 :0]HEX_4				,					 // 7 - Segment Display HEX 4 (displays single value ).
	output 		[6 :0]HEX_5									 // 7 - Segment Display HEX 5 (displays single value ).

);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Instantiation of Reset Synchronisers:

	wire				SYS_RESET		;						 // Synchronised reset for blocks using 50 MHz Clock signal (clock).
	
ResetSynchroniser_HW SYS_SYNC_R(							 // Reset Synchroniser for 'clock'. 

    .clock		(clock			),							 // 50 MHz Clock input.
    .resetIn	(RESET_IN		),							 // RESET button.
    
    .resetOut	(SYS_RESET		)							 // Reset signal synchronised to 'clock'.
);

	wire				TS_RESET			;						 // Synchronised reset for blocks using 6 MHz Clock signal (TS_CLOCK).
	
ResetSynchroniser_HW TS_SYNC_R(							 // Reset Synchroniser for 'TS_CLOCK'. 

    .clock		(TS_CLOCK_IN	),							 // 6 MHz Clock input.
    .resetIn	(RESET_IN		),							 // RESET button.
    
    .resetOut	(TS_RESET		)							 // Reset signal synchronised to 'TS_CLOCK'.
);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Instantiation of Input Synchroniser:

	wire				S_PASS			;						 // Synchronised output for PASS button.
	wire				S_RECORD			;						 // Synchronised output for RECORD button.
	wire				S_PLAY			;						 // Synchronised output for PLAY button.
	
NBitSynchroniser #(

	.WIDTH(3)  													 // 3 - bits wide, for three input signals.
	)
	SYS_SYNC_IP(
	
		.clock	(clock									),	 // 50 MHz Clock input.
		.asyncIn	({PASS_IN, RECORD_IN, PLAY_IN}	),	 // Asynchronous input signals (buttons). 
		.syncOut	({S_PASS, S_RECORD, S_PLAY}		)	 // Synchronous output signals.
);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Instantiation of Button Release Detector:

	wire				PASS				;						 // PASS input for TS_STATE_MACHINE.
	wire				RECORD			;						 // RECORD input for TS_STATE_MACHINE.
	wire				PLAY				;						 // PLAY input for TS_STATE_MACHINE.

BUTTON_REL_DET DET_IN(
  .CLOCK		(clock								)	,		 // 50 MHz Clock input.
  .RESET		(SYS_RESET							)	,      // Reset signal synchronised to 'clock'.
  .BUTTONS	({S_PASS, S_RECORD, S_PLAY}	)	,      // Inputs from push buttons.
  .RELEASE	({PASS, RECORD, PLAY}			)			 // Release detected.
);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Interface for DDR3 Memory:

// DDR Read Interface:

wire        ddr_read_clock;         					 //Clock for DDR3 Read Logic. Can be connected to "clock"
wire        ddr_read_reset;         					 //Reset for DDR3 Read Logic. If "ddr_read_clock" is connected to "clock", use "reset" for DDR read logic instead of this wire.
wire [29:0] ddr_read_address;       					 //64MB Chunk of DDR3. Word Address (unit of address is 32bit).
wire        ddr_read_waitrequest;   					 //When wait request is high, read is ignored.
wire        ddr_read_read;          					 //Assert read for one cycle for each word of data to be read.
wire        ddr_read_readdatavalid; 					 //Read Data Valid will be high for each word of data read, but latency varies from read.
wire [31:0] ddr_read_readdata;      					 //Read Data should only be used if read data valid is high.

// DDR Write Interface:

wire        ddr_write_clock;        					 //Clock for DDR3 Write Logic. Can be connected to "clock"
wire        ddr_write_reset;        					 //Reset for DDR3 Write Logic. If "ddr_read_clock" is connected to "clock", use "reset" for DDR write logic instead of this wire.
wire [29:0] ddr_write_address;      					 //64MB Chunk of DDR3. Word Address (unit of address is 32bit).  
wire        ddr_write_waitrequest;  					 //When wait request is high, write is ignored.
wire        ddr_write_write;        					 //Assert write for one cycle for each word of data to be written
wire [31:0] ddr_write_writedata;    					 //Write data should be valid when write is high.
wire [ 3:0] ddr_write_byteenable;   					 //Byte enable should be valid when write is high.

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Instantiation of State Machine:
 
 TS_STATE_MACHINE SM(
	
	.SYS_CLOCK		(clock			),
	.SYS_RESET		(SYS_RESET		),

	.TS_CLOCK_IN	(TS_CLOCK_IN	),
	.TS_RESET		(TS_RESET		),
	
	.PASS				(PASS				),
	.PLAY				(PLAY				),
	.REC				(RECORD			),
	
	.SWITCH			(SWITCH			),
	.LED				(LED				),
	
	.TS_VALID_IN	(TS_VALID_IN	),
	.TS_SYNC_IN		(TS_SYNC_IN		),
	.TS_DATA_IN		(TS_DATA_IN		),
	
	.TS_VALID_OUT	(TS_VALID_OUT	),
	.TS_SYNC_OUT	(TS_SYNC_OUT	),
	.TS_DATA_OUT	(TS_DATA_OUT	),
	
	.TS_CLOCK_OUT	(TS_CLOCK_OUT	),
	
	.STATE			(STATE			),
// DDR Read Interface
   .ddr_read_clock        (ddr_read_clock),         //Clock for DDR3 Read Logic. Can be connected to "clock"
   .ddr_read_reset        (ddr_read_reset),         //Reset for DDR3 Read Logic. If "ddr_read_clock" is connected to "clock", use "reset" for DDR read logic instead of this wire.
   .ddr_read_address      (ddr_read_address),       //64MB Chunk of DDR3. Word Address (unit of address is 32bit).
   .ddr_read_waitrequest  (ddr_read_waitrequest),   //When wait request is high, read is ignored.
   .ddr_read_read         (ddr_read_read),          //Assert read for one cycle for each word of data to be read.
   .ddr_read_readdatavalid(ddr_read_readdatavalid), //Read Data Valid will be high for each word of data read, but latency varies from read.
   .ddr_read_readdata     (ddr_read_readdata),      //Read Data should only be used if read data valid is high.
// DDR Write Interface
   .ddr_write_clock       (ddr_write_clock),        //Clock for DDR3 Write Logic. Can be connected to "clock"
   .ddr_write_reset       (ddr_write_reset),        //Reset for DDR3 Write Logic. If "ddr_read_clock" is connected to "clock", use "reset" for DDR write logic instead of this wire.
   .ddr_write_address     (ddr_write_address),      //64MB Chunk of DDR3. Word Address (unit of address is 32bit).  
   .ddr_write_waitrequest (ddr_write_waitrequest),  //When wait request is high, write is ignored.
   .ddr_write_write       (ddr_write_write),        //Assert write for one cycle for each word of data to be written
   .ddr_write_writedata   (ddr_write_writedata),    //Write data should be valid when write is high.
   .ddr_write_byteenable  (ddr_write_byteenable)    //Byte enable should be valid when write is high.
);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Logic for displaying Current State of TS_STATE_MACHINE on the 7 - Segment Displays.

wire	[2:0]STATE;												 // Current State output from TS_STATE_MACHINE.

localparam Passthrough	= 3'd0;							 // Values associated with each state in TS_STATE_MACHINE.
localparam Record			= 3'd1;
localparam Replay			= 3'd2;
localparam Rec_Wait		= 3'd3;
localparam Rep_Wait		= 3'd4;

localparam off	= 7'h7F;										 // Hex values for displaying values on the 7 - Segment Displays. 
localparam dash= 7'h3F;

localparam S 	= 7'h12;

localparam P	= 7'h0C;
localparam L	= 7'h47;
localparam A	= 7'h08;
localparam Y	= 7'h11;

localparam r	= 7'h2F;
localparam E	= 7'h06;
localparam C	= 7'h46;

assign	HEX_5 = S	;
assign	HEX_4 = dash;

always @(STATE)	begin										 // Look for change in the current state of TS_STATE_MACHINE.
	
	case(STATE)
		
		Passthrough		:	begin								 // 7 - Segment bank displays PASS.
		
			HEX_3 <= P;
			HEX_2 <= A;
			HEX_1 <= S;
			HEX_0 <= S;
		end
		
		Record			:	begin								 // 7 - Segment bank displays rEC.
			
			HEX_3 <= r;
			HEX_2 <= E;
			HEX_1 <= C;
			HEX_0 <= off;
		end
		
		Rec_Wait			:	begin								 // 7 - Segment bank displays rEC.
			
			HEX_3 <= r;
			HEX_2 <= E;
			HEX_1 <= C;
			HEX_0 <= off;
		end
		
		Replay			:	begin								 // 7 - Segment bank displays PLAY.
			
			HEX_3 <= P;
			HEX_2 <= L;
			HEX_1 <= A;
			HEX_0 <= Y;
		end
		
		Rep_Wait			:	begin								 // 7 - Segment bank displays PLAY.
			
			HEX_3 <= P;
			HEX_2 <= L;
			HEX_1 <= A;
			HEX_0 <= Y;
		end
		
		default			:	begin								 // 7 - Segment bank is off by default.
		
			HEX_3 <= off;
			HEX_2 <= off;
			HEX_1 <= off;
			HEX_0 <= off;
		end
	endcase
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
 *  DO NOT EDIT BELOW THIS LINE
 *
 *  Here we instantiate either the HPSWrapper core, or the LT24 display controller.
 *
 */

`ifndef USE_HPS_WRAPPER
    //If not using HPS Wrapper, Instantiate LT24 Display and Power-on Reset

    //Generate a reset signal at power-on.
    wire globalReset;
    power_on_reset_hw power_on_reset (
        .clock(clock      ),
        .reset(globalReset)
    );

    //Instantiate LT24 Display controller
    LT24Display #(
        .WIDTH      (240),
        .HEIGHT     (320),
        .CLOCK_FREQ (50000000)
    ) lt24_fpga (
        //Clock/Reset Inputs
        .clock        (clock      ),
        .globalReset  (globalReset),
       
        //Application Reset
        .resetApp     (reset),
        
        //Pixel Interface
        .pixelReady   (pixelReady),
        .pixelData    (pixelData ),
        .pixelWrite   (pixelWrite),
        .xAddr        (xAddr     ),
        .yAddr        (yAddr     ),
        
        //Optional Command/Data Interface
        .pixelRawMode (pixelRawMode),
        .cmdReady     (cmdReady    ),
        .cmdData      (cmdData     ),
        .cmdWrite     (cmdWrite    ),
        .cmdDone      (cmdDone     ),
        
        //LT24 Display Interface - DO NOT RENAME
        .LT24CS_n     (LT24CS_n   ),
        .LT24RS       (LT24RS     ),
        .LT24Rd_n     (LT24Rd_n   ),
        .LT24Wr_n     (LT24Wr_n   ),
        .LT24Data     (LT24Data   ),
        .LT24LCDOn    (LT24LCDOn  ),
        .LT24Reset_n  (LT24Reset_n)
    );

`else
    //Otherwise we are using the HPS Wrapper
    HPSWrapperTop #(
        .USE_DDR3_MEMORY         (`USE_DDR3_MEMORY         ), //Whether to enable DDR.   If set to 0, leave ddr_write_* and ddr_read_* ports unconnected.
        .USE_SDMMC_SAVE_INTERFACE(`USE_SDMMC_SAVE_INTERFACE), //Whether to enable SDMMC. If set to 0, leave handshake_* ports unconnected.
        .USE_UART_INTERFACE      (`USE_UART_INTERFACE      )  //Whether to enable UART.  If set to 0, leave uart_* ports unconnected.
    ) hps_system (
        //Main Application Clock/Reset
        .user_clock_clk   ( clock ), //Application logic clock input signal
        .user_reset_reset ( reset ), //Application logic reset output signal
        
        //LT24 Pixel Interface (synchronous to user_clock_clk)
        .lt24_data_ready ( pixelReady ),
        .lt24_data_data  ( pixelData  ),
        .lt24_data_write ( pixelWrite ),
        .lt24_data_xAddr ( xAddr      ),
        .lt24_data_yAddr ( yAddr      ),

        //LT24 Optional Command/Data Interface (synchronous to user_clock_clk)
        .lt24_mode_raw  ( pixelRawMode ),
        .lt24_cmd_ready ( cmdReady     ),
        .lt24_cmd_data  ( cmdData      ),
        .lt24_cmd_write ( cmdWrite     ),
        .lt24_cmd_done  ( cmdDone      ),
        
        //Connect up UART interface (synchronous to user_clock_clk)
        .usb_uart_rx ( uart_rx ), //(Data In to FPGA)
        .usb_uart_tx ( uart_tx ), //(Data Out to USB)
        
        //DDR3 Read Interface
        .ddr_read_clock_clk     ( ddr_read_clock         ), //Clock for DDR Read Interface. Can be same as user_clock_clk
        .ddr_read_reset_reset   ( ddr_read_reset         ), //If ddr_read_clock_clk is same as user_clock_clk, leave unconnected and use user_reset_reset for read logic.
        .ddr_read_address       ( ddr_read_address       ), //Use upper chunk of DDR3 memory, HPS base address 0x30000000
        .ddr_read_waitrequest   ( ddr_read_waitrequest   ), //When wait request is high, read is ignored.
        .ddr_read_read          ( ddr_read_read          ), //Assert read for one cycle for each word of data to be read.
        .ddr_read_readdatavalid ( ddr_read_readdatavalid ), //Read Data Valid will be high for each word of data read, but latency varies from read.
        .ddr_read_readdata      ( ddr_read_readdata      ), //Read Data should only be used if read data valid is high.
        
        //DDR3 Write Interface
        .ddr_write_clock_clk   ( ddr_write_clock       ), //Clock for DDR Write Interface. Can be same as user_clock_clk
        .ddr_write_reset_reset ( ddr_write_reset       ), //If ddr_write_clock_clk is same as user_clock_clk, leave unconnected and use user_reset_reset instead.
        .ddr_write_address     ( ddr_write_address     ),
        .ddr_write_waitrequest ( ddr_write_waitrequest ), //When wait request is high, write is ignored.
        .ddr_write_write       ( ddr_write_write       ), //Assert write for one cycle for each word of data to be written
        .ddr_write_writedata   ( ddr_write_writedata   ), //Write data should be valid when write is high.
        .ddr_write_byteenable  ( ddr_write_byteenable  ), //Byte enable should be valid when write is high.
        
        //Save DDR3 Memory to SDMMC
        .handshake_in_port  ( {save_req, save_req_info} ),
        .handshake_out_port ( {save_ack, save_ack_info} ),

        //
        // External Interfaces - Connect Directly to Input/Output Port List
        //
        
        //External LT24 Connections - DO NOT RENAME
        .lt24_display_cs_n  ( LT24CS_n     ),
        .lt24_display_rs    ( LT24RS       ),
        .lt24_display_rd_n  ( LT24Rd_n     ),
        .lt24_display_wr_n  ( LT24Wr_n     ),
        .lt24_display_data  ( LT24Data     ),
        .lt24_display_on    ( LT24LCDOn    ),
        .lt24_display_rst_n ( LT24Reset_n  ),
        
        //External GPIO Connections for HPS - DO NOT RENAME
        .hps_io_hps_io_sdio_inst_CMD      ( hps_io_hps_io_sdio_inst_CMD      ),
        .hps_io_hps_io_sdio_inst_D0       ( hps_io_hps_io_sdio_inst_D0       ),
        .hps_io_hps_io_sdio_inst_D1       ( hps_io_hps_io_sdio_inst_D1       ),
        .hps_io_hps_io_sdio_inst_CLK      ( hps_io_hps_io_sdio_inst_CLK      ),
        .hps_io_hps_io_sdio_inst_D2       ( hps_io_hps_io_sdio_inst_D2       ),
        .hps_io_hps_io_sdio_inst_D3       ( hps_io_hps_io_sdio_inst_D3       ),
        .hps_io_hps_io_i2c0_inst_SDA      ( hps_io_hps_io_i2c0_inst_SDA      ),
        .hps_io_hps_io_i2c0_inst_SCL      ( hps_io_hps_io_i2c0_inst_SCL      ),
        .hps_io_hps_io_gpio_inst_GPIO48   ( hps_io_hps_io_gpio_inst_GPIO48   ),
        .hps_io_hps_io_gpio_inst_GPIO53   ( hps_io_hps_io_gpio_inst_GPIO53   ),
        .hps_io_hps_io_gpio_inst_GPIO54   ( hps_io_hps_io_gpio_inst_GPIO54   ),
        .hps_io_hps_io_gpio_inst_LOANIO49 ( hps_io_hps_io_gpio_inst_LOANIO49 ),
        .hps_io_hps_io_gpio_inst_LOANIO50 ( hps_io_hps_io_gpio_inst_LOANIO50 ),

        //External DDR3 Connections for HPS - DO NOT RENAME
        .memory_mem_a       ( memory_mem_a       ),
        .memory_mem_ba      ( memory_mem_ba      ),
        .memory_mem_ck      ( memory_mem_ck      ),
        .memory_mem_ck_n    ( memory_mem_ck_n    ),
        .memory_mem_cke     ( memory_mem_cke     ),
        .memory_mem_cs_n    ( memory_mem_cs_n    ),
        .memory_mem_ras_n   ( memory_mem_ras_n   ),
        .memory_mem_cas_n   ( memory_mem_cas_n   ),
        .memory_mem_we_n    ( memory_mem_we_n    ),
        .memory_mem_reset_n ( memory_mem_reset_n ),
        .memory_mem_dq      ( memory_mem_dq      ),
        .memory_mem_dqs     ( memory_mem_dqs     ),
        .memory_mem_dqs_n   ( memory_mem_dqs_n   ),
        .memory_mem_odt     ( memory_mem_odt     ),
        .memory_mem_dm      ( memory_mem_dm      ),
        .memory_oct_rzqin   ( memory_oct_rzqin   )
    );
        
`endif //USE_HPS_WRAPPER

endmodule

