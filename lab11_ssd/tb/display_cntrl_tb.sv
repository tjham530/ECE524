`timescale 1ns/1ps

module display_cntrl_tb ();

    logic [3:0] disp_val;
    logic [6:0] seg_out;

    display_cntrl uut
    (
        .*
    );

    
    initial begin 
        //init 
        disp_val = 'bz;

        //check for f
        disp_val = 4'hf;

        //check for f
        disp_val = 4'hd;

        //check for f
        disp_val = 4'h5;
    end
endmodule 