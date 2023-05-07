`timescale 1ns / 1ns
module dbn_tb();

    //parameters
    localparam DP = 62_500_000;
    localparam PULSE_PER = 2;
    
    localparam full_cp = 8;
    localparam half_cp = 4;
    
    //tb signals 
    logic clk = 1'b0; 
    logic rst, button, result;
    
    debounce_pulse #(
        .DEBOUNCE_PERIOD (DP),
        .PULSE_PER (PULSE_PER)
    ) uut (
        .clk (clk),
        .rst (rst),
        .button (button),
        .result (result)
    );
    
    
    always begin 
        #half_cp clk = ~clk;
    end 
    
    initial begin 
        button = 1'b0; rst = 1'b0;
        
        //rst
        #full_cp rst = 1'b1;
        #full_cp rst = 1'b0;
        
        //button push: 250ms
        #full_cp  button = 1'b1;
        #(DP/2) button = 1'b0;
        #(full_cp*DP) $stop; 
    end 
endmodule
