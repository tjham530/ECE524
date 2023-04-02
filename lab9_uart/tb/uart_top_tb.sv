`timescale 1ns/1ps     

`define m1 "   [$monitor]  : %t => r_data = %b | tx = %b "
`define half_cp 4                    //1/(2* sys clk) => 4ns
`define full_cp 8                    //1/(125MHz) => 8ns
`define tick_rate (`full_cp*67)      //1 tick/ 67 clocks
`define bit_rate 8681                //(1/115200) = 8.68us [set baud rate as rx transmission rate]              //(1/115200) = 8.68 [set baud rate as rx transmission rate]

module uart_top_tb ();
    //constants for the parameter def 
    localparam SAMPLE_TICKS = 16;  
    localparam TX_DATA_WIDTH = 10;      
    localparam [TX_DATA_WIDTH-1:0] DVSR_COUNT = 8'h43;    
    localparam DVSR_BITS = 10;           
    localparam RX_DATA_WIDTH = 8;          
    localparam ADDR_WIDTH = 5;           
    localparam RX_B_BITS = RX_DATA_WIDTH;                
    localparam TX_B_BITS = TX_DATA_WIDTH;               
    localparam S_BITS = 5;              
    localparam N_BITS = 3;       

    //instance 1 signals 
    logic clk, reset;
    logic rx, rd_uart, wr_uart = 1'b0;
    logic [RX_DATA_WIDTH-1:0] r_data;
    logic tx;
    
    //instance
    uart_top 
    #(
        .SAMPLE_TICKS (SAMPLE_TICKS),
        .DVSR_BITS (DVSR_BITS),
        .RX_DATA_WIDTH (RX_DATA_WIDTH),
        .TX_DATA_WIDTH (TX_DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .RX_B_BITS (RX_B_BITS),
        .TX_B_BITS (TX_B_BITS),
        .S_BITS (S_BITS),
        .N_BITS (N_BITS)
    )
    uut 
    (
        .*
    );
    
    //clk init
    initial begin
        clk = 1'b0;
    end 
  
     //monitor block 
    initial begin 
        $monitor(`m1, $time, r_data, tx);    
    end 

    //setup block
    initial begin
        $timeformat(-9, 1, "ns");   //formats how we display the timevalues
        #(1000*`bit_rate) $finish;    //kill sim after 500 clock pulses 
    end 

    //clk 
    always begin 
        #`half_cp clk = ~clk; 
    end
    
    always begin //constatnly send 8 bit data
        #`bit_rate rx = 1'b0; 
        #`bit_rate rx = 1'b1;       //wait baud rate, then send 1st data bit 
        #`bit_rate rx = 1'b1;       //2nd data bit
        #`bit_rate rx = 1'b0;       //3rd data bit
        #`bit_rate rx = 1'b0;       //4th data bit
        #`bit_rate rx = 1'b1;
        #`bit_rate rx = 1'b1;
        #`bit_rate rx = 1'b0;  
        #`bit_rate rx = 1'b0;       //8th data bit 
        #`bit_rate rx = 1'b1;       //stop bit
    end 
    
    //main block 
    initial begin 
        //init
        reset = 1'b1; rd_uart = 1'b0; rx = 1'b1;
        wr_uart = 1'b0; 
        
        ////////////////////////////////////////////////////////////////////////
        //Test RX
        ////////////////////////////////////////////////////////////////////////
        //reset:
        #(`full_cp*5) reset = 1'b0;
      
        //read from fifo to see if transmitted
        #(`bit_rate*20) rd_uart = 1'b1;  wr_uart = 1'b1;   //set rd line high and read first num
        #(`bit_rate*20) rd_uart = 1'b0;  wr_uart = 1'b0;   
        #(`bit_rate*20) rd_uart = 1'b1;  wr_uart = 1'b1; 
        #(`bit_rate*20) rd_uart = 1'b0;  wr_uart = 1'b0;    
        ////////////////////////////////////////////////////////////////////////
        //Test TX
        ////////////////////////////////////////////////////////////////////////
//        //reset:
//        #`full_cp reset = 1'b1;
//        #`full_cp reset = 1'b0;
        
        //write data to the tx_fifo
//        #`full_cp wr_uart = 1'b1;
    end 
        
endmodule

    //notes:
        //rd line needs to go low to high for each read to go on. 