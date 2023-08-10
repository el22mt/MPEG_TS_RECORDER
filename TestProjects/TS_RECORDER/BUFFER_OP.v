module BUFFER_OP #(
	parameter WIDTH = 1
	)(
	input							CLOCK		,
	input							RESET		,
	input		  [WIDTH-1 : 0]DATA_IN	,
	output reg [WIDTH-1 : 0]DATA_OUT
);

always @(negedge CLOCK or posedge RESET)	begin
	if (RESET)	begin
		DATA_OUT <= {WIDTH{1'b0}} ;
	end
	else	begin
		DATA_OUT <= DATA_IN		  ;
	end
end

endmodule
