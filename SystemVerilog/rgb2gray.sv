module rgb2gray(input logic clk,
                input logic [width-1:0] R, G, B,
                output logic [width-1:0] gray);
    
    parameter width=8;
    
    always_ff @(posedge clk) begin
        gray <= (R>>2) + (G>>1) + (B>>2);
    end

endmodule
