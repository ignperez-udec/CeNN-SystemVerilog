module Preprocessing(input logic clk,
                     input logic [width_RGB-1:0] R, G, B,   //RGB inputs
                     output logic ready_fixed,
                     output logic [width_RGB-1:0] gray,   //only for DEMOs
                     output logic [width_fixed-1:0] fixed);   //cenn_values in fixed point [-1,1]
    
    parameter width_RGB = 8;
    parameter width_fixed = 15;
    parameter int_part_begin = 10;  //10th bit
    
    //RGB to GRAY
    rgb2gray rgb(.clk, .R, .B, .G,
                 .gray);
                 
    defparam rgb.width = width_RGB;
    
    //GRAY to Fixed point 15 bits (1 bit for signed - 5 bits for integers - 9 bits for fractional)
    uint2fixed fixed_15bits(.clk, .gray,
                            .ready_fixed, .fixed);
    
    defparam fixed_15bits.width_uint = width_RGB;
    defparam fixed_15bits.width_fixed = width_fixed;
    defparam fixed_15bits.position_int_part= int_part_begin;
    
endmodule
