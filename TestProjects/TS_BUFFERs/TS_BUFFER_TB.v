`timescale 1ns / 100ps

module TS_BUFFER_TB;

reg			RESET		;
reg 			CLOCK 	;

reg  [9:0]	DATA_IN	;

wire [9:0]	DATA_OUT	;


BUFFER_COMB DUT(
	.RESET		(RESET		),
	.CLOCK		(CLOCK		),
	
	.DATA_IN		(DATA_IN		),
	
	.DATA_OUT	(DATA_OUT	)	
);


initial begin
		DATA_IN = 10'd0;
		
		RESET	 = 1'b1;
		CLOCK	 = 1'b0;
	
#10		RESET	 = 1'b0;
//#17	RESET	 = 1'b1;
//#22	RESET	 = 1'b0;
	
end

always begin

#5	CLOCK = (~CLOCK);
end

initial begin

#20	DATA_IN = 10'b1100110011;
#20 	DATA_IN = 10'b0011001100;
#20	DATA_IN = 10'b1100110111;
#20	DATA_IN = 10'b0011100100;
#20	DATA_IN = 10'b1110110001;
#20	DATA_IN = 10'b1011001100;
#20	DATA_IN = 10'b1101010011;

#20	$stop;
end

endmodule
	