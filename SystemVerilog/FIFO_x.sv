module FIFO_x(input logic clk, ready_fixed,
              input logic [width-1:0] pixel,
              output logic read_ready,
              output logic [width-1:0] out);
              
    //Store a line of x
    
    parameter width=15;   //data bits
    parameter length=1024;   //size BRAM
    localparam AdrL=$clog2(length);
    
    logic [width-1:0] mem[length];   //BRAM
    logic [width-1:0] regx;
    logic [AdrL-1:0] Aw, Ar;   //Address
    logic wr, read;   //write and read signal 
    
    //Register for synchronization
    always_ff @(posedge clk) begin 
        if(ready_fixed) begin   //regx = pixel is pixel isnot blanking (HDMI)
            regx<=pixel;
            wr<=1;
        end
        else begin
            regx<=15'b000001000000000;   //regx = 1 is pixel is blanking (HDMI)
        end
    end    
    
    //LINE (FIFO)
    always_ff @(posedge clk) begin 
        if(!ready_fixed) begin   //restore directions
            Aw<=0;
            Ar<=0;
        end
        else begin
            if (wr) begin
                mem[Aw]<=regx;   //store data in FIFO
                Aw<=Aw+1;   //add one to direction write FIFO
                if(Aw>=length-1) begin   //restore direction write
                    Aw<=0;
                    read_ready<=1;
                end
            end
            if(read_ready) begin   //read from FIFO
                out<=mem[Ar];  
                Ar<=Ar+1;   //add one to direction read FIFO
                if(Ar>=length-1) begin   //restore direction read
                    Ar<=0;
                end
            end
            else begin
                out<=15'b000001000000000;   //out=1 if pixel isnot active (blanking in HDMI)
            end
        end
    end 


endmodule 