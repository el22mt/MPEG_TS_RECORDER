module BIT_SHIFT_TEST(
	input CLOCK,
	input	RESET,
	
	input [9:0]DATA_IN,
	
	output reg [31:0]DATA,
	
	output [31:0]DATA_OUT
);
reg FLAG;

always@	(posedge CLOCK or posedge RESET)	begin
	
	if(RESET)	begin
		
		DATA <= 32'd0;
		FLAG <= 1'b0;
	end
	else	begin
		
		if(FLAG == 1'b0)	begin
			
			DATA <= DATA << 10;
			FLAG <= 1'b1;
		end
		
		if(FLAG == 1'b1)	begin
			
			DATA[9:0] <= DATA_IN;
			FLAG <= 1'b0;
		end
	end
	
end

assign DATA_OUT = DATA;

endmodule

