module DECODER_7SEGMENT(
  input         [3:0] IN,
  output reg    [6:0] DISP
);

always @(IN)  begin
  case(IN)
//  4'd0   : DISP = 7'h7F;    // Set DISP to 7'h7F when IN is 4'd0 (OFF).
	 
	 4'd0   : DISP = 7'h40;    // Set DISP to 7'h79 -> display 0.
    
	 4'd1   : DISP = 7'h79;    // Set DISP to 7'h79 -> display 1.
    4'd2   : DISP = 7'h24;    // Set DISP to 7'h24 -> display 2.
    4'd3   : DISP = 7'h30;    
    4'd4   : DISP = 7'h19;    
    4'd5   : DISP = 7'h12;    
    4'd6   : DISP = 7'h02;    
    4'd7   : DISP = 7'h78;    
    4'd8   : DISP = 7'h00;    
    4'd9   : DISP = 7'h18;    
    
	 4'd10  : DISP = 7'h08;		// Set DISP to 7'h08 -> display A.    
    4'd11  : DISP = 7'h03;    // Set DISP to 7'h03 -> display B.
    4'd12  : DISP = 7'h46;    
    4'd13  : DISP = 7'h21;    
    4'd14  : DISP = 7'h06;    
    4'd15  : DISP = 7'h0E;    // Set DISP to 7'h0E -> display F.
    default: DISP = 7'h3F;    // Display - for all other IN values.
  endcase
end

endmodule
