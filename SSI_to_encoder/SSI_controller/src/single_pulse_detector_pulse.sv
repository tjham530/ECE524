`timescale 1ns/1ns

module single_pulse_detector_pulse (clk, input_signal, output_pulse);

    //ports 
    input logic clk;
    input logic input_signal;
    output logic output_pulse;

    //signals 
    logic [1:0] states;

    //main:
    always_ff @(posedge clk) begin 
        states[0] <= input_signal;
        states[1] <= states[0];
    end

    assign output_pulse = ((~states[1]) && (states[0]));

endmodule