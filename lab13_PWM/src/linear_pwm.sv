`timescale 1ns/1ps

/*Module Function: 
    this module will act as an LED dimmer. The transitions between different duty
    cycles will step by 1 throughout the system. Thus, making it a linear PWM */ 

module linear_pwm (clk, rst, rgb);

    ////////////////////////////////////////////////////////////////////////
    //SETUP:
    ////////////////////////////////////////////////////////////////////////    
    //parameters:
    parameter int resolution = 8;
    parameter int gradient_max = 2_499_999;     //50Hz

    localparam int dvsr = 4882;
//
    //ports
    input logic clk, rst;
    output logic [2:0] rgb;

    //signals 
    logic [resolution:0] duty;      //n+1 bits to handle extra value for 256
    // logic [31:0] dvsr = 4882;  //sysclk divider => PWM clk
    logic pwm_out;
    integer grad_count;
    logic gradient_pulse;
    logic [resolution:0] duty_cnt_reg;      //count from 0 to 256 

    ////////////////////////////////////////////////////////////////////////
    //INSTANCING 
    ////////////////////////////////////////////////////////////////////////    
   
    //instance
    pwm_switcher #(.resolution(resolution), .dvsr (dvsr)) p_i0
    (
        .clk (clk),
        .rst (rst),
        // .dvsr (dvsr),   //sending dvsr in
        .duty (duty),   //sending duty in to compare with
        .pwm_out (pwm_out)
    );

    ////////////////////////////////////////////////////////////////////////
    //MAIN:
    ////////////////////////////////////////////////////////////////////////    
   
    //LED out
    assign rgb[0] = pwm_out; //send to red-rgb
    assign rgb[1] = 1'b0;
    assign rgb[2] = 1'b0;
    
    //duty_reg to duty
    assign duty = duty_cnt_reg;

    //duty cycle counter
    always_ff @(posedge rst, posedge clk) begin 
        //duty counter
        if (rst) begin 
            grad_count <= 0;
            gradient_pulse <= 1'b0;
            duty_cnt_reg <= 'b0;
        end else begin 
            if (grad_count < gradient_max) begin
                grad_count <= grad_count +1 ;
                gradient_pulse <= 0;
            end else begin 
                grad_count <= 0;
                gradient_pulse <= 1;
            end

            //inc duty after gradient pulse
            if (gradient_pulse == 1) begin 
                duty_cnt_reg <= duty_cnt_reg + 1;
            end 

            //duty roll over
            if (duty_cnt_reg == 256) begin
                duty_cnt_reg <= 0; 
            end    
        end
    end

endmodule 