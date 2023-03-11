`timescale 1ns / 1ps

module full_adder(
   input wire x,
   input wire y,
   input wire carry_in,
   output wire sum,
   output wire carry_out
   );

wire ha1_sum;
wire ha1_carry;
wire ha2_carry;

half_adder ha1 (
   .x(x),
   .y(y),
   .sum(ha1_sum),
   .carry(ha1_carry));

half_adder ha2 (
   .x(ha1_sum),
   .y(carry_in),
   .sum(sum),
   .carry(ha2_carry));

assign carry_out = ha1_carry | ha2_carry;

endmodule
