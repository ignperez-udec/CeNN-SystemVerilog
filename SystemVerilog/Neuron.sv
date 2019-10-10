module Neuron(input logic clk, ready_signal,
              input logic [2:0] sw,
              input logic [width-1:0] bef_iteration,   //x(n)
              input logic [width-1:0] u11, u12, u13, u21, u22, u23, u31, u32, u33,   //input neurons
              input logic [width-1:0] y11, y12, y13, y21, y22, y23, y31, y32, y33,   //output neurons
              output logic [width-1:0] out_cenn, euler_out, input_delay);   //y(n+1), x(n+1), delay u22
               
    parameter width = 15;
    parameter bit_fractional = 9;
    
    logic [width-1:0] a11, a12, a13, a21, a22, a23, a31, a32, a33;
    logic [width-1:0] b11, b12, b13, b21, b22, b23, b31, b32, b33;
    logic [width-1:0] I;
    
    logic signed [width-1:0] multix, multiy_0, multiy_1, multiy_2, multiy_3, multiy_4, multiy_5, multiy_6, multiy_7, multiy_8;   //register for multiplications
    logic signed [width-1:0] multiu_0, multiu_1, multiu_2, multiu_3, multiu_4, multiu_5, multiu_6, multiu_7, multiu_8;
    logic signed [width-1:0] add, sat, abs_p, abs_n, abs_pos, abs_neg, div;
    
    //Euler registers
    logic [width-1:0] h = 15'b000001000000000;   //Step Euler (h=1)
    logic signed [width-1:0] temp;
    logic [width-1:0] temp2;
    
    logic [width-1:0] reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15, reg16, reg17, reg18, reg19, reg20;   //temporal register
    logic [width-1:0] reg1u, reg2u, reg3u, reg4u, reg5u, reg6u, reg7u, reg8u, reg9u, reg10u, reg11u;   //delay registers (input) u
    logic [width-1:0] reg1x, reg2x, reg3x;   //delay registers (euler) x
    logic [width-1:0] reg1xn, reg2xn, reg3xn, reg4xn, reg5xn, reg6xn, reg7xn;   //delays for x(n) (save value for euler integration) 
    
    //counter for signal ready_processing (sync with others PE)
    bit [3:0] count;
    
    always_comb begin
        unique casez (sw)
            0: begin //White and black edge
                   //A
                   a11=0; a12=0; a13=0; a21=0; a22=15'b00100000000000; a23=0; a31=0; a32=0; a33=0;   // [0, 0, 0; 0, 4, 0; 0, 0, 0] 
                   //B
                   b11=0; b12=15'b111110000000000; b13=0; b21=15'b111110000000000; b22=15'b000101000000000; 
                   b23=15'b111110000000000; b31=0; b32=15'b111110000000000; b33=0;   //[0, -2, 0; -2, 5, -2; 0, -2, 0]
                   //I
                   I=15'b111111000000000;   //-1 
               end      
            1: begin //grayscale edge (first)
                   //A
                   a11=0; a12=0; a13=0; a21=0; a22=15'b000010000000000; a23=0; a31=0; a32=0; a33=0;   // [0, 0, 0; 0, 2, 0; 0, 0, 0]
                   //B
                   b11=15'b111111000000000; b12=15'b111111000000000; b13=15'b111111000000000; b21=15'b111111000000000;
                   b22=15'b001000000000000; b23=15'b111111000000000; b31=15'b111111000000000; b32=15'b111111000000000; b33=15'b111111000000000;   // [-1, -1, -1; -1, 8, -1; -1, -1, -1]
                   //I
                   I=15'b111111000000000;   //-1
               end 
            2: begin //grayscale edge (second)
                   //A
                   a11=0; a12=0; a13=0; a21=0; a22=15'b000010000000000; a23=0; a31=0; a32=0; a33=0;   // [0, 0, 0; 0, 2, 0; 0, 0, 0]
                   //B
                   b11=15'b111111000000000; b12=15'b111111000000000; b13=15'b111111000000000; b21=15'b111111000000000;
                   b22=15'b001000000000000; b23=15'b111111000000000; b31=15'b111111000000000; b32=15'b111111000000000; b33=15'b111111000000000;   // [-1, -1, -1; -1, 8, -1; -1, -1, -1]
                   //I
                   I=15'b111111100000000;   //-0.5  
               end 
            3: begin //Noise (salt and pepper) (1)
                   //A
                   a11=0; a12=15'b000010000001111; a13=0; a21=15'b000010000001111; a22=15'b000010000110011;
                   a23=15'b000010000001111; a31=0; a32=15'b000010000001111; a33=0;   ////[0, 2.03, 0; 2.03, 2.1, 2.03; 0, 2.03, 0] 
                   //B
                   b11=0; b12=0; b13=0; b21=0; b22=15'b000011111111011; b23=0; b31=0; b32=0; b33=0;   //[0, 0, 0; 0, 3.99, 0; 0, 0, 0]
                   //I
                   I=15'b111111111111011;   //-0.01 
               end 
            4: begin //Noise (salt and pepper) (2)
                   //A
                   a11=0; a12=15'b000011000000000; a13=0; a21=15'b000011000000000; a22=15'b000010000000000; 
                   a23=15'b000011000000000; a31=0; a32=15'b000011000000000; a33=0;   //[0, 3, 0; 3, 2, 3; 0, 3, 0]
                   //B
                   b11=0; b12=0; b13=0; b21=0; b22=15'b000110000000000; b23=0; b31=0; b32=0; b33=0;   //[0, 0, 0; 0, 6, 0; 0, 0, 0]
                   //I
                   I=15'b000001000000000;   //1 
               end
            5: begin //Conectivity
                   //A
                   a11=0; a12=15'b000100011001101; a13=0; a21=15'b000100011001101; a22=15'b000011100110011; 
                   a23=15'b000100011001101; a31=0; a32=15'b000100011001101; a33=0;   //[0, 4.4, 0; 4.4, 3.6, 4.4; 0, 4.4, 0]
                   //B
                   b11=0; b12=0; b13=0; b21=0; b22=15'b001010101100110; b23=0; b31=0; b32=0; b33=0;   //[0, 0, 0; 0, 10.7, 0; 0, 0, 0]
                   //I
                   I=15'b000111000000000;   //7
               end
            6: begin //Shadows
                   //A
                   a11=0; a12=0; a13=0; a21=0; a22=15'b000010000110011; a23=15'b000010000000000; a31=0; a32=0; a33=0;   //[0, 0, 0; 0, 2.1, 2; 0, 0, 0]
                   //B
                   b11=0; b12=0; b13=0; b21=0; b22=15'b000000111001101; b23=0; b31=0; b32=0; b33=0;   //[0, 0, 0; 0, 0.9, 0; 0, 0, 0]
                   //I
                   I=15'b000001000000000;   //1
               end
            7: begin //Displacement
                   //A
                   a11=0; a12=0; a13=0; a21=0; a22=15'b000010000000000; a23=15'b000010000000000; a31=0; a32=0; a33=0;   //[0, 0, 0; 0, 2, 2; 0, 0, 0]
                   //B
                   b11=0; b12=0; b13=0; b21=0; b22=0; b23=0; b31=0; b32=0; b33=0;  //[0, 0, 0; 0, 0, 0; 0, 0, 0]
                   //I
                   I=15'b000000000000000;   //0
               end
        endcase
    end
    
    //pipeline 1 (MULTIPLICATIONS)
    multi multi_x (clk, 15'b111111000000000, bef_iteration, multix);
    multi multi_y11 (clk, a11, y11, multiy_0);   //convolution A*y
    multi multi_y12 (clk, a12, y12, multiy_1);
    multi multi_y13 (clk, a13, y13, multiy_2);
    multi multi_y21 (clk, a21, y21, multiy_3);
    multi multi_y22 (clk, a22, y22, multiy_4);
    multi multi_y23 (clk, a23, y23, multiy_5);
    multi multi_y31 (clk, a31, y31, multiy_6);
    multi multi_y32 (clk, a32, y32, multiy_7);
    multi multi_y33 (clk, a33, y33, multiy_8);
    multi multi_u11 (clk, b11, u11, multiu_0);   //convolution B*u
    multi multi_u12 (clk, b12, u12, multiu_1);
    multi multi_u13 (clk, b13, u13, multiu_2);
    multi multi_u21 (clk, b21, u21, multiu_3);
    multi multi_u22 (clk, b22, u22, multiu_4);
    multi multi_u23 (clk, b23, u23, multiu_5);
    multi multi_u31 (clk, b31, u31, multiu_6);
    multi multi_u32 (clk, b32, u32, multiu_7);
    multi multi_u33 (clk, b33, u33, multiu_8);
    
    always_ff @(posedge clk) begin
        if(ready_signal) begin
            //parallel
            
            //HERE MULTIPLICATIONS (CONVOLUTIONS) (UP)
            
            //pipeline 2 (ADDS)   (limit to 15 bits (MSB))
            reg1<=multix + multiy_0;   //f(n)=-x(n)+A*y(n)+B*u+I
            reg2<=multiy_1 + multiy_2;
            reg3<=multiy_3 + multiy_4;
            reg4<=multiy_5 + multiy_6;
            reg5<=multiy_7 + multiy_8;
            reg6<=multiu_0 + multiu_1;
            reg7<=multiu_2 + multiu_3;
            reg8<=multiu_4 + multiu_5;
            reg9<=multiu_6 + multiu_7;
            reg10<=multiu_8 + I;
            
            //pipeline 3 (ADDS)
            reg11<=reg1+reg2;
            reg12<=reg3+reg4;
            reg13<=reg5+reg6;
            reg14<=reg7+reg8;
            reg15<=reg9+reg10;
            
            //pipeline 4  (ADDS)
            reg16<=reg11+reg12;
            reg17<=reg13+reg14;
            reg18<=reg15;
            
            //pipeline 5 (ADDS)
            reg19<=reg16+reg17;
            reg20<=reg18;
            
            //pipeline 6  (ADDS)
            add<=reg19+reg20;   //f(n)=multi
        end
    end

    //Euler multiplication
    multi multi_euler (clk, add, h, temp);            

    always_ff @(posedge clk) begin
        if(ready_signal) begin
            //Euler integration
            //HERE EULER MULTIPLICATIONS (UP)
            temp2<=temp + reg7xn;   //x(n+1) = h*f(n) + x(n)
            
            //Saturation function
            abs_p<=temp2+15'b000001000000000;   //x(n+1)+1
            abs_n<=temp2+15'b111111000000000;   //x(n+1)-1
            if(abs_p[width-1]==1) begin   //|x(n+1)+1|
                abs_pos<=~abs_p+1;   //*-1
            end
            else begin
                abs_pos<=abs_p;   //*-1
            end
            if(abs_n[width-1]==1) begin   //|x(n+1)-1|
                abs_neg<=~abs_n+1;
            end
            else begin
                abs_neg<=abs_n;
            end
            div<=abs_pos-abs_neg;   //|x(n+1)+1| - |x(n+1)-1|
            out_cenn<=div>>>1;   //0.5*(|x(n+1)+1| - |x(n+1)-1|)
            
            //input delay
            reg1u<=u22;
            reg2u<=reg1u;
            reg3u<=reg2u;
            reg4u<=reg3u;
            reg5u<=reg4u;
            reg6u<=reg5u;
            reg7u<=reg6u;
            reg8u<=reg7u;
            reg9u<=reg8u;
            reg10u<=reg9u;
            reg11u<=reg10u;
            input_delay<=reg11u;
            
            //euler delay
            reg1x<=temp2;
            reg2x<=reg1x;
            reg3x<=reg2x;
            euler_out<=reg3x;
            //euler_out<=temp;
            
            //x(n) delays (store value for euler integration)
            reg1xn<=bef_iteration;
            reg2xn<=reg1xn;
            reg3xn<=reg2xn;
            reg4xn<=reg3xn;
            reg5xn<=reg4xn;
            reg6xn<=reg5xn;
            reg7xn<=reg6xn;
        end
    end

endmodule