module CeNN(input logic clk, press_DOWN, press_UP,   //clock and button to change threshold
            input logic [2:0] sw,   //switch to change kernel of CeNN
            input logic [width_RGB-1:0] R, G, B,   //inputs in RGB
            output logic [4:0] led,   //led to show threshold
            output logic [width_RGB-1:0] gray,   //gray images output
            output logic [width_fixed-1:0] pixel, out_cenn_0, out_cenn_x,   //fixed and out cenn (y[0] and y[9]) images outputs
            output logic [width_RGB-1:0] black_white_0, black_white_x);   //black and white images outputs (PE[0] and PE[10])

    parameter width_RGB = 8;
    parameter width_fixed = 15;
    parameter int_part_begin = 10;
    parameter length_column = 2200;   //total horizontal pixel in 1920x1080.
    parameter bit_fractional = 9;
    parameter number_PEs = 10;
    
    //Reg
    logic ready_fixed;

    //preprocessing module (RGB2gray and gray2fixed_point)
    Preprocessing pre(.clk, .R, .G, .B,
                      .ready_fixed, .gray, .fixed(pixel));
                      
    defparam pre.width_RGB = width_RGB;
    defparam pre.width_fixed = width_fixed;
    defparam pre.int_part_begin = int_part_begin;
    
    //processing module (ten PEs: FIFO, state equation, euler equation, saturation equation)
    Processing pro (.clk, .ready_fixed, .sw, .pixel,
                    .out_cenn_0, .out_cenn_x);
                    
    defparam pro.width = width_fixed;
    defparam pro.length_column = length_column;
    defparam pro.bit_fractional = bit_fractional;
    defparam pro.number_PEs = number_PEs;
    
    //Postprocessing module (fixed2black_and_white)
    Postprocessing post(.clk, .press_DOWN, .press_UP, .ready_signal(ready_fixed), .out_cenn_0, .out_cenn_x,
                        .led, .black_white_0, .black_white_x);
                   
    defparam post.width_fixed=width_fixed;
    defparam post.width_RGB=width_RGB;

endmodule
