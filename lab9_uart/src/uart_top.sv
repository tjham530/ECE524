`timescale 1s/1ns

module uart_top ( clk, reset, rx, r_data,  rd_uart, tx, wr_uart);
     
    //parameters
    parameter SAMPLE_TICKS = 16;        //number of samples/bit 
    parameter TX_DATA_WIDTH = 10;       //data and start/stop bits   
    parameter DVSR_BITS = 8;           //num of bits for baud gen counter
    parameter RX_DATA_WIDTH = 8;        //data only
    parameter ADDR_WIDTH = 5;           //number of words per fifo (10 default)
    parameter RX_B_BITS = RX_DATA_WIDTH;                //b = position in b register
    parameter TX_B_BITS = TX_DATA_WIDTH;                //b = position in b register
    parameter S_BITS = 5;               //s = max number of sampling ticks
    parameter N_BITS = 3;               //n = number of data bits received in data state

    //ports
    input logic clk, reset;
    input logic rx, rd_uart, wr_uart;
    output logic [RX_DATA_WIDTH-1:0] r_data;
    output tx;
    //output logic full, rx_empty, tx_full;

    //intermediate signals
    logic tick_int, rx_done_tick, full_int, tx_int, tx_full_int;
    logic rx_empty_int, tx_done_tick, empty_int, not_empty_int;
    logic [RX_DATA_WIDTH-1:0] dout_int, rx_data_int ;
    logic [TX_DATA_WIDTH-1:0] din_int, tx_r_data_int;
    
    //outputs that dont need to be mapped
    logic full;
    logic rx_empty;
    logic tx_full;
    logic [TX_DATA_WIDTH-1:0] w_data; 

    //instances
    baud_gen #(.DVSR_BITS(DVSR_BITS)) baud_gen_unit 
    (
        .*,
        .tick(tick_int)
    );

    //rx_fifo
    fifo_top #(.PACK_WIDTH(RX_DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) rx_fifo_unit 
    (
        .*, 
        .rd (rd_uart),
        .wr (rx_done_tick),
        .w_data (dout_int),
        .empty (rx_empty_int),
        .full (full_int),
        .r_data (rx_data_int)
    );

    //tx_fifo: needs 11 bits of data width 
    fifo_top #(.PACK_WIDTH(TX_DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) tx_fifo_unit 
    (
        .*, 
        .rd (tx_done_tick),
        .wr (wr_uart),
        .w_data (w_data),
        .empty (empty_int),
        .full (tx_full_int),
        .r_data (tx_r_data_int)
    );

    //tx
    uart_tx 
    #(
        .DATA_WIDTH (TX_DATA_WIDTH), 
        .SAMPLE_TICKS (SAMPLE_TICKS), 
        .B_BITS (TX_B_BITS), 
        .S_BITS (S_BITS), 
        .N_BITS (N_BITS)
    ) 
    tx_unit
    (
        .*, 
        .din (tx_r_data_int),
        .tx_start (not_empty_int),
        .s_tick (tick_int),
        .tx_done_tick (tx_done_tick),
        .tx (tx_int) 
    );

    //rx
    uart_rx 
    #(
        .DATA_WIDTH (RX_DATA_WIDTH), 
        .SAMPLE_TICKS (SAMPLE_TICKS), 
        .B_BITS (RX_B_BITS), 
        .S_BITS (S_BITS), 
        .N_BITS (N_BITS)
    ) 
    rx_unit 
    (
        .*, 
        .rx (rx),
        .s_tick (tick_int),
        .rx_done_tick (rx_done_tick),
        .dout (dout_int)
    );

    //comb assignments
    assign not_empty_int = ~empty_int;
    assign full = full_int;
    assign rx_empty = rx_empty_int;
    assign r_data = rx_data_int;
    assign tx_full = tx_full_int;
    assign tx = tx_int;
    
    assign w_data = {1'b0, rx_data_int, 1'b1};           
    
endmodule
    //parameter sys_clk_freq = 125_000_000;
    //parameter baud_rate = 115200;   
    //parameter dvsr = (baud_rate*sample_ticks);
    
