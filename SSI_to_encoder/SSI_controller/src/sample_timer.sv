//////////////////////////////////////////////////////////////////////////////////////////////////
//MODULE FUNCTION 
    // Used to help rx unit know when to sample in the middle of data
    //     Avoids Thl and Tlh propagation delays
    // Three States:
    //     Idle: waiting for SSI clk to go low
    //     Delay: wait 3/4 of an SSI clk pulse => middle of rising edge 
    //     Pulse => pulse just like the tx_unit, and stop after 25 pulses 
    //     Back to idle after
//////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module sample_timer (clk, ssi_clk, rst, sampling_clk);
    //////////////////////////////////////////////////////////////////////////////////////////////
    //SETUP
    //////////////////////////////////////////////////////////////////////////////////////////////

    //parameters (input)
    parameter SSI_CLKS = 4; //input clk freq to encoder => 25Mhz
    parameter RESOLUTION = 25;
    parameter RX_DLY_CLKS = 3;

    //local parameters 
    localparam HALF_CP = 2;

    //ports 
    input ssi_clk, clk, rst;
    output sampling_clk;

    //signals 
    typedef enum {idle, delay, pulse} state_type;
    state_type state_reg, state_next;
    logic sampling_clk_reg, delay_done, pulse_done;
    integer delay_count, out_timer, out_count;

    //////////////////////////////////////////////////////////////////////////////////////////////
    //OUTPUT HANDLING
    //////////////////////////////////////////////////////////////////////////////////////////////
    assign sampling_clk = (state_reg == pulse) ? sampling_clk_reg : 1'b0;

        //////////////////////////////////////////////////////////////////////////////////////////
        //SAMPLING CLK COUNTING:
            //only pulse, the length of the sys clk pusle, not ssi clk
        //////////////////////////////////////////////////////////////////////////////////////////
        always_ff @(posedge clk, posedge rst) begin 
            if ((rst) || (state_reg != pulse)) begin 
                sampling_clk_reg <= 1'b1;
                out_timer <= 1;
                out_count <= 0;
                pulse_done <= 1'b0;
            end else begin
                if (out_count != RESOLUTION) begin 
                    if (out_timer == SSI_CLKS) begin 
                        sampling_clk_reg <= ~sampling_clk_reg;
                        out_timer <= 1;
                        out_count <= out_count + 1;
                    end else begin 
                        out_timer <= out_timer + 1;
                        sampling_clk_reg <= 1'b0;
                    end 
                end else begin 
                    pulse_done <= 1'b1;
                    out_count <= 0;
                end 
            end
        end 

    //////////////////////////////////////////////////////////////////////////////////////////////
    //NEXT STATE LOGIC
    //////////////////////////////////////////////////////////////////////////////////////////////
    always_comb begin 
        state_next <= state_reg;

        case (state_reg)
            idle : begin 
                if (!ssi_clk) begin         //first falling edge of pulse train seen 
                    state_next <= delay;
                end else begin 
                    state_next <= state_reg;
                end 
            end delay :  begin              //delay to middle of CLOCK HIGH
                if (delay_done) begin 
                    state_next <= pulse;
                end else begin 
                    state_next <= state_reg;
                end 
            end pulse : begin 
                if (pulse_done) begin 
                    state_next <= idle;
                end else begin 
                    state_next <= state_reg;
                end
            end default : begin 
                state_next <= state_reg;
            end 
        endcase
    end 

        //////////////////////////////////////////////////////////////////////////////////////////////
        //DELAY TIMING
        //////////////////////////////////////////////////////////////////////////////////////////////
        always_ff @(posedge clk, posedge rst) begin 
            if ((rst) || (state_reg != delay)) begin 
                delay_count <= 1;
                delay_done <= 1'b0;
            end else begin
                if (delay_count == RX_DLY_CLKS) begin 
                    delay_done <= 1'b1;
                    delay_count <= 1;
                end else begin 
                    delay_done <= 1'b0;
                    delay_count <= delay_count + 1;
                end 
            end
        end

    //////////////////////////////////////////////////////////////////////////////////////////////
    //CURRENT STATE LOGIC
    //////////////////////////////////////////////////////////////////////////////////////////////
    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            state_reg <= idle;      
        end else begin 
            state_reg <= state_next;
        end 
    end 
endmodule