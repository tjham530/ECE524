//time_unit: how long the delay takes in simulation
//time_precision: 
`timescale 1ns / 1ps //<time_unit> / <time_precision>


module logic_ex 
    (
        input [1:0] SW,
        output [3:0] LED
    );

//using logical operators b/c single bit
assign LED[0] = !SW[0];
assign LED[1] = SW[1] && SW[0];
assign LED[2] = SW[1] || SW[0];
assign LED[3] = SW[1] ^ SW[0]; //bitwise used here b/c no logical XNOR

endmodule 