module Processing(input logic clk, ready_fixed,
                  input logic [2:0] sw,
                  input logic [width-1:0] pixel,
                  output logic [width-1:0] out_cenn_0, out_cenn_x);
    
    //Processing module contains the 10 PEs (the first PE (only one FIFO) and normal PEs (3 FIFO, one for u(input), y(out) and x(state variable)))
                  
    parameter width=15;
    parameter length_column=1024;
    parameter bit_fractional=9;
    parameter number_PEs=10; 
    
    logic [width-1:0] y[number_PEs-1:0], x[number_PEs-1:0], u[number_PEs-1:0];   //output, state variable and input of each PE
    
    First_PE PE_0(.clk, .ready_fixed, .sw, .pixel,   //definition of First PE
                  .out_neuron(y[0]), .euler_out(x[0]), .input_delay(u[0]));
                   
    defparam PE_0.width=width;
    defparam PE_0.length_column=length_column;
    defparam PE_0.bit_fractional=bit_fractional;
    
    
    genvar i;   //generate n PEs (by default is 9)
    generate
        for (i=1; i<number_PEs; i=i+1) begin : PE
            Processing_Element #(
                .width(width),
                .length_column(length_column),
                .bit_fractional(bit_fractional)
            )
            PEs (.clk, .ready_fixed, .sw, .pixel_y(y[i-1]), .pixel_x(x[i-1]), .pixel_u(u[i-1]),
                 .out_neuron(y[i]), .euler_out(x[i]), .input_delay(u[i]));    
        end 
    endgenerate
    
    assign out_cenn_0 = y[0];    //assign the first output to out_cenn_0
    assign out_cenn_x = y[number_PEs-1];   //assign the n output to out_cenn_x (by defaul n=9) (10 PEs)
    
endmodule
