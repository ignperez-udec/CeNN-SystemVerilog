module FIFOs(input logic clk, ready_fixed,
               input logic [width-1:0] pixel,
               output logic read_ready,
               output logic [width-1:0] out_1, out_2, out_3);
    
    parameter width=15;   //data bits
    parameter length=1024;   //size BRAM
    localparam AdrL=$clog2(length);
    
    logic [width-1:0] mem2[length], mem3[length];   //BRAMs
    logic [AdrL-1:0] Aw2, Aw3, Ar2, Ar3;   //Address
    logic wr2, wr3, r1, r2;   //write and read signal  
    
     //First LINE
    always_ff @(posedge clk) begin 
        if(ready_fixed) begin   //out = pixel is pixel isnot blanking (HDMI)
            out_1<=pixel;
            wr2<=1;
        end
        else begin
            out_1<=15'b000001000000000;   //out = 1 is pixel is blanking (HDMI)
        end
    end  
    
    //Second LINE (FIFO)
    always_ff @(posedge clk) begin 
        if(!ready_fixed) begin   //restore directions
            Aw2<=0;
            Ar2<=0;
        end
        else begin
            if (wr2) begin
                mem2[Aw2]<=out_1;   //store data in FIFO2
                Aw2<=Aw2+1;   //add one to direction write FIFO2
                if(Aw2>=length-1) begin   //restore direction write
                    Aw2<=0;
                    r2<=1;
                    wr3<=1;
                end
            end
            if(r2) begin   //read from FIFO
                out_2<=mem2[Ar2];  
                Ar2<=Ar2+1;   //add one to direction read FIFO2
                if(Ar2>=length-1) begin   //restore direction read
                    Ar2<=0;
                end
            end
            else begin
                out_2<=15'b000001000000000;   //out=1 if pixel isnot active (blanking in HDMI)
            end
        end
    end 
    
    //Third LINE (FIFO)
    always_ff @(posedge clk) begin 
        if(!ready_fixed) begin   //restore directions
            Aw3<=0;
            Ar3<=0;
        end
        else begin
            if (wr3) begin
                mem3[Aw3]<=out_2;    //store data in FIFO3
                Aw3<=Aw3+1;   //add one to direction write FIFO3
                if(Aw3>=length-1) begin   //restore direction write
                    Aw3<=0;
                    read_ready<=1;
                end
            end
            if(read_ready) begin   //read from FIFO
                out_3<=mem3[Ar3];
                Ar3<=Ar3+1;   //add one to direction read FIFO3
                if(Ar3>=length-1) begin   //restore direction read
                    Ar3<=0;
                end
            end
            else begin
                out_3<=15'b000001000000000;   //out=1 if pixel isnot active (blanking in HDMI)
            end
        end
    end 

endmodule 