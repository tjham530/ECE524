`timescale 1ns/1ps 

module pwm_switcher (clk, rst, duty, pwm_out);

    ////////////////////////////////////////////////////////////////////////
    //SETUP:
    ////////////////////////////////////////////////////////////////////////    
    
    //parameters:
    parameter int resolution = 8;
    parameter int dvsr = 4882;

    //ports:
    input logic clk, rst;
//    input logic [31:0] dvsr;        
    input logic [resolution:0] duty;
    output logic pwm_out;
    
    //counting ticks for pwm switching freq
    logic [31:0] p_cnt_reg;
    logic [31:0] p_cnt_next;
    logic p_tick;

    //counting duty cycle
    logic [resolution-1:0] d_cnt_reg;
    logic [resolution-1:0] d_cnt_next;

    //duty cycle count value
    logic [resolution:0] d_reg_ext;

    //pwm_out 
    logic pwm_reg;
    logic pwm_next;

    ////////////////////////////////////////////////////////////////////////
    //MAIN:
        //function:
            //count up to PWM dvsr value => gen tick
            //the duty cycle count goes up one value every tick 
            //PWM pulses when the duty count is greater than duty comp.
    ////////////////////////////////////////////////////////////////////////  
    //current state logic:
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            p_cnt_reg <= 'b0;
            d_cnt_reg <= 'b0;
            pwm_reg <= 'b0;
        end else begin
            p_cnt_reg <= p_cnt_next;
            d_cnt_reg  <= d_cnt_next;
            pwm_reg <= pwm_next;
        end
    end

    //nextstate logic 
    assign p_cnt_next = (p_cnt_reg == dvsr) ? 'b0 : p_cnt_reg + 1;      //coutner for PWM freq divider
    assign p_tick = (p_cnt_reg == 0) ? 1'b1 : 1'b0;                     //PWM freq tick 
    assign d_cnt_next = (p_tick == 1'b1) ? d_cnt_reg + 1: d_cnt_reg;      //increment duty cycle value every tick
    assign d_reg_ext = {1'b0, d_cnt_reg};

    //out logic 
    assign pwm_next = (duty > d_reg_ext) ? 1'b1 : 1'b0;     //when duty cycle reaches max, toggle PWM output to 1
    assign pwm_out = pwm_reg;

endmodule 