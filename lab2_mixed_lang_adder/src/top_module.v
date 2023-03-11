`timescale 1ns / 1ps

module top_module(
   input wire [1:0] x,
   input wire [1:0] y,
   input wire clk,
   input wire rst,
   output wire [2:0] s
   );

reg [1:0] x_i;
reg [1:0] y_i;
wire [1:0] s_i;
wire c_i;
reg [2:0] s_reg;

full_adder_n_bit #(2)   //seems to specify the generic for the instantiation
   FA_N_BIT (
   .x(x_i),
   .y(y_i),
   .sum(s_i),
   .carry_out(c_i));

always @(posedge clk or posedge rst) begin
   if (rst == 1'b1) begin
       x_i <= 2'b0;
       y_i <= 2'b0;
       s_reg <= 3'b0;
   end
   else begin
       x_i <= x;
       y_i <= y;
       s_reg <= {c_i, s_i};
   end
end

assign s = s_reg;

endmodule

