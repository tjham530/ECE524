
module fifo_top
   #(
    parameter PACK_WIDTH=0, // number of bits in a word
              ADDR_WIDTH=0  // number of address bits
   )
   (
    input  logic clk, reset,
    input  logic rd, wr,
    input  logic [PACK_WIDTH-1:0] w_data,
    output logic empty, full,
    output logic [PACK_WIDTH-1:0] r_data
   );

   //signal declaration
   logic [ADDR_WIDTH-1:0] w_addr, r_addr;
   logic wr_en, full_tmp;

   // write enabled only when FIFO is not full
   assign wr_en = wr & ~full_tmp;
   assign full = full_tmp;
   
   // instantiate fifo control unit
   fifo_ctrl #(.ADDR_WIDTH(ADDR_WIDTH)) c_unit
      (.*, .full(full_tmp));

   // instantiate register file
   reg_file #(.PACK_WIDTH(PACK_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) f_unit 
      (.*);
endmodule

