module BUFFER_IP #(
	parameter WIDTH = 1											// 1-bit wide buffer by default.
	)(
	input							CLOCK		,						// Clock signal for the buffer.
	input							RESET		,						// Reset signal.
	input		  [WIDTH-1 : 0]DATA_IN	,						// Input data, WIDTH-bits wide.
	output reg [WIDTH-1 : 0]DATA_OUT							// Output data, WIDTH-bits wide.
);

always @(posedge CLOCK or posedge RESET)	begin
	if (RESET)	begin												// Asynchronous Reset.
		DATA_OUT <= {WIDTH{1'b0}}	;
	end
	else	begin
		DATA_OUT <= DATA_IN			;							// Output triggered at rising edge of CLOCK.
	end
end

endmodule
