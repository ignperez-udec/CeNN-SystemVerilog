module fixed2BaW(input logic clk, press_DOWN, press_UP, ready_signal,   //clock, button down, button up, ready
                 input logic [width_fixed-1:0] out_cenn_0, out_cenn_x,   //outputs of PE 0 and PE 9
                 output logic [4:0] led,   //leds to displays the threshold
                 output logic [width_BaW-1:0] black_white_0, black_white_x);   //black and white values of PE 0 and PE 9 outs
                  
    parameter width_fixed=15;
    parameter width_BaW=8;
    
    logic [4:0] counter;
    logic [width_fixed-1:0] threshold;
    
    //If the user push a button, the counter change the threshold
    
    always_comb begin
        unique casez (counter)
            0: threshold=15'b111111000000000;    //-1
            1: threshold=15'b111111000100000;    //-0.9375
            2: threshold=15'b111111001000000;    //-0.875
            3: threshold=15'b111111001100000;    //-0.8125
            4: threshold=15'b111111010000000;    //-0.75
            5: threshold=15'b111111010100000;    //-0.6875
            6: threshold=15'b111111011000000;    //-0.625
            7: threshold=15'b111111011100000;    //-0.5625
            8: threshold=15'b111111100000000;    //-0.5
            9: threshold=15'b111111100100000;    //-0.4375
            10: threshold=15'b111111101000000;   //-0.375
            11: threshold=15'b111111101100000;   //-0.3125
            12: threshold=15'b111111110000000;   //-0.25
            13: threshold=15'b111111110100000;   //-0.1875
            14: threshold=15'b111111111000000;   //-0.125
            15: threshold=15'b111111111100000;   //-0.0625
            16: threshold=15'b000000000000000;   //0
            17: threshold=15'b000000000100000;   //0.0625
            18: threshold=15'b000000001000000;   //0.125
            19: threshold=15'b000000001100000;   //0.1875
            20: threshold=15'b000000010000000;   //0.25
            21: threshold=15'b000000010100000;   //0.3125
            22: threshold=15'b000000011000000;   //0.375
            23: threshold=15'b000000011100000;   //0.4375
            24: threshold=15'b000000100000000;   //0.5
            25: threshold=15'b000000100100000;   //0.5625
            26: threshold=15'b000000101000000;   //0.625
            27: threshold=15'b000000101100000;   //0.6875
            28: threshold=15'b000000110000000;   //0.75
            29: threshold=15'b000000110100000;   //0.8125
            30: threshold=15'b000000111000000;   //0.875
            31: threshold=15'b000000111100000;   //0.9375
        endcase
    end
    
    always_ff @(posedge clk) begin
        if(!ready_signal) begin    //by default, threshold is 0
            counter<=16;
        end
        else begin
            if(press_DOWN) begin    //is button down is pressed, counter decrease in one
                if(counter>0) begin    //condition to avoid underflow
                    counter<=counter-1;
                end
            end
            if(press_UP) begin   //is button up is pressed, counter increase in one
                if(counter<31) begin   //condition to avoid  overflow
                    counter<=counter+1;
                end
            end
        end
        led<=counter;    //assign counter in led (to see threshold)
    end
    
    
    //if out_cenn is less than threshold, black_white signal is 255 (white) and if out_cenn is greater than threshold, black_white is 0 (black)
    //in cenn values, -1 is white and 1 is black.
    always_ff @(posedge clk) begin
        //black and white values of out of first PE (PE[0])
		if(out_cenn_0[width_fixed-1]==0) begin   //compare sign bit out_cenn(positive=0)
			if(threshold[width_fixed-1]==1) begin
				black_white_0<=0;   //if out_cenn>0 and threshold<0, out_cenn>threshold => black_white is black 
			end
			else begin   //if out_cenn and threshold are positive,
				if(out_cenn_0>threshold) begin
					black_white_0<=0;    //if out_cenn>threshold => black_white is black
				end
				else begin
					black_white_0<=255;   //else, black_white is white
				end
			end
		end 
		else begin   //compare sign bit out_cenn(negative=1)
			if(threshold[width_fixed-1]==0) begin
				black_white_0<=255;    //if out_cenn<0 and threshold>0 => out_cenn<threshold => black_white is white
			end
			else begin   //if out_cenn and threshold are negative,
				if(out_cenn_0>threshold) begin   
					black_white_0<=0;   //if out_cenn>threshold => black_white is black
				end
				else begin
					black_white_0<=255;   //else, black_white is white
				end
			end
		end
        //black and white values of out of PE[n]
		if(out_cenn_x[width_fixed-1]==0) begin    //compare sign bit out_cenn(positive=0)
			if(threshold[width_fixed-1]==1) begin
				black_white_x<=0;   //if out_cenn>0 and threshold<0, out_cenn>threshold => black_white is black 
			end
			else begin   //if out_cenn and threshold are positive,
				if(out_cenn_x>threshold) begin
					black_white_x<=0;   //if out_cenn>threshold => black_white is black
				end
				else begin
					black_white_x<=255;   //else, black_white is white
				end
			end
		end 
		else begin    //compare sign bit out_cenn(negative=0)
			if(threshold[width_fixed-1]==0) begin
				black_white_x<=255;   //if out_cenn<0 and threshold>0, out_cenn<threshold => black_white is white
			end
			else begin   //if out_cenn and threshold are negative,
				if(out_cenn_x>threshold) begin
					black_white_x<=0;   //if out_cenn>threshold => black_white is black
				end
				else begin
					black_white_x<=255;   //else, black_white is white
				end
			end
		end
    end                    
endmodule
