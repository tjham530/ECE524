`timescale 1ns/1ns
`define  m1 " [$monitor: master]  : %t =>  led = %b | seg = %b | cs = %b"
`define m3 " [$monitor: int signals] : %t => data_int = %b | ssi_clk_int = %b | zero_int = %b"

module E_controller_tb();
    ///////////////////////////////////////////////////////
    //SIGNALS
    ///////////////////////////////////////////////////////
    //parameters (change)
    localparam SYS_CLK_FREQ = 100_000_000;
    localparam DEBOUNCE_CLKS = 10;

    //constants 
    localparam full_cp =  10;
    localparam half_cp =  5;
    localparam half_cp_d2 =  20;

    //instance signals: inputs
    logic clk = 1'b0;
    logic rst;    
    logic data_in; 
    
    //instance signals: outputs    
    logic [3:0] led;
    logic [6:0] seg;   //output to SSD
    logic cs;          //SSD chip sel
    logic ssi_clk, zero;

    //tb signals:            
    integer time1;
    integer time2;
    logic [24:0] data_val = 25'b0000_0000_0101_0_0000_0101_0101;
    integer i = 0;
    logic ssi_clk_int;
    logic clk_d2 = 1'b0;

    ///////////////////////////////////////////////////////
    //INSTANCES
    ///////////////////////////////////////////////////////
    ssi_top #(
        .SYS_CLK_FREQ (SYS_CLK_FREQ),
        .DEBOUNCE_CLKS (DEBOUNCE_CLKS)     
    ) uut(
        .clk(clk),
        .sys_rst(rst),
        .data (data_in),
        .ssi_clk (ssi_clk),
        .zero (zero), 
        .led (led),
        .seg (seg),
        .cs (cs)
    );
  
    ///////////////////////////////////////////////////////
    //SETUP
    ///////////////////////////////////////////////////////
    //monitor block 
//    initial begin 
//        $monitor(`m1, $time, led, seg, cs);  
//        $monitor(`m3, $time, data_int, ssi_clk_int, zero_int);
//    end 
    
    //setup block
    initial begin
        $timeformat(-9, 1, "ns");   //formats how we display the timevalues
    end 
    
    /////////////////////////////////////////////////////////////////////////////////////
    //MAIN TESTING: 
    /////////////////////////////////////////////////////////////////////////////////////
    //master clk gen  
    always begin
       #half_cp clk = ~clk;
    end   
    
//    //init slave clk at rising edge of main clk 
//    initial begin 
//        @(posedge clk) clk_d2 = ;
       
//    end 
    
    
    // //slave clock gen
    // always begin 
    //    #half_cp_d2 clk_d2 = ~clk_d2;
    // end 
                
        /////////////////////////////////////////////////////////////////////////////////////////////////////////
        //Main Test Block:
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        initial begin 
            //////////////////////////////////////////////////////////////////////////////////////////////////////
            //EXHAUSTIVE:
                //test to see if we can send clocks, and time the data_in with a delayed reg, 
                //see if delayed received data is correct
                    //then check seg and led
            //////////////////////////////////////////////////////////////////////////////////////////////////////
            //init signals 
            rst = 1'b0;

            //system reset:
            #full_cp rst = 1'b1;
            #full_cp rst = 1'b0;

            //test 1 :
            @(tx_unit.tm_done);     //first pulse train done
            if (uut.ssd_right != 4'b0101) begin 
                $display("TEST 1 FAILED: LSB of SSD did not receive correct pos bits. SSD_R = %b", uut.ssd_right);
                $stop;
            end 
            
            //test 2: 
            #full_cp;
            if (uut.ssd_left != 4'b0101) begin 
                $display("TEST 2 FAILED: MSB of SSD did not receive correct pos bits. SSD_L = %b", uut.ssd_left);
                $stop;
            end 
            
            //test 3: 
            #full_cp;
            if (led != 4'b0101) begin 
                $display("TEST 3 FAILED: leds did not receive correct rev bits. Leds = %b", led);
                $stop;
            end 
                       
            #full_cp $display("EXHAUTIVE SIMULATION COMPLETE. ALL TESTS PASSED");
            #full_cp $finish;

        end 
            
        // /////////////////////////////////////////////////////////////////////////////////////////////////////////
        // //CLOCK-INT Block: register that sycns data when entering encoder
        // //////////////////////////////////////////////////////////////////////////////////////////////////////////
         always_ff @(posedge ssi_clk, negedge ssi_clk, posedge rst) begin     //Go board clk = 25Mhz receiving
             if (rst) begin 
                 ssi_clk_int <= 1'b1;       //line kept high until receiving clk
             end else begin 
                 ssi_clk_int <= ssi_clk;
             end 
         end 

        // /////////////////////////////////////////////////////////////////////////////////////////////////////////
        // //DATA-INT TRIGGERED BLOCK: clock received by encoder and passing data
        // //////////////////////////////////////////////////////////////////////////////////////////////////////////
         always_ff @(posedge ssi_clk_int, posedge rst) begin 
             if (rst) begin 
                 data_in <= 1'b1;
                 i <= 0;
             end else begin 
                 if (i == 25) begin
                     i <= 0;
                 end else begin 
                     data_in <= data_val[i];
                     i <= i + 1;
                 end 
             end 
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