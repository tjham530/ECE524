//////////////////////////////////////////////////////////////////////////////////////////////////
//MODULE FUNCTION 
    //sys clk will be input to hear 
    //unit will output a 16Mhz clk pulse train when directed
    //4 states: 
        //idle => base state when encoder zeroed
        //Tcalc wait 
        //N pulse trains 
        //Tm wait 
    //unless zeroed, sys will repeat from tcalc wait => tm wait and roll over

    //all inputs to module, aside from ssi clk, will be integers for # of clocks to count
//////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module tx_unit (clk, rst, ssi_clk);
    //////////////////////////////////////////////////////////////////////////////////////////////
    //SETUP
    //////////////////////////////////////////////////////////////////////////////////////////////

    //parameters
    parameter SSI_CLKS = 4; //input clk freq to encoder 
    parameter FM_CLKS = 25;   //number of clks to wait for data line period after packet transmitted => 20us
    parameter FCALC_CLKS = 5; //number of clks to wait for wait period for clk to let encoder calc data between packets => 4us 
    parameter HALF_CP = 2; 
    parameter RESOLUTION = 25;

    //ports 
    input clk;
    input rst;
    output ssi_clk;

    //signals 
    typedef enum {idle, tcalc, ptrain, tm} state_type;
    state_type state_reg, state_next;
    logic ssi_clk_reg;
    logic tcalc_done, tm_done, ptrain_done;
    integer tcalc_count, tm_count, out_timer, out_count;

    //////////////////////////////////////////////////////////////////////////////////////////////
    //OUTPUT HANDLING
    //////////////////////////////////////////////////////////////////////////////////////////////
    assign ssi_clk = (state_reg == ptrain) ? ssi_clk_reg : 1'b1;

        //////////////////////////////////////////////////////////////////////////////////////////
        //SSI CLK COUNTING
        //////////////////////////////////////////////////////////////////////////////////////////
        always_ff @(posedge clk, posedge rst) begin 
            if ((rst) || (state_reg != ptrain)) begin 
                ssi_clk_reg <= 1'b0;
                out_count <= 0;
                out_timer <= 1;
                ptrain_done <= 1'b0;
            end else begin
                if (out_count != RESOLUTION) begin 
                    if (out_timer == HALF_CP) begin 
                        ssi_clk_reg <= ~ssi_clk_reg;
                        out_timer <= 1;
                        if (ssi_clk_reg == 1'b0) begin 
                            out_count <= out_count + 1;
                        end 
                    end else begin 
                        out_timer <= out_timer + 1;
                    end
                end else begin 
                    out_count <= 0;
                    ptrain_done <= 1'b1;
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
                if (!rst) begin             //see falling edge, not rising edge
                    state_next <= tcalc;
                end else begin 
                    state_next <= state_reg;
                end 
            end tcalc :  begin 
                if (tcalc_done) begin 
                    state_next <= ptrain;
                end else begin 
                    state_next <= state_reg;
                end 
            end ptrain : begin 
                if (ptrain_done) begin 
                    state_next <= tm;
                end else begin 
                    state_next <= state_reg;
                end
            end tm : begin
                if (tm_done) begin 
                    state_next <= tcalc;
                end else begin 
                    state_next <= state_reg;
                end
            end default : begin 
                state_next <= state_reg;
            end 
        endcase
    end 

        //////////////////////////////////////////////////////////////////////////////////////////////
        //TCALC TIMING
        //////////////////////////////////////////////////////////////////////////////////////////////
        always_ff @(posedge clk, posedge rst) begin 
            if ((rst) || (state_reg != tcalc)) begin 
                tcalc_count <= 1;
                tcalc_done <= 1'b0;
            end else begin
                if (tcalc_count == FCALC_CLKS) begin 
                    tcalc_done <= 1'b1;
                    tcalc_count <= 0;
                end else begin 
                    tcalc_done <= 1'b0;
                    tcalc_count <= tcalc_count + 1;
                end 
            end
        end

        //////////////////////////////////////////////////////////////////////////////////////////////
        //TM TIMING
        //////////////////////////////////////////////////////////////////////////////////////////////
        always_ff @(posedge clk, posedge rst) begin 
            if ((rst) || (state_reg != tm)) begin 
                tm_count <= 1;
                tm_done <= 1'b0;
            end else begin
                if (tm_count >= FM_CLKS) begin 
                    tm_done <= 1'b1;
                    tm_count <= 0;
                end else begin 
                    tm_done <= 1'b0;
                    tm_count <= tm_count + 1;
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