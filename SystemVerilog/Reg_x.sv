module Reg_x(input logic clk, read_ready,
                 input logic [width-1:0] out,
                 output logic active_delay,
                 output logic [width-1:0] x_n);
                 
    parameter width=8;
    
    bit [3:0] count;
    logic [width-1:0] reg_x0;
    
    //delays in 2 cycles x(n) (for synchronization with reg_mask)
   
    always_ff @(posedge clk) begin
        if(read_ready) begin
            //delays
            reg_x0 <= out;
            x_n <= reg_x0;;
            //activations signals
            if (count<=3) begin    //if count is less than 4, active_mask is 0
                count<=count+1;
                active_delay<=0;
            end
            else begin
                active_delay<=1;    //else, active is 1
            end
        end
    end
    
endmodule
