
module reg_file
   #(
    parameter PACK_WIDTH = 8, // number of bits
              ADDR_WIDTH = 2  // number of address bits
   )
   (
    input  logic clk,
    input  logic wr_en,
    input  logic [ADDR_WIDTH-1:0] w_addr, r_addr,
    input  logic [PACK_WIDTH-1:0] w_data,
    output logic [PACK_WIDTH-1:0] r_data
   );

   // signal declaration
   logic [PACK_WIDTH-1:0] array_reg [0:2**ADDR_WIDTH-1];

   // body
   // write operation
   always_ff @(posedge clk) begin
      if (wr_en) begin 
         array_reg[w_addr] <= w_data;
      end
   end
   
   // read operation
   assign r_data = array_reg[r_addr];
endmodule
