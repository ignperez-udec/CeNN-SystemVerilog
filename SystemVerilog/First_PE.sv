module First_PE(input logic clk, ready_fixed,
                input logic [2:0] sw,
                input logic [width-1:0] pixel,
                output logic [width-1:0] out_neuron, euler_out, input_delay);
                
    parameter width = 15;
    parameter length_column = 1024;
    parameter bit_fractional = 9;
    
    //ready_fixed -> from fixed module
    //active_pixel -> from HDMI (active pixels in frame)
    
    //Reg
    logic read_ready, active_mask;
    logic [width-1:0] out_1, out_2, out_3;
    logic [width-1:0] u11, u12, u13, u21, u22, u23, u31, u32, u33;
    
    //FIFO
    FIFOs mem_uyx(.clk, .ready_fixed, .pixel,
                  .read_ready, .out_1, .out_2, .out_3);
    
    defparam mem_uyx.width = width;
    defparam mem_uyx.length = length_column;
    
    //Reg mask (3x3)
    Reg_Mask reg_uy(.clk, .read_ready, .out_1, .out_2, .out_3,
                    .active_mask, .u11, .u12, .u13, .u21, .u22, .u23, .u31, .u32, .u33);
                    
    defparam reg_uy.width = width; 
    
    //Neuron
    Neuron neuron_0(.clk, .ready_signal(active_mask), .sw, .bef_iteration(u22), .u11, .u12, .u13, .u21, .u22, .u23, .u31, .u32, .u33, 
                    .y11(u11), .y12(u12), .y13(u13), .y21(u21), .y22(u22), .y23(u23), .y31(u31), .y32(u32), .y33(u33), 
                    .out_cenn(out_neuron), .euler_out, .input_delay);
    
    defparam neuron_0.width = width;
    defparam neuron_0.bit_fractional = bit_fractional;
    
endmodule
