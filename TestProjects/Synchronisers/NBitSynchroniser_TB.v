`timescale 1 ns/100 ps

module NBitSynchroniser_TB ();

localparam WIDTH  = 1;
localparam LENGTH = 2;

    //Clock and Asynchronous Input
    reg              clock	 ;
	 reg  [WIDTH-1:0] asyncIn;
    
	 //Synchronous Output
    wire [WIDTH-1:0] syncOut;

NBitSynchroniser #(
    .WIDTH 	(WIDTH	),
    .LENGTH	(LENGTH	)
	)
	DUT(
	 .asyncIn(asyncIn	),
    .clock	(clock	),
    .syncOut(syncOut	)
);	 

initial	begin
	clock		= 1'b0			;
end

always	begin
#10	clock <= ~clock;
end

initial	begin
#10	asyncIn	=1'b1;

#50	$stop;
end 
endmodule
