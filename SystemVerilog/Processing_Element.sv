module Processing_Element(input logic clk, ready_fixed,
                          input logic [2:0] sw,
                          input logic [width-1:0] pixel_y, pixel_x, pixel_u,
                          output logic [width-1:0] out_neuron, euler_out, input_delay);   //y, x and u respectively

    parameter width = 15;
    parameter length_column = 10;
    parameter bit_fractional = 9;
    
    //PE: process u(input), y(output) and x(state variable) in the state equation (neuron)
    
    //Reg
    logic read_ready_u, read_ready_y, read_ready_x;   //activation signals for read memory 
    logic active_mask_u, active_mask_y, active_mask_x;   //activation signals of mask registers
    logic [width-1:0] out_u1, out_u2, out_u3, out_y1, out_y2, out_y3, out_x;   //outs of FIFO 
    logic [width-1:0] u11, u12, u13, u21, u22, u23, u31, u32, u33;   //out of mask u
    logic [width-1:0] y11, y12, y13, y21, y22, y23, y31, y32, y33;   //out of mask y
    logic [width-1:0] x_n;   //out of delay x (2 cycles for sync with u22)
    
    
    //INPUT u
    //FIFO u
    FIFOs mem_u(.clk, .ready_fixed, .pixel(pixel_u),   //inputs
                .read_ready(read_ready_u), .out_1(out_u1), .out_2(out_u2), .out_3(out_u3));   //outputs  
    defparam mem_u.width = width;
    defparam mem_u.length = length_column;
    //Reg mask (3x3)
    Reg_Mask reg_u(.clk, .read_ready(read_ready_u), .out_1(out_u1), .out_2(out_u2), .out_3(out_u3),   //inputs
                   .active_mask(active_mask_u), .u11, .u12, .u13, .u21, .u22, .u23, .u31, .u32, .u33);   //outputs             
    defparam reg_u.width = width; 
    
    
    //OUTPUT y
    //FIFO y
    FIFOs mem_y(.clk, .ready_fixed, .pixel(pixel_y),   //inputs
                .read_ready(read_ready_y), .out_1(out_y1), .out_2(out_y2), .out_3(out_y3));   //outputs
    defparam mem_y.width = width;
    defparam mem_y.length = length_column;
    //Reg mask (3x3)
    Reg_Mask reg_y(.clk, .read_ready(read_ready_y), .out_1(out_y1), .out_2(out_y2), .out_3(out_y3),   //inputs
                   .active_mask(active_mask_y), .u11(y11), .u12(y12), .u13(y13), .u21(y21), .u22(y22), .u23(y23), .u31(y31), .u32(y32), .u33(y33));   //outputs                
    defparam reg_y.width = width; 
        
        
    //EULER x
    //FIFO x
    FIFO_x mem_x(.clk, .ready_fixed, .pixel(pixel_x),   //inputs
                 .read_ready(read_ready_x), .out(out_x));   //outputs           
    defparam mem_x.width = width;
    defparam mem_x.length = length_column;   
    //Reg x
    Reg_x reg_x(.clk, .read_ready(read_ready_x), .out(out_x),   //inputs
                    .active_delay(active_mask_x), .x_n);   //outputs                      
    defparam reg_x.width = width;
    
    
    //Neuron (processing)
    //Neuron
    Neuron neuron(.clk, .ready_signal(active_mask_u), .sw, .bef_iteration(x_n), .u11, .u12, .u13, .u21, .u22, .u23, .u31, .u32, .u33,   //inputs
                  .y11, .y12, .y13, .y21, .y22, .y23, .y31, .y32, .y33,   //inputs
                  .out_cenn(out_neuron), .euler_out, .input_delay);   //outputs
    defparam neuron.width = width;
    defparam neuron.bit_fractional = bit_fractional;

endmodule
