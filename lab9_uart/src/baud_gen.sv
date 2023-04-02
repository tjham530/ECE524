`timescale 1ns/1ps 
module baud_gen (clk, reset, tick);

    //parameter
    parameter DVSR_BITS = 8;
    
    //ports
    input logic clk, reset;
    output logic tick;

    //intermediate signals 
    logic [DVSR_BITS-1:0] count;
    logic [DVSR_BITS-1:0] c_next;
    logic [DVSR_BITS-1:0] val;

    //current state logic: NBA bc they are FFs
    always @(posedge clk or posedge reset) begin 
        if (reset) begin 
            count <= 0;
        end 
        else begin 
            count <= c_next;
        end 
    end 
    
    assign val = 8'h42;     //create a constant for the count comparison => 66
    assign c_next = (count == val) ? 0 : (count + 1'b1);    //next state logic
    assign tick = (count == val);    //output logic: if 67 clks reached, tick goes high, then low afer 
    
endmodule

    //SV Notes
        //LOGIC: a data type that can handle both reg and wire 
        //always_ff : any assignments within the block infer registers 
        //register assignments should be NBA bc the clock controls the time, not us

    