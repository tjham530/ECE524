`timescale 1ns / 1ps

//module function:
module top(clk, sw, servo_pwm, btn0, rgb);

    //parameters 
    parameter resolution = 8;
    parameter gradient_max = 2_499_999; //50hz value for pts 1 and 2
    
    //localparam
    localparam PWM_freq = 100;  //100hz
    localparam SYS_freq = 125_000_000; //125Mhz
    localparam min_pulse_us = 1000; //1ms
    localparam max_pulse_us = 2000; //2ms
    localparam step_count = 2**resolution;  //different speeds from range 2ms-1ms. 

    //ports 
    input clk;
    input logic [3:0] sw;
    input logic btn0;
    output logic [2:0] rgb;
    output logic servo_pwm;

    //RGB int signals 
    logic [2:0] linear_rgb, sine_rgb, mood_rgb;

    //signals 
    logic s1_next, s1_reg;
    logic s2_next, s2_reg;
    logic s3_next, s3_reg;
    logic s4_next, s4_reg;
    logic servo_out;
    logic [resolution-1:0] position;

    //instances 
        //linear pwm
        linear_pwm #(
            .resolution (resolution),
            .gradient_max (gradient_max)
        ) pt1_unit (
            .clk (clk),
            .rst (rst),
            .rgb (linear_rgb)
        );
        
        //sine pwm 
        sine_pwm #(
            .resolution (resolution),
            .gradient_max (gradient_max),
            .step_count (step_count)
        ) pt2_unit (
            .clk (clk),
            .rst (rst),
            .position (position),
            .rgb (sine_rgb)
        );

        //servo ctrl
        servo_pwm #(
            .clk_hz (SYS_freq),
            .pulse_hz (PWM_freq),       //PWM freq
            .min_pulse_us (min_pulse_us),
            .max_pulse_us (max_pulse_us),
            .step_count (step_count)
        ) pt3_unit (
            .clk (clk),
            .rst (rst),
            .position (position),
            .pwm (servo_out)
        );
        
        //RGB mood lighting
        mood_pwm #(
            .resolution (resolution),
            .gradient_max (gradient_max)
        ) pt4_unit (
            .clk (clk),
            .rst (rst),
            .rgb (mood_rgb)
        );
        
    //////////////////////////////////////////////////////////////////////////////////
    //OUTPUT CTRL
    //////////////////////////////////////////////////////////////////////////////////
    assign rgb = (s1_reg) ?  linear_rgb : 
                 (s2_reg) ?  sine_rgb :
                 (s4_reg) ?  mood_rgb : 3'b000;
    
    assign servo_pwm = (s3_reg) ? servo_out : 1'b0;
    
    assign rst = btn0;

    //////////////////////////////////////////////////////////////////////////////////
    //STATE MACHINE
    //////////////////////////////////////////////////////////////////////////////////
    assign s1_next = (sw == 4'h1) ? 1'b1 : 1'b0; 
    assign s2_next = (sw == 4'h2) ? 1'b1 : 1'b0; 
    assign s3_next = (sw == 4'h3) ? 1'b1 : 1'b0; 
    assign s4_next = (sw == 4'h4) ? 1'b1 : 1'b0; 

    always @(posedge clk, posedge rst) begin 
        if (rst) begin 
            s1_reg <= 1'b0;
            s2_reg <= 1'b0;
            s3_reg <= 1'b0;
            s4_reg <= 1'b0;
        end else begin 
            s1_reg <= s1_next;
            s2_reg <= s2_next;
            s3_reg <= s3_next;
            s4_reg <= s4_next;
        end  
    end 
    
endmodule

//////////////////////////////////////////////////////////////////////////////////
//TO DO 
//////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
//NOTES
//////////////////////////////////////////////////////////////////////////////////
//part 1 confirmed working on sim and board
//part 2 confirmed working on sim and board
//part 3 confirmed working on sim and board
//part 4 confirmed working on sim and board



















