`timescale 1ns/1ps
`define m "   [$monitor]  : %t => chip_sel = %b | seg = %b | kcol = %b | krow = %b"
`define full_cp 20
`define half_cp 10
`define bp 2_000_000    //2ms

module ssd_keypad_top_tb ();

    //tb signals 
    logic clk = 1'b0;
    logic btn;   //btn0 used for rst
    logic chip_sel;   //chip_sel bit     
    logic [6:0] seg;
    logic [3:0] kcol;
    logic [3:0] krow;

    //instance 
    top_pt2 uut 
    (
        .clk (clk),
        .btn (btn), 
        .chip_sel (chip_sel),
        .seg (seg),
        .kcol (kcol),
        .krow (krow)
    );

    //monitor block 
    initial begin 
        $monitor(`m, $time, chip_sel, seg, kcol, krow);  
    end 
    
    //setup block
    initial begin
        $timeformat(-9, 1, "ns");   //formats how we display the timevalues
    end 

    //clk pulsing 
    always begin 
        #`half_cp clk = ~clk;
    end

    //main code:
    initial begin   
        //init 
        btn = 1'b0; krow = 'b0;

        //push rst 
        #`full_cp btn = 4'h1; 
        #`bp btn = 4'h0; 
        
        //button 1 is pushed: 
        #(`bp) krow = 4'b1011;  //btn #7
        #(`bp) krow = 4'h0; 
        #(`bp) krow = 4'h7; 
        #(`bp) krow = 4'h0; 
        #(`bp*10); 
        $finish;
    end 
endmodule 