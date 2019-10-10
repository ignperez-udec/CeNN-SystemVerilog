module Postprocessing (input logic clk, press_DOWN, press_UP, ready_signal,
                       input logic [width_fixed-1:0] out_cenn_0, out_cenn_x,
                       output logic [4:0] led,
                       output logic [width_RGB-1:0] black_white_0, black_white_x);
                       
    parameter width_fixed = 15;
    parameter width_RGB = 8;
                       
    fixed2BaW black_white_conversor (.clk, .press_DOWN, .press_UP, .ready_signal, .out_cenn_0, .out_cenn_x,
                                     .led, .black_white_0, .black_white_x);
                                     
    defparam black_white_conversor.width_fixed=width_fixed;
    defparam black_white_conversor.width_BaW=width_RGB;
    
endmodule