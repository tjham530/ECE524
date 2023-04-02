`timescale 1ns/1ps       //keep timing with regards to actual time for `define's

`define m1 "   [$monitor]  : %t => r_data = %b | full = %b | rx_empty = %b | tx = %b | tx_full = %b "
`define half_cp 4                    //1/(2* sys clk) => 4ns
`define full_cp 8                    //1/(125MHz) => 8ns
`define tick_rate (`full_cp*67)      //1 tick/ 67 clocks
`define bit_rate 8681                //(1/115200) = 8.68us [set baud rate as rx transmission rate]

module baud_gen_tb ();
    //params
    localparam bits = 8;

    //tb signals 
    logic clk = 1'b0;
    logic reset;
    logic tick;
    
    //instance
    baud_gen #(.DVSR_BITS(bits)) uut 
    (
        .clk (clk),
        .reset (reset),
        .tick (tick)
    );     

    //clk 
    always begin 
        #`half_cp clk = ~clk; 
        //#1 clk = ~clk; 
    end
    
    //main block 
    initial begin 
        reset = 1'b1;
        #`full_cp reset = 1'b0;
//        #1 reset = 1'b0;
        #750 $finish;  
    end 
        
endmodule

    //notes:
        //rd line needs to go low to high for each read to go on. 