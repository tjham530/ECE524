/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Module Function: 
    //create a 2d array, rows are 8 bits numbers, each 8 bit num is array
    //take array values and perform and If-else (if-else statement) on the numbers to get resulting truth table
        //use 2nd level of array to compare bits / numbers 
        //final value of array doesnt matter, bc we will place in excel
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module LUT_gen (clk,a,b,outp);
    parameter n = 5;            // 5 bits in case of carry / overflow
    
    input clk;
    input [n-2:0] a,b;
    output [n-1:0] outp;        
    
    reg [n-2:0] inter;              // 4 bit
    reg [n-1:0] outp_int;           // 5 bit
    reg [n-2:0] carry_test;         // 4 bit for mag only

    always @(posedge(clk)) 
    begin
        if (a[n-2] == b[n-2]) begin     //a[3] == b[3] => if same sign (start with 4 bit numbers)
            carry_test = a[n-3:0] + b[n-3:0];   //[2:0] for mags    
            if (carry_test[n-2] == 1'b1) //if fourth bit of magnitude has a 1, then we have overflow
                begin       
                    outp_int = {a[n-2], carry_test};        //shift sign bit and concat. 4-bit mag
                end 
            else 
                begin
                    inter = a[n-3:0] + b[n-3:0];
                    outp_int = {1'b0, a[n-2], inter};    //no carry => keep 5th bit 0 and add normally
                end
            end 
        else if (a[n-2] > b[n-2]) 
            begin 
                inter = a[n-3:0] - b[n-3:0];
                outp_int = {1'b0,a[n-2],inter};
            end 
        else 
            begin 
                inter = b[n-3:0] - a[n-3:0];
                outp_int = {1'b0,b[n-2],inter};
            end  
    end 
    assign outp = outp_int;
endmodule

    //CHECK: NEED TO ADJUST EVERYTHING FOR 5 BIT PARAMETERS
        //ADD note to ROM code saying how answers pull are structured
            //if carry: bit 5 = blahg
            //no carry = ignore 5th bit

    //new method for LUT gen:
        //if (Same sign) then
            //if overflow
                //shift sign bit and add the overflow  
            //else 
                //add normally 
        //else (opposite sign)
            //if Amag > Bmag 
                //sub Amag - Bmag 
                //keep Asign and give inter
            //else (Bmag > A mag))
                //sub Bmag - Amag 
                //add to Bsign

///////////////////////////////////////////////////////////
    /*
        //code without carry coverage
        if (a[n-1] == b[n-1]) 
            begin
                inter = a[n-2:0] + b[n-2:0];
                outp_int = {a[n-1], inter};
            end
        if (a[n-2:0] > b[n-2:0])
            begin
                inter = a[n-2:0] - b[n-2:0];
                outp_int = {a[n-1],inter};
            end
        if (a[n-2:0] < b[n-2:0])
            begin
                inter = b[n-2:0] - a[n-2:0];
                outp_int = {b[n-1],inter};
            end
    */