`timescale 1ns/1ns

////////////////////////////////////////////////////////////////////////////////////////////////
//MODULE FUNCTION:
    //BTN 3 => N, BTN 2 => S, BTN 1 => E, BTN 0 => W, 
    //RED => rgb[2], GREEN rgb[1], BLUE => rgb[0] 
    //START ENTERING  => "SS"
    //CANCEL ENTER => "EE"
    //EXIT ALARM => "WE"
    //RST => sw == 4'h1
    //lock the lock => "NN"
    //COMBO CTRL => EACH COMBO WISHING TO BE ENTERED, NEED TO PUT SW[1] HIGH, EVERYTIME
////////////////////////////////////////////////////////////////////////////////////////////////

module fsm_top (clk, n, s, e, w, sw, rst, rgb, led);

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //SETUP 
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //parameters:
    localparam SYS_CLK = 125_000_000; //Hz
    parameter DEBOUNCE_PERIOD = 100_000_000;  //desired wait time clocks for button pulse to arrive => 500ms
    parameter PULSE_PER = 1; //how many clock periods the button will be active for
    parameter RED_PULSE = 62_500_000;

    //constants:
    localparam N = 4'h8;
    localparam S = 4'h4;
    localparam E = 4'h2;
    localparam W = 4'h1;
    localparam PASSCODE = 16'h1214;    //enter the right most digit first, then go left
    localparam INP_CODE = 8'h44;     
    localparam ALARM_CODE = 8'h21;
    localparam CANCEL_CODE = 8'h22;
    localparam LOCK_CODE = 8'h88;
    
    //ports 
    input logic clk;
    input logic sw, rst;
    input logic n,s,e,w;
    output logic [2:0] rgb;
    output logic [3:0] led;

    //state machine signals 
    typedef enum {idle, alarm, unlocked, inp, inp_combo} state_type;
    state_type state_reg, state_next;
    logic [7:0] combo_next, combo_reg;      //combo passed to mealy controller
    logic combo_control;    //reception signal of the sw[1] 
    logic digit_ctrl_reg, digit_ctrl_next;   //controls which combo digit we are entering
    logic [15:0] passcode_reg, passcode_next;      //holds users entered passcode
    logic check_ready_reg, check_ready_next;      //tells mealy controller passcode is entered

    //instance signals:
    logic [3:0] button_out;

    //top signals
    logic red_reg;
    integer rgb_counter;        //holds the count for clock division on alarm
    logic [1:0] key_control_next, key_control_reg;

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //COMBINATIONAL CODE:
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // assign combo_control = sw[1];   //if wishing to input a combo, sw 2 goes high 
    assign led[3] = ((state_reg == alarm) || (state_reg == inp_combo)) ? 1'b1 : 1'b0;
    assign led[2] = ((state_reg == unlocked) || (state_reg == inp_combo)) ? 1'b1 : 1'b0;
    assign led[1] = ((state_reg == inp) || (state_reg == inp_combo)) ? 1'b1 : 1'b0;
    assign led[0] = ((state_reg == idle) || (state_reg == inp_combo)) ? 1'b1 : 1'b0;
    
    assign rgb[0] = ((state_reg == inp) || (state_reg == inp_combo)) ? 1'b1 : 1'b0;  //blue
    assign rgb[1] = ((state_reg == unlocked) || (state_reg == inp_combo)) ? 1'b1 : 1'b0;   //green
    assign rgb[2] = (state_reg == idle) ? 1'b1 :      //red
                   (state_reg == alarm) ? red_reg : 1'b0;

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //STATE MACHINE:
    ////////////////////////////////////////////////////////////////////////////////////////////////
        
        ////////////////////////////////////////////////////////////////////////////////////////////////
        //OUTPUT CONTROL :
        ////////////////////////////////////////////////////////////////////////////////////////////////
     
        //RED RGB CLK DIVIDER
        always @(posedge clk, posedge rst) begin 
            if (rst) begin 
                rgb_counter <= 0;
                red_reg <= 1'b1;
            end else begin  //state = alarm 
                if (rgb_counter == RED_PULSE) begin 
                    rgb_counter <= 0;
                    red_reg <= ~red_reg;      //turn on and off red RGB
                end else begin 
                    rgb_counter <= rgb_counter + 1;
                end
            end
        end 

        ////////////////////////////////////////////////////////////////////////////////////////////////
        //NEXT STATE LOGIC
        ////////////////////////////////////////////////////////////////////////////////////////////////
        always_comb begin 
            state_next <= state_reg;
            digit_ctrl_next <= digit_ctrl_reg;
            combo_next <= combo_reg;
            passcode_next <= passcode_reg;
            key_control_next <= key_control_reg;
            check_ready_next <= check_ready_reg;

            case (state_reg) 
                idle: begin 
                    if (combo_control) begin   //combo => inp_code
                        state_next <= inp_combo;
                    end else begin
                        state_next <= state_reg;
                    end  
                end inp: begin 
                    if (combo_control) begin            //cancel code
                        state_next <= inp_combo;
                    end else if (check_ready_reg) begin     //passcode to nextstate
                        if (passcode_reg == PASSCODE) begin 
                            state_next <= unlocked;
                        end else begin 
                            state_next <= alarm;
                        end
                        passcode_next <= 'b0;  
                        check_ready_next <= 1'b0; 
                    end else begin                  //read in passcode
                        if (button_out != 'b0) begin 
                            if (key_control_reg == 2'b00) begin 
                                key_control_next <= 2'b01;
                                passcode_next[3:0] <= button_out;
                            end else if (key_control_reg == 2'b01) begin 
                                key_control_next <= 2'b10;
                                passcode_next[7:4] <= button_out;
                            end else if (key_control_reg == 2'b10) begin 
                                key_control_next <= 2'b11;
                                passcode_next[11:8] <= button_out;
                            end else begin 
                                key_control_next <= 2'b00;
                                passcode_next[15:12] <= button_out;
                                check_ready_next <= 1'b1;
                            end
                        end else begin 
                            key_control_next <= key_control_reg;
                            passcode_next <= passcode_reg;
                        end
                    end 
                end unlocked : begin 
                    if (combo_control) begin   //combo => LOCK_CODE
                        state_next <= inp_combo;
                    end else begin
                        state_next <= state_reg;
                    end  
                end alarm : begin 
                    if (combo_control) begin   //combo => ALARM_CODE
                        state_next <= inp_combo;
                    end else begin
                        state_next <= state_reg;
                    end  
                end inp_combo: begin
                    if ((combo_reg[7:4] != 'b0) && (combo_reg[3:0] != 'b0)) begin   //nextstate
                        case (combo_reg) 
                            INP_CODE : begin    
                                state_next <= inp;
                            end ALARM_CODE : begin 
                                state_next <= idle;
                            end LOCK_CODE : begin 
                                state_next <= idle;
                            end CANCEL_CODE : begin 
                                state_next <= idle;
                            end default: begin 
                                state_next <= state_reg;
                            end 
                        endcase
                    combo_next <= 'b0;  
                    end else begin          //read in combo    
                        if ((button_out != 'b0) ) begin 
                            if (!digit_ctrl_reg) begin 
                                digit_ctrl_next <= 1'b1;
                                combo_next[3:0] <= button_out;
                            end else begin 
                                digit_ctrl_next <= 1'b0;
                                combo_next[7:4] <= button_out;
                            end
                        end else begin 
                            combo_next <= combo_reg;
                            digit_ctrl_next <= digit_ctrl_reg;
                        end 
                    end 
                end default : begin 
                    state_next <= state_reg;
                    digit_ctrl_next <= digit_ctrl_reg;
                    combo_next <= combo_reg;
                    passcode_next <= passcode_reg;
                    key_control_next <= key_control_reg;
                    check_ready_next <= check_ready_reg;
                end
            endcase
        end 

        ////////////////////////////////////////////////////////////////////////////////////////////////
        //CURRENT STATE LOGIC
        ////////////////////////////////////////////////////////////////////////////////////////////////
        always @(posedge clk, posedge rst) begin 
            if (rst) begin 
                state_reg <= idle;
                digit_ctrl_reg <= 'b0;
                combo_reg <= 'b0;
                passcode_reg <= 'b0;
                key_control_reg <= 'b0;
                check_ready_reg <= 'b0;
            end else begin
                digit_ctrl_reg <= digit_ctrl_next;
                state_reg <= state_next;
                combo_reg <= combo_next;
                passcode_reg <= passcode_next;
                key_control_reg <= key_control_next;
                check_ready_reg <= check_ready_next;
            end 
        end

     ////////////////////////////////////////////////////////////////////////////////////////////////
    //INSTANCES 
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //single pulse debounce: all four buttons
    debounce_pulse #( 
        .DEBOUNCE_PERIOD (DEBOUNCE_PERIOD),
        .PULSE_PER (PULSE_PER)
    ) north (
        .clk (clk),
        .rst (rst), 
        .button (n),
        .result (button_out[3])
    );

    debounce_pulse #( 
        .DEBOUNCE_PERIOD (DEBOUNCE_PERIOD),
        .PULSE_PER (PULSE_PER)
    ) south (
        .clk (clk),
        .rst (rst), 
        .button (s),
        .result (button_out[2])
    );

    debounce_pulse #( 
        .DEBOUNCE_PERIOD (DEBOUNCE_PERIOD),
        .PULSE_PER (PULSE_PER)
    ) east (
        .clk (clk),
        .rst (rst), 
        .button (e),
        .result (button_out[1])
    );

    debounce_pulse #( 
        .DEBOUNCE_PERIOD (DEBOUNCE_PERIOD),
        .PULSE_PER (PULSE_PER)
    ) west (
        .clk (clk),
        .rst (rst), 
        .button (w),
        .result (button_out[0])
    );

    //sw1 dbn pulse 
    debounce_pulse #( 
        .DEBOUNCE_PERIOD (DEBOUNCE_PERIOD),
        .PULSE_PER (PULSE_PER)
    ) combo_control_unit (
        .clk (clk),
        .rst (rst), 
        .button (sw),
        .result (combo_control)
    );

endmodule 


////////////////////////////////////////////////////////////////////////////////////////////////
//TO DO
////////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////
//ERRORS
////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////
//NOTES
////////////////////////////////////////////////////////////////////////////////////////////////
//in SV there are no variables 
    //we controll execution with BA or NBA
    //BA's can be used for instant update variables

//alternative to separate output control: have it all in the same always block

//expecting design flaw with RGBs and not keeping the states output values
    ///could fix with prev state, but no time