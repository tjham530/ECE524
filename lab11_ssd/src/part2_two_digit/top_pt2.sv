`timescale 1ns/1ps
module top_pt2
//#(
//    parameter SYS_CLK = 50_000_000, // system clock : 50Mhz
//    parameter COL_WAIT_TIME = 0.002,    //wait time = 2ms for kpd decoder col sampling
//    parameter DEBOUNCE_PER = 0.0005,     //kypd deboucne per = 0.5ms
//    parameter CHIP_SEL_WAIT = 0.001  //time b/w toggle = 1ms
//)
(
   input logic clk,
   input logic btn,   //btn0 used for rst
   input logic  [3:0] krow,
   output logic chip_sel,   //chip_sel bit : 0 => right , 1 => left 
   output logic [6:0] seg,
   output logic  [3:0] kcol
);
    ////////////////////////////////////////////////////////////////////////////
    //intermediate signals 
    ////////////////////////////////////////////////////////////////////////////
    logic rst;
    logic chip_sel_reg;
    logic [6:0] seg1;
    logic [6:0] seg2;
    logic is_a_key_pressed_db;
    logic is_a_key_pressed;
    integer clk_count;
    integer buf_count; 

    //localparam cs_wait = (SYS_CLK*(CHIP_SEL_WAIT));
    localparam cs_wait = (50_000); //1ms
    localparam buf_time = 50_000_000; //1s

    //fsm signals 
    typedef enum {pressed, not_pressed, release_buf} disp_type;
    disp_type keypad_reg, keypad_next;
    logic [3:0] disp_val1_reg;
    logic [3:0] disp_val1_next;
    logic [3:0] disp_val2_reg;
    logic [3:0] disp_val2_next;
    logic digit_toggle_next;
    logic digit_toggle_reg;
    logic [3:0] disp_val;
    
    ////////////////////////////////////////////////////////////////////////////
    //instances
    ////////////////////////////////////////////////////////////////////////////
    display_cntrl ssd_right (
        .disp_val (disp_val1_reg),   //disp val from kpd
        .seg_out (seg1)   //decoded value for right digit 
    );

    display_cntrl ssd_left(
        .disp_val (disp_val2_reg), //disp val from kpd 
        .seg_out (seg2)  //decoded value for left digit 
    );

    keypad_decoder 
//    #(
//        .SYS_CLK (SYS_CLK),
//        .COL_WAIT_TIME (COL_WAIT_TIME)
//    ) 
        kpd
    (
        .clk (clk), 
        .rst (rst),  
        .col (kcol),  
        .row (krow),         
        .decode_out (disp_val),  //goes to disp_ctrl
        .is_a_key_pressed (is_a_key_pressed) 
    );

    debounce 
//    #(
//        .SYS_CLK (SYS_CLK),
//        .DEBOUNCE_PER (DEBOUNCE_PER)
//    )
        debounce_kpd
    (
        .clk (clk),
        .rst (rst),
        .button (is_a_key_pressed),
        .result (is_a_key_pressed_db)
    );

    ////////////////////////////////////////////////////////////////////////////
    //combinational main
    ////////////////////////////////////////////////////////////////////////////
    assign rst = btn;
    assign chip_sel = chip_sel_reg; 
    //assign seg = seg_int;   //takes values from one of two disp controls 
    assign seg = (chip_sel_reg) ? seg2 : seg1;
    
    ////////////////////////////////////////////////////////////////////////////
    //sequential main
    ////////////////////////////////////////////////////////////////////////////    

    //current state control 
    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            keypad_reg <= not_pressed;
            disp_val1_reg <= 4'b0;
            disp_val2_reg <= 4'b0;
//            seg_int = 7'b0;
            digit_toggle_reg <= 1'b0;        //digit = right
        end else begin 
            keypad_reg <= keypad_next;
            disp_val1_reg <= disp_val1_next;
            disp_val2_reg <= disp_val2_next;
            digit_toggle_reg <= digit_toggle_next;
        end  
    end

    //nextstate control 
    always_comb begin 
        keypad_next <= keypad_reg; 
        disp_val1_next <= disp_val1_reg;
        disp_val2_next <= disp_val2_reg;
        digit_toggle_next <= digit_toggle_reg;
        
        case (keypad_reg)
            not_pressed: begin
                if (is_a_key_pressed_db) begin //wait for key to be pressed
                    keypad_next <= pressed;
                end else begin 
                    keypad_next <= not_pressed;
                end
            end 
            pressed: begin 
                if (!is_a_key_pressed_db) begin //if a button is released, go back to toggling and sel disp val
                    keypad_next <= release_buf;   
                    //check which disp value we need to change next 
                    if (digit_toggle_reg) begin //if left 
                        disp_val2_next <= disp_val; //change left
                        digit_toggle_next <= 1'b0;  //right is next
                    end else begin //if right
                        disp_val1_next <= disp_val; //change right
                        digit_toggle_next <= 1'b1;  //left is next 
                    end
                end 
            end 
            release_buf: begin 
                if (buf_count == buf_time) begin 
                    keypad_next <= not_pressed;
                end 
            end
            default: keypad_next <= not_pressed; 
        endcase
    end
    
    //buf_timer 
    always_ff @(posedge clk) begin
        if (keypad_reg !== release_buf) begin 
            buf_count <= 0;
        end else begin 
            buf_count <= buf_count + 1;
        end 
    end
    
    //control the digit toggling
    always_ff @(posedge clk, posedge rst) begin
       if (rst) begin
           chip_sel_reg <= 0;       // 0 => right 
           clk_count <= 0;
       end else begin
            clk_count <= clk_count + 1;
            if  (clk_count == cs_wait) begin
                chip_sel_reg <= ~chip_sel_reg;
                clk_count <= 0;
            end
       end
    end    

endmodule
    //steps:
        //all components (check)
        //constr (check)
        //top controller (n/a)
            //different values on displays works in sim as is
                //fpga still displays same value on both => TIMING ISSUE
                    //if i push the buttons really fast, i can get them to be different
                
        // sol: find correct debounce time. not too long, not too short
        // sol: buffer b/w states
