`timescale 1ns / 1ps

module simple_xor(
   input wire a,
   input wire b,
   output wire c
   );
  
   assign c = a ^ b;
endmodule
