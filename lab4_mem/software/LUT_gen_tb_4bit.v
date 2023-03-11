`timescale 1ns/1ps
`define twait 1

module LUT_gen_tb_4bit ();
    localparam n = 5;
    reg [n-2:0] a,b = {5{1'b0}};
    wire [n-1:0] outp;
    reg [8:0] i =  {9{1'b0}};
    reg clk =1'b0;

    LUT_gen #(5) inst(clk,a,b,outp);
    
    always
    begin
       #1 clk = !clk;
    end

    always @(posedge(clk))
    begin
        if (i <= 8'b11111111) 
            begin
                a = i[3:0];
                b = i[7:4];
                #`twait $display("%b",outp);
                i = i + 1;
                if (i === 9'b100000000) $finish;
            end
            
        end
endmodule