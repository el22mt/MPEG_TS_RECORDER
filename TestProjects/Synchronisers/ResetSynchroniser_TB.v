`timescale 1 ns/100 ps

module ResetSynchroniser_TB();

  reg	 clock	 	;
  reg	 resetIn		;
  wire resetOut	;
  
//  wire compRST = ~resetIn;

ResetSynchroniser DUT(
    .clock		(clock	),
    .resetIn	(resetIn	),
    .resetOut	(resetOut)
);

initial	begin
	clock	= 1'b0;
end

always	begin
#10	clock <= ~clock;
end

initial	begin
		resetIn	= 1'b0;
#100	resetIn	= 1'b1;
#100	resetIn	= 1'b0;		
#04	resetIn	= 1'b1;
#01	resetIn	= 1'b0;
#01	resetIn	= 1'b1;
#10	resetIn	= 1'b0;
#10	resetIn	= 1'b1;
#10	resetIn	= 1'b0;
#10	resetIn	= 1'b1;
#10	resetIn	= 1'b0;
#10	resetIn	= 1'b1;
#10	resetIn	= 1'b0;
#179	resetIn	= 1'b1;
#04	resetIn	= 1'b0;
#120	resetIn	= 1'b1;
#04	resetIn	= 1'b0;
#50	resetIn	= 1'b1;
#04	resetIn	= 1'b0;

#200	$stop;
end 
endmodule
