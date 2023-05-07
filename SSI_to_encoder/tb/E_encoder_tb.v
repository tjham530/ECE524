`timescale 1ns/1ns
`define m " [$monitor] : %t => ssi_clk_int = %b | data_out = %b"

module E_encoder_tb();
    ///////////////////////////////////////////////////////
    //SIGNALS
    ///////////////////////////////////////////////////////
    //parameters
    localparam DEBOUNCE_CLKS = 1;     //based on go board freq
    localparam T_PROP = 1;    //number of clks to wait for prop delay of data => 0.4us
    localparam FM_CLKS = 5;   //number of clks to wait for data line period after packet transmitted => 20us
    
    //constants:
    localparam pos_down_val = 4'h1;
    localparam pos_up_val = 4'h2;
    localparam rev_down_val = 4'h4;
    localparam rev_up_val = 4'h8;
    localparam half_cp = 20;
    localparam full_cp = 40;

    //instance signals: inputs 
    reg clk = 1'b0; 
    reg rst;
    reg ssi_clk = 1'b1;
    reg [3:0] buttons;

    //instance signals: outputs
    wire data_out;
    
    //
    integer i;

    ///////////////////////////////////////////////////////
    //INSTANCES
    ///////////////////////////////////////////////////////
    encoder_top #(
        .DEBOUNCE_CLKS (DEBOUNCE_CLKS),
        .T_PROP (T_PROP), 
        .FM_CLKS (FM_CLKS)
        ) uut(
        .clk(clk),
        .zero (rst),
        .data_out (data_out),
        .ssi_clk (ssi_clk),
        .pos_down (buttons[0]),
        .pos_up (buttons[1]),
        .rev_down (buttons[2]),
        .rev_up (buttons[3])
    );
   
    ///////////////////////////////////////////////////////
    //SETUP
    ///////////////////////////////////////////////////////
    //monitor block 
    initial begin 
       $monitor(`m, $time, ssi_clk, data_out);
    end 
    
//    //setup block
//    initial begin
//        $timeformat(-9, 1, "ns");   //formats how we display the timevalues
//    end 
    
    /////////////////////////////////////////////////////////////////////////////////////
    //MAIN TESTING: 
    /////////////////////////////////////////////////////////////////////////////////////
    //clk gen  
    always begin
       #half_cp clk = ~clk;
    end  

    //ssi clk 
    always begin 
         #250;       //tcalc
         @(posedge clk);
         for (i = 0; i < 24; i = i + 1) begin 
             #half_cp ssi_clk = 1'b0;
             #half_cp ssi_clk = 1'b1;
         end 

         #100; //tm
     end 
                
        /////////////////////////////////////////////////////////////////////////////////////
        //Main Test Block
        /////////////////////////////////////////////////////////////////////////////////////
        initial begin 
            //init signals 
            rst = 1'b0; buttons = 'h0; 
            
            //sys rst:
            #full_cp rst = 1'b1;
            #full_cp rst = 1'b0;
            
            //test buttons 
//            @(uut.pt_done);
            #full_cp buttons = pos_up_val;
            #full_cp buttons = 4'h0;
            
            #1000;
            
//            @(uut.pt_done);
            #full_cp buttons = rev_up_val;
            #full_cp buttons = 4'h0;
            
            #10_000;
            
            #full_cp $finish;
        end 
endmodule 
    
 /////////////////////////////////////////////////////////////////////////////////////
 //Errors:
 /////////////////////////////////////////////////////////////////////////////////////


 /////////////////////////////////////////////////////////////////////////////////////
 //NEED TO FIX:
 /////////////////////////////////////////////////////////////////////////////////////

 /////////////////////////////////////////////////////////////////////////////////////
 //notes:
 /////////////////////////////////////////////////////////////////////////////////////













