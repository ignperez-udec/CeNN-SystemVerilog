module Reg_Mask(input logic clk, read_ready,
                 input logic [width-1:0] out_1, out_2, out_3,
                 output logic active_mask,
                 output logic [width-1:0] u11, u12, u13, u21, u22, u23, u31, u32, u33);
                 
    parameter width=8;
    
    bit [3:0] count;
    
    //create mask 3x3
   
    always_ff @(posedge clk) begin
        if(read_ready) begin
            //initial values
            u13<=out_3;
            u23<=out_2;
            u33<=out_1;
            //intermediate values
            u12<=u13;
            u22<=u23;
            u32<=u33;
            //final values
            u11<=u12;
            u21<=u22;
            u31<=u32;
            //activations signals
            if (count<=3) begin    //if count is less than 4, active_mask is 0
                count<=count+1;
                active_mask<=0;
            end
            else begin
                active_mask<=1;    //else, active is 1
            end
        end
    end
    
endmodule