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
* Uses u, y(n) and x(n) to calculate the state equation. (A is a propagation kernel, B is a control kernel and I is a bias)

![equation](http://www.sciweavers.org/tex2img.php?eq=f_{ij}(n)%3D%20-x_{ij}(n)%2B\sum_{(k,%20l)%20\in%20C(i,%20j)}a_{kl}y_{kl}(n)%2B%0A\sum_{(k,%20l)%20\in%20C(i,j)}b_{kl}u_{kl}%20%2B%20I&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

* Use euler integration method to compute x(n+1)

![equation](http://www.sciweavers.org/tex2img.php?eq=x_%7Bij%7D%28n%2B1%29%3Dx_%7Bij%7D%28n%29%2Bh%5Ccdot%20f_%7Bij%7D%28n%29&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

* Use a symmetric linear saturation function to produces a value y(n+1) in the range [-1,1].

![equation](http://www.sciweavers.org/tex2img.php?eq=y_%7Bij%7D%28n%2B1%29%3D%5Cfrac%7B1%7D%7B2%7D%28%7Cx_%7Bij%7D%28n%2B1%29%2B1%7C-%7Cx_%7Bij%7D%28n%2B1%29-1%7C%29&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

OBS: In first iteration (PE[0]), y(0)=x(0)=u 

## Postprocessing

The postprocessing stage of the accelerator binarizes the CeNN output and generates an RGB output image. We compare the 15-bit output of the last PE in the processing stage to a user-provided threshold (using buttons) in the range [−1,1] to produce a binary output image.

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
  
