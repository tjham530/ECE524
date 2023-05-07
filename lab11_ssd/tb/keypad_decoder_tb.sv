`timescale 1ns/1ps
`define m "   [$monitor]  : %t => col = %b | decode_out = %b | is_a_key_pressed = %b "
`define full_cp 20
`define half_cp 10
`define button_press 1000000

module keypad_decoder_tb ();

    //tb signals 
    logic clk = 1'b0;
    logic rst = 1'b0;
    logic [3:0] row, col;
    logic [3:0] decode_out;
    logic is_a_key_pressed;

    //inst 
    keypad_decoder uut
    (
        .clk (clk),
        .rst (rst),
        .row (row),
        .col (col),
        .decode_out (decode_out),
        .is_a_key_pressed (is_a_key_pressed)
    );

    ////////////////////////////////////////////////////////////////////
    //SETUP BLOCKS
    /////////////////////////////////////////////////////////////////////
     //monitor block 
    initial begin 
        $monitor(`m, $time, col, decode_out, is_a_key_pressed);  
    end 
    
    //setup block
    initial begin
        $timeformat(-9, 1, "ns");   //formats how we display the timevalues
    end 

    //clk pulsing 
    always begin 
        #`half_cp clk = ~clk;
    end
    
    //condition checking always block
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////// 
    //main block:
        //testing procedure:
            //init signals 
            //initial reset to init all outputs
            //condition 1 check : push #1 on kpd, assert 1st column pulled down @ sclk = 21 
                //@ sclk = 29, assert decode out and is a key pressed = 0001 and 1
            //condition 2 check : col 2 pulled down and #5 pressed
                //occurs at sclk = 50
                //decode_out = 5, key pressed = 1
                
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //testing conditions:
    always @(posedge uut.sclk) begin 
        if (uut.sclk == 20'h0001E) begin   //check condition 1
            assert (decode_out == 4'h1) else $error("TEST FAILED: col 1 pull down did not toggle decode out = 0001.");
            assert (is_a_key_pressed == 1'b1) else $error("TEST FAILED: col 1 pull down did not toggle is_a_key_pressed = 1.");
        end 
        
        if (uut.sclk == 20'h00032) begin   //check condition 2
            assert (decode_out == 4'h5) else $error("TEST FAILED: col 2 pull down did not toggle decode out = 1'h5.");
            assert (is_a_key_pressed == 1'b1) else $error("TEST FAILED: col 2 pull down did not toggle is_a_key_pressed = 1.");
        end 
    end 
    
    //main
    initial begin 
        //init
        rst = 1'b0; row = 4'h0;
        
        //init rst system
        #`full_cp rst = 1'b1;
        #`full_cp rst = 1'b0;

        //button 1 pushed 
        #(50*`full_cp) row = 4'h7;  //btn #1
        #(`button_press) row = 'b0; 
        
        //wait for sys to stabilize
        #(`full_cp*40); 

        //button 7 pushed 
        row = 4'b1011;  //btn #5*/
        #(`full_cp*40); 
        
        $finish;
    end 
    
endmodule