//////////////////////////////////////////////////////////////////////////////////////////////////
//MODULE FUNCTION 
//////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module rx_unit (clk, ssi_clk, rst, sampling_clk, data_in, pos_bits_lower, 
                    pos_bits_upper, rev_bits);
    //////////////////////////////////////////////////////////////////////////////////////////////
    //SETUP
    //////////////////////////////////////////////////////////////////////////////////////////////

    //parameters (input)
    parameter FP_CLKS = 1;
    parameter RESOLUTION = 25;

    //ports 
    input logic clk, rst, ssi_clk;
    input logic sampling_clk;
    input logic data_in;
    output logic [3:0] pos_bits_lower, pos_bits_upper;
    output logic [3:0] rev_bits;

    //signals 
    typedef enum {idle, sample, tp} state_type;
    state_type state_reg, state_next;
    logic sample_done_reg, sample_done_next, tp_done;
    logic [RESOLUTION-1:0] encoder_out_reg, encoder_out_prev, encoder_out_next, encoder_out_shifted, encoder_out_prev_srl;
    integer tp_count;
    integer i_reg, i_next, data_count;
    logic data_ready;

    //////////////////////////////////////////////////////////////////////////////////////////////
    //OUTPUT HANDLING
    //////////////////////////////////////////////////////////////////////////////////////////////
//    assign pos_bits_lower = (data_ready) ? encoder_out_shifted[3:0] : encoder_out_prev_srl[3:0];
//    assign pos_bits_upper = (data_ready) ? encoder_out_shifted[7:4] : encoder_out_prev_srl[7:4];
//    assign rev_bits = (data_ready) ? encoder_out_shifted[16:13] : encoder_out_prev_srl[16:13];
    assign pos_bits_lower = encoder_out_shifted[3:0];
    assign pos_bits_upper = encoder_out_shifted[7:4];
    assign rev_bits = encoder_out_shifted[16:13];

    always_comb begin 
        encoder_out_shifted <= encoder_out_reg >> 1;
        encoder_out_prev_srl <= encoder_out_prev >> 1;
    end
    
    //////////////////////////////////////////////////////////////////////////////////////////////
    //NEXT STATE LOGIC
    //////////////////////////////////////////////////////////////////////////////////////////////
    always_comb begin 
        state_next <= state_reg;
        encoder_out_next <= encoder_out_reg;
        i_next <= i_reg;
        sample_done_next <= sample_done_reg;

        case (state_reg)
            idle : begin 
                if (!ssi_clk) begin         //first falling edge of pulse train seen 
                    state_next <= sample;
                end else begin 
                    state_next <= state_reg;
                end 
            end sample : begin              //sample data
                if (sample_done_reg) begin 
                    state_next <= tp;
                    sample_done_next <= 1'b0;
                end else begin
                    if (i_reg == RESOLUTION) begin 
                        i_next <= 1;
                        sample_done_next <= 1'b1;
                    end else begin 
                        if (sampling_clk) begin 
                            encoder_out_next[i_reg] <= data_in;
                            i_next <= i_reg + 1;
                        end else begin 
                            encoder_out_next <= encoder_out_reg;
                            i_next <= i_reg;
                        end
                    end
                end 
            end tp : begin              //avoid any falling edges of clocks
                if (tp_done) begin 
                    state_next <= idle;
                end else begin 
                    state_next <= state_reg;
                end
            end default : begin 
                state_next <= state_reg;
                encoder_out_next <= encoder_out_reg;
                i_next <= i_reg;
                sample_done_next <= sample_done_reg;
            end 
        endcase
    end 

        //////////////////////////////////////////////////////////////////////////////////////////////
        //TP STATE TIMING
        //////////////////////////////////////////////////////////////////////////////////////////////
        always_ff @(posedge clk, posedge rst) begin 
            if ((rst) || (state_reg != tp)) begin 
                tp_count <= 0;
                tp_done <= 1'b0;
            end else begin
                if (tp_count == FP_CLKS) begin 
                    tp_done <= 1'b1;
                    tp_count <= 0;
                end else begin 
                    tp_done <= 1'b0;
                    tp_count <= tp_count + 1;
                end 
            end
        end

        //////////////////////////////////////////////////////////////////////////////////////////////
        //OUTPUT TIMER
        //////////////////////////////////////////////////////////////////////////////////////////////
//        always_ff @(posedge clk, posedge rst) begin 
//            if ((rst)) begin 
//                data_count <= 0;
//                data_ready <= 1'b0;
//            end else begin
//                if (data_count == 1_000_000) begin 
//                    data_ready <= 1'b1;
//                    data_count <= 0;
//                end else begin 
//                    data_ready <= 1'b0;
//                    data_count <= data_count + 1;
//                end 
//            end
//        end

    //////////////////////////////////////////////////////////////////////////////////////////////
    //CURRENT STATE LOGIC
    //////////////////////////////////////////////////////////////////////////////////////////////
    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            state_reg <= idle;      
            encoder_out_reg <= 'b0;
            encoder_out_prev <= 'b0;
            i_reg <= 1;
            sample_done_reg <= 1'b0;
        end else begin 
            state_reg <= state_next;
            encoder_out_reg <= encoder_out_next;
            encoder_out_prev <= encoder_out_reg;
            i_reg <= i_next;
            sample_done_reg <= sample_done_next;
        end 
    end 

endmodule