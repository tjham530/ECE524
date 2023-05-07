`timescale 1ns/1ps
module top_pt1
(
   input logic clk,
   input logic btn,   //btn0 used for rst
   input logic  [3:0] krow,
   output logic chip_sel,   //chip_sel bit     
   output logic [6:0] seg,
   output logic  [3:0] kcol
);
    ////////////////////////////////////////////////////////////////////////////
    //intermediate signals 
    ////////////////////////////////////////////////////////////////////////////
    logic rst;
    logic [6:0] seg_int;
    logic [3:0] disp_val_int;
    logic [3:0] kcol_int;
    
    ////////////////////////////////////////////////////////////////////////////
    //instances
    ////////////////////////////////////////////////////////////////////////////
    display_cntrl ssd_right (
        .disp_val (disp_val_int),   //disp val from kpd
        .seg_out (seg_int)   //decoded value for right digit 
    );

    keypad_decoder kpd(
        .clk (clk), 
        .rst (rst),  
        .col (kcol_int),  
        .row (krow),         
        .decode_out (disp_val_int),  //goes to disp_ctrl
        .is_a_key_pressed (is_a_key_pressed) 
    );

//    debounce debounce_kpd
//    (
//        .clk (clk),
//        .rst (rst),
//        .button (is_a_key_pressed),
//        .result (is_a_key_pressed_db)
//    );

    ////////////////////////////////////////////////////////////////////////////
    //combinational main
    ////////////////////////////////////////////////////////////////////////////
    assign rst = btn;
    assign chip_sel = 1'b0; 
    assign seg = seg_int;
    assign kcol = kcol_int;

endmodule

