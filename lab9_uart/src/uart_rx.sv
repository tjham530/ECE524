
module uart_rx (clk, reset, rx, s_tick, rx_done_tick, dout);

   //parameters 
   parameter DATA_WIDTH = 0;
   parameter SAMPLE_TICKS = 0;  // # ticks for stop bits
   parameter B_BITS = DATA_WIDTH;      //b = the number of bits retrieved
   parameter S_BITS = 0;               //s = number of sampling ticks
   parameter N_BITS = 0;               //n = number of data bits received

   //ports 
    input  logic clk, reset, rx, s_tick;
    output logic rx_done_tick;
    output logic [DATA_WIDTH-1:0] dout;

   // fsm state type 
   typedef enum {idle, start, data, stop} state_type;

   // signal declaration
   state_type state_reg, state_next;
   logic [S_BITS-1:0] s_reg, s_next;
   logic [N_BITS-1:0] n_reg, n_next;
   logic [B_BITS-1:0] b_reg, b_next;

   // FSM current state logic
   always_ff @(posedge clk, posedge reset)
      if (reset) begin
         state_reg <= idle;
         s_reg <= 0;
         n_reg <= 0;
         b_reg <= 0;
      end
      else begin
         state_reg <= state_next;
         s_reg <= s_next;
         n_reg <= n_next;
         b_reg <= b_next;
      end

   // FSMD next-state logic
   always_comb
   begin
      //need to assign the next values to the current values
         //allows values from others processes to be included in here
      state_next = state_reg;
      rx_done_tick = 1'b0;
      s_next = s_reg;
      n_next = n_reg;
      b_next = b_reg;
      case (state_reg)
         idle:
            if (~rx) begin    //start when start bit received (low signal)
               state_next = start;
               s_next = 0;
            end
         start:
            if (s_tick) //baud rate gen rate enable signal 
               if (s_reg == 7) begin  //count to middle of start bit
                  state_next = data;
                  s_next = 0;
                  n_next = 0;
               end
               else
                  s_next = s_reg + 1;
         data:
            if (s_tick)
               if (s_reg==15) begin    //count to middle of next bit
                  s_next = 0;
                  b_next = {rx, b_reg[DATA_WIDTH-1:1]}; //shift received bit and shift off LSB
                  if (n_reg==(DATA_WIDTH-1))
                     state_next = stop ;
                  else
                     n_next = n_reg + 1;
               end
               else
                  s_next = s_reg + 1;
         stop:
            if (s_tick)
               if (s_reg==(SAMPLE_TICKS-1)) begin  //count to end of stop bit
                  state_next = idle;
                  rx_done_tick =1'b1;
               end
               else
                  s_next = s_reg + 1;
      endcase
   end

   // output
   assign dout = b_reg;
endmodule
