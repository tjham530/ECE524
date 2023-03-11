`timescale 1ns / 1ps
module full_adder_tb();

reg x_tb;
reg y_tb;
wire sum_tb;
reg carry_in_tb;
wire carry_out_tb;
reg clk_tb;

full_adder uui (
   .x(x_tb),
   .y(y_tb),
   .sum(sum_tb),
   .carry_in(carry_in_tb),
   .carry_out(carry_out_tb)
   );

always begin
   clk_tb <= 1'b1;
   #5;
   clk_tb <= 1'b0;
   #5;
end

always begin
       carry_in_tb <= 1'b0;
       x_tb <= 1'b0;
       y_tb <= 1'b0;
       #10;
       carry_in_tb <= 1'b0;
       x_tb <= 1'b0;
       y_tb <= 1'b1;
       #10;
       carry_in_tb <= 1'b0;
       x_tb <= 1'b1;
       y_tb <= 1'b0;
       #10;
       carry_in_tb <= 1'b0;
       x_tb <= 1'b1;
       y_tb <= 1'b1;
       #10;
       carry_in_tb <= 1'b1;
       x_tb <= 1'b0;
       y_tb <= 1'b0;
       #10;
       carry_in_tb <= 1'b1;
       x_tb <= 1'b0;
       y_tb <= 1'b1;
       #10;
       carry_in_tb <= 1'b1;
       x_tb <= 1'b1;
       y_tb <= 1'b0;
       #10;
       carry_in_tb <= 1'b1;
       x_tb <= 1'b1;
       y_tb <= 1'b1;
       #10;
end
endmodule
