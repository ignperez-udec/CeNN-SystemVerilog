# CeNN-SystemVerilog

Codes in SystemVerilog for CeNN hardware implementation on FPGA.

The CeNN process is divided in 3 stages:

## Preprocessing

Transforms to input RGB to Grayscale images (CeNN operates in one channel).
Since CeNNs need fractional values, the preprocessing module also transforms the grayscale image from unsigned int of 8 bits to a 15-bit fixed point. The most significant bit is the sign, 5 bits represent the integers part and 9 bits represent the fractional part. In addition, the fixed values are normalized to the range [−1, 1] (-1 are whites and 1 are black pixels).

## Processing 

The processing module contains the PE of the architecture.
Each PE:

* Stores values in a 2 LINE FIFO and use 9 registers to create the neighborhood 3x3 of each variable. The variables are u (input), y (output) and x (state equation).
* Uses u, y and x to calculate the state equation.

![equation](http://www.sciweavers.org/tex2img.php?eq=f_%7Bij%7D%28n%29%3D%20-x_%7Bij%7D%28n%29%2B%5Csum_%7B%28k%2C%20l%29%20%5Cin%20C%28i%2C%20j%29%7Da_%7Bkl%7Dy_%7Bkl%7D%28n%29%2B%0A%5Csum_%7B%28k%2C%20l%29%20%5Cin%20C%28i%2Cj%29%7Db_%7Bkl%7Du_%7Bkl%7D%20%2B%20I&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

# Hierarchy 

The hierarchy of codes is:

CeNN.sv:

  -> Preprocessing.sv:
  
    -> rgb2gray.sv                //RGB to gray
    
    -> uint2fixed.sv              //gray in 8 bits unsigned int to 15 bits fixed point
    
  -> Processing.sv:
  
    -> First_PE.sv                //PE[0], initial PE
    
    -> Processing_Element.sv      //PE[1:n], others PEs (from PE1 to PEn)
    
    each PE has (PE[0] and PE[1:n]):
    
      -> FIFOs.sv                 //FIFOs for input values (input u and output y)
      
      -> FIFO_x.sv                //FIFO for state variable (x)
      
      -> Reg_Mask.sv              //create a mask 3x3 for each input (u, y and x)
      
      -> Neuron.sv:               //Process to state equation, euler integration and saturation equation.
      
        -> multi.sv               //multiplies 2 values
        
  -> Postprocessing.sv:
  
    -> fixed2BaW                  //apply a threshold to the output pixels (y of last PE)
  
