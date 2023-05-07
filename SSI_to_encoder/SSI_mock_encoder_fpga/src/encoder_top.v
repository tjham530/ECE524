//`timescale 1ns/1ns

module encoder_top (clk, zero, data_out, ssi_clk, pos_up, pos_down, rev_up, rev_down);
//    //////////////////////////////////////////////////////////////////////////////////////////////////
//    //SETUP
//    //////////////////////////////////////////////////////////////////////////////////////////////////
    
        //parameters (adjust)
        localparam GO_BOARD_FREQ =  25_000_000; //max freq: 25MHz 
        localparam PULSE_CLKS = 1;
        localparam RESOLUTION = 25;
        
        //parameters (dont adjust)
        parameter DEBOUNCE_CLKS = 12_500_000;     //based on go board freq
        parameter T_PROP = 10;    //number of clks to wait for prop delay of data => 0.4us
        parameter FM_CLKS = 2000;   //number of clks to wait for data line period after packet transmitted => 20us

        //constants: states
        localparam idle = 2'b00;
        localparam pd_rise = 2'b01;
        localparam pass_data = 2'b10;
        localparam low = 2'b11;

        //ports
        input clk, zero, ssi_clk;
        input pos_up, pos_down;
        input rev_down, rev_up;
        output data_out;

        //signals 
        wire [3:0] button_out;
        reg [RESOLUTION-1:0] encoder_data_reg;
        wire [RESOLUTION-1:0] encoder_data_next;
        reg [1:0] state_reg;
        wire [1:0] state_next; // 0 => idle, 1 => prop_delay rise, 2=> pulse data bit, 3 =>  prop delay fall, 4 => line low
        reg ssi_clk_reg, prop_done;
        integer prop_count, low_count;
        reg data_reg, low_done;
        integer pulse_count;
        reg pt_done;
     
     //////////////////////////////////////////////////////////////////////////////////////////////////
     //MAIN
     //////////////////////////////////////////////////////////////////////////////////////////////////
        assign data_out = data_reg;
        
        //////////////////////////////////////////////////////////////////////////////////////////////
        //INPUT CLOCK RECEIVING:
            //NEED TO CLOCK THE INPUT WITH RESPECT TO THE CLOCK ON THE GO BOARD??
            //use reg to deal with clock domain crossing
        //////////////////////////////////////////////////////////////////////////////////////////////
        // always @(posedge clk or posedge zero) begin 
        //     if (zero) begin 
        //         ssi_clk_reg <= 1'b1;    //set high until we get input value
        //     end else begin 
        //         ssi_clk_reg <= ssi_clk;
        //     end 
        // end 

        // always @(negedge ssi_clk or posedge zero) begin 
        //     if (zero) begin 
        //         ssi_clk_reg <= 1'b1;    //set high until we get input value
        //     end else begin 
        //         ssi_clk_reg <= ssi_clk;
        //     end 
        // end 

        //////////////////////////////////////////////////////////////////////////////////////////////
        //DATA UPDATE CONTROL
        //////////////////////////////////////////////////////////////////////////////////////////////
        //current state
        always @(posedge clk or posedge zero) begin 
            if (zero) begin 
                encoder_data_reg <= 25'h1_555_555;
            end else begin 
//                if (state_reg != pass_data) begin               //only update when out of data pass
                    encoder_data_reg <= encoder_data_next;
//                end 
            end 
        end 

        //nextstate
        assign encoder_data_next = (button_out[0]) ? (encoder_data_reg[12:0] + 10) :
                                   (button_out[1]) ? (encoder_data_reg[12:0] + 10) :
                                   (button_out[2]) ? (encoder_data_reg[24:13] + 1) :
                                   (button_out[3]) ? (encoder_data_reg[24:13] + 1) : encoder_data_reg;

        
        //////////////////////////////////////////////////////////////////////////////////////////////
        //DATA OUTPUT CONTROL
        //////////////////////////////////////////////////////////////////////////////////////////////
            //////////////////////////////////////////////////////////////////////////////////////////
            //NEXT STATE
            //////////////////////////////////////////////////////////////////////////////////////////
            assign state_next = ((ssi_clk_reg) && state_reg == idle)  ? pd_rise   : 
                                ((prop_done) && state_reg == pd_rise) ? pass_data :
                                ((pt_done) && state_reg == pass_data) ? low       :
                                ((low_done) && state_reg == low) ? idle           :  state_reg  ;

                
                //////////////////////////////////////////////////////////////////////////////////////
                //PULSE TRAIN && data_reg ctrl
                //////////////////////////////////////////////////////////////////////////////////////
                always @(posedge clk or posedge zero) begin
                    if ((zero) || (state_reg != pass_data) && (state_reg != low)) begin 
                        pulse_count <= 0;
                        pt_done <= 1'b0;
                        data_reg <= 1'b0;
                    end else begin
                        if ((state_reg == pass_data) && (ssi_clk)) begin 
                            if (pulse_count == RESOLUTION) begin 
                                pulse_count <= 1'b1;
                                pt_done <= 1'b1;
                                data_reg <= 1'b0;
                            end else begin 
                                data_reg <= encoder_data_reg[pulse_count];
                                pulse_count <= pulse_count + 1;
                                pt_done <= 1'b0;
                            end 
                        end else begin 
                            data_reg <= 1'b0;
                        end 
                    end 
                end 
                
                //////////////////////////////////////////////////////////////////////////////////////
                //PROP DELAY TIMING CONTROL
                //////////////////////////////////////////////////////////////////////////////////////
                always @(posedge clk or posedge zero) begin 
                    if ((zero) || (state_reg != pd_rise)) begin 
                        prop_count <= 1;
                        prop_done <= 1'b0;
                    end else begin
                        if (prop_count == T_PROP) begin 
                            prop_done <= 1'b1;
                            prop_count <= 1;
                        end else begin 
                            prop_done <= 1'b0;
                            prop_count <= prop_count + 1;
                        end 
                    end
                end 
                
                //////////////////////////////////////////////////////////////////////////////////////
                //TP TIMING CONTROL
                //////////////////////////////////////////////////////////////////////////////////////
                always @(posedge clk or posedge zero) begin 
                    if ((zero) || (state_reg != low)) begin 
                        low_count <= 1;
                        low_done <= 1'b0;
                    end else begin
                        if (low_count == FM_CLKS) begin 
                            low_done <= 1'b1;
                            low_count <= 1;
                        end else begin 
                            low_done <= 1'b0;
                            low_count <= low_count + 1;
                        end 
                    end
                end 

             //////////////////////////////////////////////////////////////////////////////////////////
            //CURRENT STATE
            //////////////////////////////////////////////////////////////////////////////////////////
            always @(posedge clk or posedge zero) begin 
                if (zero) begin 
                    state_reg <= 'b0;       
                end else begin 
                    state_reg <= state_next;
                end 
            end 

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //INSTANCES
    //////////////////////////////////////////////////////////////////////////////////////////////////
    
        //btn0 
        dbn #(
            .DEBOUNCE_PERIOD (DEBOUNCE_CLKS),
            .PULSE_PER (PULSE_CLKS)
        ) btn0 (
            .clk (clk),
            .rst (zero),
            .button (pos_up),
            .result (button_out[0])
        );

        //btn1
        dbn #(
            .DEBOUNCE_PERIOD (DEBOUNCE_CLKS),
            .PULSE_PER (PULSE_CLKS)
        ) btn1 (
            .clk (clk),
            .rst (zero),
            .button (pos_down),
            .result (button_out[1])
        );

        //btn2
        dbn #(
            .DEBOUNCE_PERIOD (DEBOUNCE_CLKS),
            .PULSE_PER (PULSE_CLKS)
        ) btn2 (
            .clk (clk),
            .rst (zero),
            .button (rev_up),
            .result (button_out[2])
        );

        //btn3
        dbn #(
            .DEBOUNCE_PERIOD (DEBOUNCE_CLKS),
            .PULSE_PER (PULSE_CLKS)
        ) btn3 (
            .clk (clk),
            .rst (zero),
            .button (rev_down),
            .result (button_out[3])
        );

endmodule