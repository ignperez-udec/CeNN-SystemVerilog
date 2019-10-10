module uint2fixed(input logic clk,
                  input logic [width_uint-1:0] gray,
                  output logic ready_fixed,
                  output logic [width_fixed-1:0] fixed);

    parameter width_uint = 8;
    parameter width_fixed = 15;
    parameter position_int_part = 10;   //begin of int part
    
    logic [width_uint+9-1:0] temp1, temp2, mask;
    bit [3:0] count;
    
    //pixed_fixed = 1 - 2gray/256 (15 bits)
    always_ff @(posedge clk) begin
        temp1 <= {9'b0,gray};
        mask <= temp1 << position_int_part-8;   //left shift for 9 bits (LSB) for fractional part
                                                //-8 for division by 256 (right shift)
                                                //mask = 2*gray/256
        temp2 <= 17'b1000000000 - mask;   // subtraction (1 - mask)
        fixed <= temp2[width_fixed-1:0];   //fixed bits to out
        if (count<=5) begin
            count <= count+1;
            ready_fixed<=0;   //signal to PEs
        end
        else begin
            ready_fixed<=1;  
        end
    end
    
endmodule
