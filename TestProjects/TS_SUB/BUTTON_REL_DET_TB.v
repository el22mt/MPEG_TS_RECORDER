`timescale 1 ns/100 ps

module BUTTON_REL_DET_TB;

reg           CLOCK;
reg           RESET;
reg    [3:0]  BUTTONS;
wire   [3:0]  RELEASE;

BUTTON_REL_DET DUT(						  // Instantiate BUTTON_REL_DET module
  .CLOCK      (CLOCK		),
  .RESET      (RESET		),
  .BUTTONS    (BUTTONS	),
  .RELEASE    (RELEASE	)
);

initial  begin
    CLOCK = 1'b0;                     // Initialize CLOCK to 0
    RESET = 1'b1;                     // Set RESET to 1 initially
#10 RESET = 1'b0;                	  // Deassert RESET after 10 time units
end

always #5 CLOCK <= ~CLOCK;            // Toggle CLOCK every 5 time units

initial  begin
	
		BUTTONS = 4'b0000;   // Initialize BUTTONS to 4'b0000

#10	BUTTONS = 4'b1010;	// Set BUTTONS to 4'b1010 every 10 time units
#10	BUTTONS = 4'b0101;	// Set BUTTONS to 4'b0101 every 10 time units
#10	BUTTONS = 4'b0000;	// Set BUTTONS to 4'b0000 every 10 time units
#10	BUTTONS = 4'b0110;	// Set BUTTONS to 4'b0110 every 10 time units
#10	BUTTONS = 4'b0001;	// Set BUTTONS to 4'b0001 every 10 time units
#10	BUTTONS = 4'b0100;	// Set BUTTONS to 4'b0100 every 10 time units
#10	BUTTONS = 4'b0000;	// Set BUTTONS to 4'b0000 every 10 time units
	
#20 $stop;                 // Stop simulation after 20 time units
end

endmodule
