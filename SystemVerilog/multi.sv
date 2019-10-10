module multi(input logic clk,
             input logic [width-1:0] input_a, input_b,
             output logic [width-1:0] out);
             
    //expand inputs from 15 to 30 bits (with signed bits), multiplies and send a number of 15 bits
             
    parameter width = 15;
    parameter fractional_bit = 9;
    
    logic signed [2*width-1:0] mul_a, mul_b;
    logic signed [2*width-1:0] result;  
    
    always_comb  begin
        if (input_a[14] == 1) begin   //if input_a is negative, add 15 bits ones to mul_a
            mul_a = {15'b111111111111111, input_a};
        end
        else begin   //else, add 15 zeros (by default)
            mul_a = input_a;
        end
        if (input_b[14] == 1) begin   //if input_a is negative, add 15 bits ones to mul_b
            mul_b = {15'b111111111111111, input_b};
        end
        else begin   //else, add 15 zeros (by default)
            mul_b = input_b;
        end
        result = mul_a * mul_b;   //multiplies mul_a and mul_b (result has 30 bits)
    end
    
    always_ff @(posedge clk) begin
        out <= result[width-1+fractional_bit:fractional_bit];   //send an out of 15 bits (multiplications shifts the results in 9 bits (fractional bits))
    end

endmodule
