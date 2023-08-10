//module ResetSynchroniser (
//    input clock,
//    input resetIn,
//    
//    output resetOut
//);
//
////Reset synchroniser to avoid metastability if external push-button used
//reg [3:0] resetSync = 4'hF;
//
//always @ (posedge clock or posedge resetIn) begin
//    if (resetIn) begin
//        resetSync <= 4'hF; //Assert reset asynchronously
//    end else begin
//        resetSync <= {resetSync[2:0],1'b0}; //Deassert reset synchronously
//    end
//end
//
//assign resetOut = resetSync[3];
//
//endmodule
module ResetSynchroniser (
    input clock,
    input resetIn,
    
    output resetOut
);

//For active low Reset:
reg [3:0] resetSync = 4'h0;

always @ (posedge clock or negedge resetIn) begin
    if (~resetIn) begin
		  resetSync <= {resetSync[2:0],1'b1}; //Deassert reset synchronously
        
    end else begin
        resetSync <= 4'h0; //Assert reset asynchronously
    end
end

assign resetOut = resetSync[3];

endmodule
