`timescale 1ns/1ns

module spd (clk, input_signal, output_pulse);

    //ports 
    input clk;
    input input_signal;
    output output_pulse;

    //signals 
    reg [1:0] states;

    //main:
    always @(posedge clk) begin 
        states[0] <= input_signal;
        states[1] <= states[0];
    end

    assign output_pulse = ((~states[1]) && (states[0]));

endmodule