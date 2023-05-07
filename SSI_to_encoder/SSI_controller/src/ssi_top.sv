`timescale 1ns/1ns
////////////////////////////////////////////////////////////////////////////////////////////////////////
//TOP MODULE
////////////////////////////////////////////////////////////////////////////////////////////////////////

module ssi_top (clk, sys_rst, data, ssi_clk, zero, led, cs, seg);

    //////////////////////////////////////////////////////////////////////////////////////////////
    //SETUP
    //////////////////////////////////////////////////////////////////////////////////////////////
    //parameters (change)
    parameter SYS_CLK_FREQ = 100_000_000;   //100Mhz
    localparam SSI_CLK_FREQ = 25_000_000; // (SYS_CLK_FREQ*0.25); //input clk freq to encoder 
    localparam SSI_CLKS = 4;    //dvsr for SSI clk divider  => Sys_clk/ssi_clk
    localparam RX_DLY_CLKS = 1;    //timing to center of rising edge of ssi clk => 3/4*SSI_CLKS
    localparam HALF_CP_TX = 2; //1/2 of SSI clks
    
    //parameters (dont touch)
    parameter DEBOUNCE_CLKS = 50_000_000; //SYS_CLK_FREQ*0.5;  //0.5s
    localparam PROP_DELAY_CLKS = 40; //(SYS_CLK_FREQ*0.0000004);    //number of clks to wait for prop delay of data => 0.4us
    localparam FM_CLKS = 2000;  // (SYS_CLK_FREQ*0.00002);   //number of clks to wait for data line period after packet transmitted => 20us
    localparam FP_CLKS = 26000; //(SYS_CLK_FREQ*0.000026);   //number of clks to wait for clk period after a packet of data => 26us
    localparam CS_WAIT_CLKS = 100_000; //(SYS_CLK_FREQ*0.001); //1ms
    localparam FCALC_CLKS = 400; // (SYS_CLK_FREQ*0.000004); //number of clks to wait for wait period for clk to let encoder calc data between packets => 4us 
    localparam PBITS = 13;   //number of bits used to hold position value
    localparam RBITS = 12;   //number of bits used to count revolutions
    localparam RESOLUTION = PBITS + RBITS;
    localparam PULSE_CLKS = 1;
    localparam CODE_TYPE = 1; //1 =>> gray code | 0 => binary
    
    //inputs 
    input logic clk;
    input logic sys_rst;    //mapped to button 0
    input logic data;
    
    //outputs
    output logic ssi_clk;
    output logic zero;
    output logic [3:0] led;
    output logic [6:0] seg;   //output to SSD
    output logic cs;          //SSD chip sel

    //signals 
    logic rst;  //debounced sys reset
    logic [6:0] seg_out_lsb, seg_out_msb;
    logic chip_sel_reg;     //0 => LSB, 1 => MSB
    integer cs_count;
    logic sampling_clk;
    logic [3:0] rev_bits, ssd_right, ssd_left;
//    logic data_in_int;
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////
    //ILAs
    //////////////////////////////////////////////////////////////////////////////////////////////
    ila_0 ssi_clk_ila (.clk(clk), .probe0(ssi_clk));
    ila_0 data_ila (.clk(clk), .probe0(data));
    ila_0 zero_ila (.clk(clk), .probe0(zero));
    
    //////////////////////////////////////////////////////////////////////////////////////////////
    //INSTANCES
    //////////////////////////////////////////////////////////////////////////////////////////////

    //reset button debounce
    debounce_pulse #(
        .DEBOUNCE_PERIOD (DEBOUNCE_CLKS),
        .PULSE_PER (PULSE_CLKS)
    ) rst_button (
        .clk (clk),
        .button (sys_rst),
        .result (rst)
    );

    //tx_unit
    tx_unit #(
        .SSI_CLKS (SSI_CLKS),
        .FM_CLKS (FM_CLKS),
        .FCALC_CLKS (FCALC_CLKS),
        .RESOLUTION (RESOLUTION),
        .HALF_CP (HALF_CP_TX)
    ) ssi_tx (
        .clk (clk),
        .rst (rst),
        .ssi_clk (ssi_clk) 
    );

    //sampling timer:
    sample_timer #(
        .SSI_CLKS (SSI_CLKS),
        .RESOLUTION (RESOLUTION),
        .RX_DLY_CLKS (RX_DLY_CLKS)
    ) sample_timer_unit (
        .clk (clk),
        .ssi_clk (ssi_clk),
        .rst (rst),
        .sampling_clk (sampling_clk)
    );

    //rx_unit
    rx_unit #(
        .RESOLUTION (RESOLUTION),
        .FP_CLKS (FP_CLKS)
    ) ssi_rx (
        .clk (clk),
        .rst (rst),
        .ssi_clk (ssi_clk),
        .data_in (data),
        .sampling_clk (sampling_clk),
        .pos_bits_lower (ssd_right),
        .pos_bits_upper (ssd_left),
        .rev_bits (rev_bits)
    );
    
    //LSB 4-bits SSD controller
    display_cntrl LSB_digit 
    (
        .disp_val (ssd_right),
        .seg_out (seg_out_lsb)
    );

    //MSB 4-bits SSD controller
    display_cntrl MSB_digit 
    (
        .disp_val (ssd_left),
        .seg_out (seg_out_msb)
    );

    //////////////////////////////////////////////////////////////////////////////////////////////
    //MAIN
    //////////////////////////////////////////////////////////////////////////////////////////////

        //////////////////////////////////////////////////////////////////////////////////////////
        //DATA RECEIVING CLOCKED
            //do i need to clock data coming in from the other FPGA? 
        //////////////////////////////////////////////////////////////////////////////////////////
//        throw_error //error to remind to check if the rx_unit timing will be interrupted

//        always_ff @(posedge clk, posedge rst) begin 
//            if (rst) begin 
//                data_in_int <= 1'b0;
//            end else begin 
//                data_in_int <= data;
//            end 
//        end 
        
        //////////////////////////////////////////////////////////////////////////////////////////
        //SSD CLOCK DIVIDER
        //////////////////////////////////////////////////////////////////////////////////////////

        always_ff @(posedge clk, posedge rst) begin
            if (rst) begin
                chip_sel_reg <= 1'b0;       // 0 => right 
                cs_count <= 0;
            end else begin
                    cs_count <= cs_count + 1;
                    if  (cs_count == CS_WAIT_CLKS) begin
                        chip_sel_reg <= ~chip_sel_reg;
                        cs_count <= 0;
                    end
            end
        end

        //////////////////////////////////////////////////////////////////////////////////////////
        //ASSIGNS
        //////////////////////////////////////////////////////////////////////////////////////////
        assign seg = (chip_sel_reg) ? seg_out_msb : seg_out_lsb;
        assign led = rev_bits;
        assign cs = chip_sel_reg;
        assign zero = rst;
        
endmodule 

////////////////////////////////////////////////////////////////////////////////////////////////////////
//NOTES
////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////
//CURRENT ERRORS
////////////////////////////////////////////////////////////////////////////////////////////////////////
