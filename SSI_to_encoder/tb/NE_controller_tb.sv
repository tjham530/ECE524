`timescale 1ns/1ns
`define  m1 " [$monitor: master]  : %t =>  led = %b | seg = %b | cs = %b"
`define m3 " [$monitor: int signals] : %t => data_int = %b | ssi_clk_int = %b | zero_int = %b"

module NE_controller_tb();
    ///////////////////////////////////////////////////////
    //SIGNALS
    ///////////////////////////////////////////////////////
    //parameters (change)
    localparam SYS_CLK_FREQ = 100_000_000;
    localparam DEBOUNCE_CLKS = 10;

    //constants 
    localparam full_cp =  10;
    localparam half_cp =  5;
    
    //instance signals: inputs
    logic clk = 1'b0;
    logic rst;    
    logic data_in; 
    
    //instance signals: outputs    
    logic [3:0] led;
    logic [6:0] seg;   //output to SSD
    logic cs;          //SSD chip sel
    logic ssi_clk, zero;
                
    integer time1;
    integer time2;
    ///////////////////////////////////////////////////////
    //INSTANCES
    ///////////////////////////////////////////////////////
    ssi_top #(
        .SYS_CLK_FREQ (SYS_CLK_FREQ),
        .DEBOUNCE_CLKS (DEBOUNCE_CLKS)     
    ) uut(
        .clk(clk),
        .sys_rst(rst),
        .data (data_in),
        .ssi_clk (ssi_clk),
        .zero (zero), 
        .led (led),
        .seg (seg),
        .cs (cs)
    );
  
    ///////////////////////////////////////////////////////
    //SETUP
    ///////////////////////////////////////////////////////
//    //monitor block 
//    initial begin 
//        $monitor(`m1, $time, led, seg, cs);  
////        $monitor(`m3, $time, data_int, ssi_clk_int, zero_int);
//    end 
    
    //setup block
    initial begin
        $timeformat(-9, 1, "ns");   //formats how we display the timevalues
    end 
    
    /////////////////////////////////////////////////////////////////////////////////////
    //MAIN TESTING: 
    /////////////////////////////////////////////////////////////////////////////////////
    //clk gen  
    always begin
       #half_cp clk = ~clk;
    end   
                
        /////////////////////////////////////////////////////////////////////////////////////////////////////////
        //Main Test Block:
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        initial begin 
            //////////////////////////////////////////////////////////////////////////////////////////////////////
            //NON-EXHAUSTIVE 
                //TEST 1: sys reset => check too see if all signals are init
                //TEST 2: see the correct period timing of ssi clk
                    //test 3: test to see if correct clock count comes out
                //TEST 3: see if sampling clock is occuring at correct time 
                //TEST 4: see if data_output not 0 when a pulse train comes through
            //////////////////////////////////////////////////////////////////////////////////////////////////////
            //init signals 
            rst = 1'b0; data_in = 1'b0;

            //TEST 1: 
            #full_cp rst = 1'b1;
            #full_cp rst = 1'b0;
            
            #full_cp;
            if (led == 'bx) begin
                $display("TEST 1 FAILED: system reset did not initiate signal => led.");
                $stop;
            end 
            
            #full_cp;
            if (seg == 'bx) begin
                $display("TEST 1 FAILED: system reset did not initiate signal => seg.");
                $stop;
            end 
                   
            //TEST 2:
                //a: period = 40ns
                @(posedge ssi_clk) time1 = $time; //wait until ssi clk rising edge
                @(posedge ssi_clk) time2 = $time; //wait until ssi clk rising edge
                #full_cp;
                if ((time2-time1) != 40) begin 
                    $display("TEST 2 FAILED: SSI clk period  = %d", (time2-time1));
                    $stop;
                end 
                
//                //b: clk count = 25
//                @(tx_unit.ptrain_done);
//                if (tx_unit.out_count != 24) begin 
//                    $display("TEST 2 FAILED: clock count = %d ", tx_unit.out_count); 
//                end 
            
            //TEST 3:
            @(posedge ssi_clk);
            #12;
            if (uut.sampling_clk != 1'b1) begin 
                $display("TEST 3 FAILED: sampling clock timing not occuring in the middle of ssi_clk => %t", $time);
                @(posedge uut.sampling_clk) time1 = $time;
                @(posedge uut.sampling_clk) time2 = $time;
                $display("Sampling clock pulse period = %d", (time2-time1));
                $stop;
            end 
            
            #full_cp $display("NON-EXHAUSTIVE SIMULATION SUCCESS. ALL TESTS PASSED.");
            #full_cp $finish;
         end 
endmodule 
            




            
//            if (controller.ssd_right == 'b0) begin                          //checks lowest bits of position data
//                $display ("ERROR: POSITION DATA NOT TRANSMITTED.");
//                $stop;
//            end 
            
//            #full_cp;
//            if (led == 'b0) begin 
//                $display ("ERROR: REV DATA NOT TRANSMITTED.");
//                $stop;
//            end 
            
//            #full_cp;
//            $display("TEST PASSED: DATA TRANSMITTED SUCCESSFULLY.");
//            #full_cp $finish;

    
 /////////////////////////////////////////////////////////////////////////////////////
 //Errors:
 /////////////////////////////////////////////////////////////////////////////////////
    //sampling clk is miss timed 
    //ssi clk is not repeating over time. only pulsing one train

 /////////////////////////////////////////////////////////////////////////////////////
 //NEED TO FIX:
 /////////////////////////////////////////////////////////////////////////////////////

 /////////////////////////////////////////////////////////////////////////////////////
 //notes:
 /////////////////////////////////////////////////////////////////////////////////////
//inputs to control:
    //sys_rst => button0 on zybo 
    //buttons 
    //clk 
















//             //init signals
//             oe0 = 1'b0; en0 = 1'b0; opcode0 = 'b0; a0 = 'b0; b0 = 'b0;
//             done = 1'b0;
//             //setup for input and output enable 
//             #full_cp oe0 = 1'b1; en0 = 1'b1;
//             #full_cp a0 = 4'h2; b0 = 2'h1; opcode0 = code[0];
            
//             //Testing Enable Lines:
//             $display("TEST STARTED: unsigned enable lines test.");
//             #full_cp oe0 = 1'b0; 
//             #(2*full_cp) en_mem[0] = alu_out1;
//             #(2*full_cp) en_mem[1] = alu_out1;
//             #full_cp if (en_mem[0] != en_mem[1]) $display("TEST FAILED: unsigned oe line didnt maintain output.");
//             #full_cp oe0 = 1'b1; 
//             #full_cp oe0 = 1'b0; 
//             #full_cp if (alu_out0 != 'bz) $display("TEST FAILED: unsigned oe line didnt disable output.");
//             #full_cp oe0 = 1'b1; 
//             $display("TEST SUCCESSFUL: unsigned enable lines test.");
            
//             //test all opcodes for A = 2, B = 1
//             $display("TEST STARTED: unsigned opcode test.");
//             #full_cp;
//             for(int i = 0; i < 6; i++) begin
//                 #full_cp opcode0 = code[i];
//                 #full_cp unsigned_task(opcode0,a0,b0,test_vector0);
//                 #(2*full_cp);
//                 if (alu_out0 !== test_vector0) begin
//                     if (i == 0) $display("TEST FAILED: unsigned add opcode test failed. %b + %b /= %b.",a0,b0,test_vector0);
//                     if (i == 1) $display("TEST FAILED: unsigned sub opcode test failed. %b - %b /= %b.",a0,b0,test_vector0);
//                     if (i == 2) $display("TEST FAILED: unsigned AND opcode test failed. %b & %b /= %b.",a0,b0,test_vector0);
//                     if (i == 3) $display("TEST FAILED: unsigned OR opcode test failed. %b | %b /= %b.",a0,b0,test_vector0);
//                     if (i == 4) $display("TEST FAILED: unsigned XOR opcode test failed. %b ^ %b /= %b.",a0,b0,test_vector0);
//                     if (i == 5) $display("TEST FAILED: unsigned NOT opcode test failed. ~%b /= %b.",a0,test_vector0);
//                     $stop;
//                 end
//             end 
//             $display("TEST SUCCESSFUL: unsigned opcode test.");
            
//             //TEST: zero flag
//             $display("TEST STARTED: unsigned flags test.");
//             #full_cp force unsigned_unit.alu_out_reg = 'b0;
//             #(2*full_cp);
//             if (zf0 !== 1'b1) begin
//                 $display("TEST FAILED: Unsigned zero flag not triggered.");
//                 $stop;
//             end
//             release unsigned_unit.alu_out_reg;
            
//             //TEST: carry flag => adding
//             #full_cp opcode0 = code[0];
//             #full_cp force unsigned_unit.carry_test = 5'b1_0000;
//             #(2*full_cp);
//             if (cf0 !== 1'b1) begin
//                 $display("TEST FAILED: Unsigned addition carry flag not triggered.");
//                 $stop;
//             end
//             release unsigned_unit.carry_test;
            
//             //TEST: carry flag => subtracting
//             #full_cp opcode0 = code[1]; b0 = 4'hf;
//             #(2*full_cp);
//             if (cf0 !== 1'b1) begin
//                 $display("TEST FAILED: Unsigned subtraction carry flag not triggered.");
//                 $stop;
//             end

//             //TEST: negative
//             #full_cp force unsigned_unit.alu_out_reg = 4'h8;
//             #(2*full_cp);
//             if (sf0 !== 1'b1) begin
//                 $display("TEST FAILED: Unsigned negative flag not triggered.");
//                 $stop;
//             end
//             release unsigned_unit.alu_out_reg;
//             $display("TEST SUCCESSFUL: unsigned flags test.");
                
//             //random testing:
//             $display("TEST STARTED: unsigned random test.");
//             #full_cp;
//             for (int k = 0; k < 100; k++) begin
//                 #full_cp;
//                 opcode0 = code[$urandom_range(0,5)];
//                 a0 = $urandom_range(4'h0,4'hf);
//                 b0 = $urandom_range(4'h0,4'hf);
//                 #(2*full_cp) unsigned_task(opcode0,a0,b0,test_vector0);
//                 if (alu_out0 != test_vector0) begin
//                     $display("TEST FAILED: Random Testing => Opcode0 = %b | A0 = %b | B0 = %b | alu_out0 = %b | Test_vector = %b.",
//                              opcode0,a0,b0,alu_out0,test_vector0);
//                     $stop;
//                 end 
//             end
//             $display("TEST SUCCESSFUL: unsigned random test.");
//             #full_cp; done = 1'b1;
//             $display("UNSIGNED TESTS COMPLETED SUCCESSFULLY.");
//         end 

//         /////////////////////////////////////////////////////////////////////////////////////
//         //SIGNED TESTING BLOCK: 
//         /////////////////////////////////////////////////////////////////////////////////////
//         initial begin    
//             //init signals
//             oe1 = 1'b0; en1 = 1'b0; opcode1 = 'b0; a1 = 'b0; b1 = 'b0; test_vector1 = 'b0;
            
//             @(done == 1'b1);
            
//             //setup for input and output enable 
//             #full_cp oe1 = 1'b1; en1 = 1'b1;
//             #full_cp a1 = 5'b0_0100; b1 = 5'b0_0010; opcode1 = code[0];
            
//             //Testing Enable Lines:
//             $display("TEST STARTED: signed enable lines test.");
//             #full_cp oe1 = 1'b0; 
//             #(2*full_cp) en_mem[0] = alu_out1;
//             #(2*full_cp) en_mem[1] = alu_out1;
//             #full_cp if (en_mem[0] != en_mem[1]) $display("TEST FAILED: signed oe line didnt maintain output.");
//             #full_cp oe1 = 1'b1; 
//             #full_cp oe1 = 1'b0; 
//             #full_cp if (alu_out1 != 'bz) $display("TEST FAILED: signed oe line didnt disable output.");
//             #full_cp oe1 = 1'b1; 
//             $display("TEST SUCCESSFUL: signed enable lines test.");
            
//             //test all opcodes for A = 2, B = 1
//             $display("TEST STARTED: signed opcode test.");
//             #full_cp;
//             for(int j = 0; j < 6; j++) begin
//                 #full_cp opcode1 = code[j];
//                 #full_cp;
//                 if ((opcode1 == 4'h2) | (opcode1 == 4'h3)) begin 
//                     #full_cp signed_math(opcode1,a1,b1,test_vector1);
//                 end else begin 
//                     #full_cp signed_logic(opcode1,a1,b1,test_vector1);
//                 end 
//                 #(2*full_cp);
//                 if (alu_out1 !== test_vector1) begin
//                     if (j == 0) $display("TEST FAILED: signed add opcode test failed. %b + %b /= %b.",a1,b1,test_vector1);
//                     if (j == 1) $display("TEST FAILED: signed sub opcode test failed. %b - %b /= %b.",a1,b1,test_vector1);
//                     if (j == 2) $display("TEST FAILED: signed AND opcode test failed. %b & %b /= %b.",a1,b1,test_vector1);
//                     if (j == 3) $display("TEST FAILED: signed OR opcode test failed. %b | %b /= %b.",a1,b1,test_vector1);
//                     if (j == 4) $display("TEST FAILED: signed XOR opcode test failed. %b ^ %b /= %b.",a1,b1,test_vector1);
//                     if (j == 5) $display("TEST FAILED: signed NOT opcode test failed. ~%b /= %b.",a1,b1,test_vector1);
//                     if (j == 5) $display("TEST FAILED: signed NOT opcode test failed. ~%b /= %b.",a1,b1,test_vector1);
//                     $stop;
//                 end
//             end 
//             $display("TEST SUCCESSFUL: signed opcode test.");
            
//             //TEST: zero flag
//             $display("TEST STARTED: signed flags test.");
//             #full_cp force signed_unit.alu_out_reg = 'b0;
//             #(2*full_cp);
//             if (zf1 !== 1'b1) begin
//                 $display("TEST FAILED: Signed zero flag not triggered.");
//                 $stop;
//             end
//             release signed_unit.alu_out_reg;
            
//             //TEST: overflow flag => adding
//             #full_cp opcode1 = code[0];
//             #full_cp force signed_unit.alu_out_reg = 5'b1_0000;
//             #(2*full_cp);
//             if (of1 !== 1'b1) begin
//                 $display("TEST FAILED: Signed addition overflow flag not triggered.");
//                 $stop;
//             end
//             release signed_unit.alu_out_reg;
            
//             //TEST: overflow flag => subtracting
//             #full_cp opcode1 = code[1]; a1 = 5'b1_0001; b1 = 5'b1_0001;
//             #full_cp force signed_unit.alu_out_reg = 5'b0_0001;
//             #(2*full_cp);
//             if (of1 !== 1'b1) begin
//                 $display("TEST FAILED: Signed subtraction overflow flag not triggered.");
//                 $stop;
//             end
//             release signed_unit.alu_out_reg;
            
//             //TEST: negative
//             #full_cp force signed_unit.alu_out_reg = 5'b1_0000;
//             #(2*full_cp);
//             if (sf1 !== 1'b1) begin
//                 $display("TEST FAILED: Signed negative flag not triggered.");
//                 $stop;
//             end
//             release signed_unit.alu_out_reg;
//             $display("TEST SUCCESSFUL: Signed flags test.");
                
//             //random testing:
//             $display("TEST STARTED: Signed random test.");
//             #full_cp;
//             for (int k = 0; k < 100; k++) begin
//                 #full_cp;
//                 opcode1 = code[$urandom_range(0,5)];
//                 a1 = $urandom_range(4'h0,4'hf);
//                 b1 = $urandom_range(4'h0,4'hf);
//                 #full_cp;
//                 if ((opcode1 == 4'h2) | (opcode1 == 4'h3)) begin 
//                     #full_cp signed_math(opcode1,a1,b1,test_vector1);
//                 end else begin 
//                     #full_cp signed_logic(opcode1,a1,b1,test_vector1);
//                 end 
//                 #(4*full_cp);
//                 if (alu_out1 != test_vector1) begin
//                     $display("TEST FAILED: Random Testing [iteration : %d] => Opcode1 = %h | A1 = %b | B1 = %b | alu_out1 = %b | Test_vector = %b.",
//                              k,opcode1,a1,b1,alu_out1,test_vector1);
//                     //$stop;
//                 end 
//             end
//             $display("TEST SUCCESSFUL: Signed random test.");
//             #full_cp; done = 1'b1;
//             $display("SIGNED TESTS COMPLETED SUCCESSFULLY.");
            
//             //end of sim:
//             #full_cp $display("EXHAUSTIVE TEST COMPLETED SUCCESSFULLY: all conditions passed successfully.");
//             #full_cp $finish;
//         end 
// endmodule

    
//  /////////////////////////////////////////////////////////////////////////////////////
//  //Errors:
//  /////////////////////////////////////////////////////////////////////////////////////

//  /////////////////////////////////////////////////////////////////////////////////////
//  //NEED TO FIX:
//  /////////////////////////////////////////////////////////////////////////////////////

//  /////////////////////////////////////////////////////////////////////////////////////
//  //notes:
//  /////////////////////////////////////////////////////////////////////////////////////

            
    






























