`timescale  1ns/1ns

module dbn (clk, rst, button, result);
    //parameters
    parameter DEBOUNCE_PERIOD = 100;
    parameter PULSE_PER = 1;

    //ports
    input clk, button, rst;
    output result;

    //signals 
    wire detector;
    reg pulse_toggle;
    reg pulse_out;
    integer dbn_count, pulse_count;

    //instances
    spd spd_unit 
    (
        .clk (clk),
        .input_signal (button),
        .output_pulse (detector)
    );

    //main
    always @(posedge detector or posedge rst or posedge clk) begin 
        if (detector || rst) begin 
            dbn_count <= 0;
            pulse_count <= 0;
            pulse_out <= 1'b0;
            pulse_toggle <= 1'b0;
        end else begin 
            if (pulse_toggle) begin 
                if (pulse_count == PULSE_PER) begin 
                    pulse_toggle <= 1'b0;
                    pulse_out <= 1'b0;
                end else begin 
                    pulse_out <= 1'b1;
                    pulse_count <= pulse_count + 1;
                end 
            end else begin 
                if (dbn_count == DEBOUNCE_PERIOD) begin 
                    pulse_toggle <= 1'b1;
                end else begin 
                    pulse_toggle <= 1'b0;
                    dbn_count <= dbn_count + 1;
                end            
            end 
        end 
    end 

    assign result = pulse_out;

endmodule 