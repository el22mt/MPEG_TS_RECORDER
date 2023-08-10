module BUTTON_REL_DET(
  input               CLOCK	,          					// Input clock signal
  input               RESET	,          					// Input reset signal
  input         [3:0] BUTTONS	,        					// Input representing the current state of buttons
  output reg    [3:0] RELEASE          					// Output register representing the button release signals
);

  reg    [3:0] PREV_BUTTONS;    								// Register to store previous button states.

  always @(posedge CLOCK or posedge RESET) begin
    if (RESET) begin
      PREV_BUTTONS <= 4'b0000;      						// Reset the previous button states.
      RELEASE      <= 4'b0000;      						// Reset the release signals.
    end
    else begin
      PREV_BUTTONS <= ~BUTTONS;      						// Store the previous button states.
      RELEASE      <= (PREV_BUTTONS & BUTTONS);  	   // Detect button releases.
    end
  end
endmodule

