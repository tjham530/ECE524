`timescale 1ns/1ps 

module mood_pwm (clk, rst, rgb);

    ////////////////////////////////////////////////////////////////
    //SETUP
    ////////////////////////////////////////////////////////////////
    //parameters
    parameter resolution = 8;
    parameter gradient_max = 2_499_999;
    
    localparam dvsr = 4882;

    //ports 
    input logic clk, rst;
    output logic [2:0] rgb;

    //signals 
    logic [resolution:0] duty;      //n+1 bits to handle extra value for 256
    logic pwm_out_reg;
    integer grad_count;
    logic gradient_pulse;
    logic [resolution:0] duty_cnt_reg;      //count from 0 to 256 

    //state machine:
    typedef enum {one, two, three, four, five, six} state_type;    //see planning doc to know what each step does
    state_type state_reg, state_next;
    logic done_pulse;

    ////////////////////////////////////////////////////////////////
    //INSTANCE
    ////////////////////////////////////////////////////////////////

    pwm_switcher #(.resolution (resolution), .dvsr (dvsr)) switcher 
    (
        .clk (clk),
        .rst (rst),
        .duty (duty),
        .pwm_out (pwm_out_reg)
    );

    //////////////////////////////////////////////////////////////////////////////
    //MAIN: 
    //////////////////////////////////////////////////////////////////////////////
    //assign based on 6 states, and concatenate pwm_out to constants
        //0 => red
        //1 => blue
        //2 => green
    assign rgb = (state_reg == one)   ? {pwm_out_reg, 1'b0, 1'b1} : //green turning on
                 (state_reg == two)   ? {1'b1, 1'b0, pwm_out_reg} : //red turning off
                 (state_reg == three) ? {1'b1, pwm_out_reg, 1'b0} : //blue turning on
                 (state_reg == four)  ? {pwm_out_reg, 1'b1, 1'b0} : //green turning off
                 (state_reg == five)  ? {1'b0, 1'b1, pwm_out_reg} : //red turning on
                 (state_reg == six)   ? {1'b0, pwm_out_reg, 1'b1} : 3'b0 ;   //blue turning off 

    assign duty = duty_cnt_reg;

    
    ////////////////////////////////////////////////////////////////
    //STATE MACHINE: 
    ////////////////////////////////////////////////////////////////

    //current state: 
    always @(posedge clk, posedge rst) begin 
        if (rst) begin 
            state_reg <= one;
        end else begin 
            state_reg <= state_next;
        end 
    end 

    //next state:
    always_comb begin 
        state_next <= state_reg;

        case (state_reg) 
            one: begin 
                if (done_pulse) begin      //duty cycle counter outputs a pulse when the duty has counted down or up 
                    state_next <= two;
                end 
            end two: begin
                if (done_pulse) begin      //duty cycle counter outputs a pulse when the duty has counted down or up 
                    state_next <= three;
                end 
            end three: begin
                if (done_pulse) begin      //duty cycle counter outputs a pulse when the duty has counted down or up 
                    state_next <= four;
                end 
            end four: begin 
                if (done_pulse) begin      //duty cycle counter outputs a pulse when the duty has counted down or up 
                    state_next <= five;
                end 
            end five: begin
                if (done_pulse) begin      //duty cycle counter outputs a pulse when the duty has counted down or up 
                    state_next <= six;
                end 
            end six: begin
                if (done_pulse) begin      //duty cycle counter outputs a pulse when the duty has counted down or up 
                    state_next <= one;
                end 
            end default: begin 
                state_next <= state_next;
            end
        endcase
    end

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //STATE MACHINE TRANSITION TIMING / DUTY CYCLE COUNTER: 
        //based on which state we are in, the duty cycle counter will count up or down 
        //once finished counting up or down, send a pulse out that will trigger the next state of the reg
        //the duty cycle will reset based on which state is up next. Set to max or min
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge rst, posedge clk) begin 
        //duty counter
        if (rst) begin 
            grad_count <= 0;
            gradient_pulse <= 1'b0;
            duty_cnt_reg <= 'b0;        //start from 0 when starting at state 1
            done_pulse <= 1'b0;
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
                if (state_reg == one || state_reg == three || state_reg == five) begin  //turning on: increment
                    if (duty_cnt_reg == 256) begin 
                        duty_cnt_reg <= duty_cnt_reg;        //leave at max so we can count down with it
                        done_pulse <= 1'b1;
                    end else begin 
                        duty_cnt_reg <= duty_cnt_reg + 1;
                        done_pulse <= 1'b0;
                    end
                end else begin                          //turning off: decrement 
                    if (duty_cnt_reg == 0) begin 
                        duty_cnt_reg <= duty_cnt_reg;        //leave at max so we can count down with it
                        done_pulse <= 1'b1;
                    end else begin 
                        duty_cnt_reg <= duty_cnt_reg - 1;
                        done_pulse <= 1'b0;
                    end
                end 
            end else begin 
                done_pulse <= 1'b0; //turn off the done pulse after init
            end 
        end
    end

endmodule



  