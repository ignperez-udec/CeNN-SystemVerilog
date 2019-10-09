# CeNN-SystemVerilog

Codes in SystemVerilog for CeNN hardware implementation on FPGA.

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
      
      -> Neuron.sv:                //Process to state equation, euler integration and saturation equation.
      
        -> multi.sv               //multiplies 2 values
        
  -> Postprocessing.sv:
  
    -> fixed2BaW                  //apply a threshold to the output pixels (y of last PE)
  
