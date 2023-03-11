`timescale 1ns/1ps
`define twait 1

module LUT_gen_tb_8bit ();
    localparam n = 9;
    reg [n-2:0] a,b = {8{1'b0}};
    wire [n-1:0] outp;
    reg [16:0] i =  {17{1'b0}};
    reg clk =1'b0;

    LUT_gen #(9) inst(clk,a,b,outp);
    
    always
    begin
       #1 clk = !clk;
    end

    always @(posedge(clk))
    begin
        if (i <= {16{1'b1}}) 
            begin
                a = i[7:0];
                b = i[15:8];
                #`twait 
                //$display("i = ","%d",i);
                $display("%b",outp);
                i = i + 1;
                if (i === 17'b10000000000000001) $finish;
            end
            
        end
endmodule