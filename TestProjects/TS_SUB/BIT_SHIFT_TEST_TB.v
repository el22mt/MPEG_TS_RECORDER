`timescale 1 ns/100 ps

module BIT_SHIFT_TEST_TB;

	reg	CLOCK;
	reg	RESET;
	
	reg [9:0]DATA_IN;
	
	wire [31:0]DATA;
	
	wire [31:0]DATA_OUT;
	

BIT_SHIFT_TEST DUT(
	.CLOCK		(CLOCK),
	.RESET		(RESET),
	
	.DATA_IN		(DATA_IN),
	
	.DATA			(DATA),
	
	.DATA_OUT	(DATA_OUT)
);

initial	begin
		CLOCK = 1'b0;
		RESET = 1'b1;
		DATA_IN = 10'd0;
		
#10	RESET = 1'b0;
end

always	#5	CLOCK <= ~CLOCK;

initial	begin
		
#30	DATA_IN = 10'b1100110011;

#10	DATA_IN = 10'b0011001100;

#10	DATA_IN = 10'b1111100000;
		
#50	$stop;
end 


endmodule
