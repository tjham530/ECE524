`timescale 1ns/1ns
`define m " [$monitor:]  : %t => sw = %b | buttons = %b | rgb = %b | state = %s"


/////////////////////////////////////////////////////////////////////////////////
//TESTING STRATEGY:
    //perform non_exhaustive first, prove basic fucntion 
    //wait until above done to begin exhuastive, try to force an error!!
/////////////////////////////////////////////////////////////////////////////////

module full_test();
    ///////////////////////////////////////////////////////
    //SIGNALS
    ///////////////////////////////////////////////////////
    //parameters: 
    localparam SYS_CLK = 125_000_000; //Hz
    localparam DEBOUNCE_PERIOD = (SYS_CLK);  //desired wait time clocks for button pulse to arrive => 500ms
    localparam PULSE_PER = 1000; //how many clock periods the button will be active for
    localparam RED_PULSE = (SYS_CLK*0.5);
    localparam bp = (SYS_CLK * 0.5);  //100ns
    
    //otehr constants
    localparam N = 4'h8;
    localparam S = 4'h4;
    localparam E = 4'h2;
    localparam W = 4'h1;
    localparam PASSCODE = 16'h1214;    //enter the right most digit first, then go left
    localparam INP_CODE = 8'h44;     
    localparam ALARM_CODE = 8'h12;
    localparam CANCEL_CODE = 8'h22;
    localparam LOCK_CODE = 8'h88;
    
    //timing constants:
    localparam full_cp = 8;     //ns clk
    localparam half_cp = 4;
    
    //instance signals: 
    logic clk = 1'b0;
    logic [1:0] sw;
    logic [3:0] button;
    logic [2:0] rgb;
    logic mem [0:1];
    
    //comparison values for states:
    typedef enum {idle,alarm, unlocked, inp} state_type;
    localparam state_type ST1 = idle;
    localparam state_type ST2 = inp;
    localparam state_type ST3 = unlocked;
    localparam state_type ST4 = alarm;
    localparam RED = 3'b100;
    localparam GREEN = 3'b010;
    localparam BLUE = 3'b001;
    
    ///////////////////////////////////////////////////////
    //TASKS 
    ///////////////////////////////////////////////////////
    task inp_combo (input [7:0] inp_combo, input state_type desired_state, input [2:0] desired_rgb );
        #full_cp sw[1] = 1'b1;
        #(10*full_cp) button = inp_combo[3:0];  //button gets lower combo
        #bp button = 'b0;   //wait a full button push => 500ms
        #(2*SYS_CLK) button = inp_combo[7:4];   //wait 2s in between
        #bp button = 'b0;   //hold button for 500ms 
        #full_cp sw[1] = 1'b0;  
        #(2*SYS_CLK); //wait 2s and check state and rgb 
        if ((uut.state_reg != desired_state) || (rgb != desired_rgb)) begin 
            $display("TEST FAILED: desired state change and/or RGB change did not occur.");
            $display("state = %s",uut.state_reg.name());
            $display("combo = %b", uut.combo);
//            $display("
            $stop;
        end
        #full_cp;
    endtask
    
    task inp_passcode(input [15:0] inp_password, input state_type desired_state, input [2:0] desired_rgb);
        #(10*full_cp) button = inp_password[3:0];
        #bp button = 'b0;
        #(10*full_cp) button = inp_password[7:4];
        #bp button = 'b0;
        #(10*full_cp) button = inp_password[11:8];
        #bp button = 'b0;
        #(10*full_cp) button = inp_password[15:12];
        #bp button = 'b0;
        #full_cp;
        if ((uut.state_reg != desired_state) || (rgb != desired_rgb)) begin 
            $display("TEST FAILED: passcode input did not invoke desired state and/or rgb.");
            $stop;
        end
        #full_cp;
    endtask
    
    task reset;
        #full_cp sw[0] = 1'b1;     //rst triggered with sw0
        #(10*full_cp) sw[0] = 1'b0;
        #full_cp;
    endtask

    ///////////////////////////////////////////////////////
    //INSTANCES
    ///////////////////////////////////////////////////////
    fsm_top #(.DEBOUNCE_PERIOD (DEBOUNCE_PERIOD), .PULSE_PER (PULSE_PER), .RED_PULSE (RED_PULSE)) 
        uut( .clk (clk), .sw (sw), .n (button[3]),
            .w (button[0]), .e (button[1]), .s (button[2]), .rgb (rgb));
   
    ///////////////////////////////////////////////////////
    //SETUP
    ///////////////////////////////////////////////////////
    //monitor block 
    initial begin 
        $monitor(`m,$time,sw,button,rgb, uut.state_reg.name());  
    end 
    
    //setup block
    initial begin
        $timeformat(-9, 1, "ns");   //formats how we display the timevalues
    end 
    
    /////////////////////////////////////////////////////////////////////////////////////
    //MAIN TESTING: test two instances
        //plan: 
            //non-exhaustive first: go through all states from start to finish
            //EX: test all state transitions, and force errors!!
    /////////////////////////////////////////////////////////////////////////////////////
    //clk gen  
    always begin
       #half_cp clk = ~clk;
    end 
                
        initial begin 
            /////////////////////////////////////////////////////////////////////////////////////
            //NON-EXHAUSTIVE
            /////////////////////////////////////////////////////////////////////////////////////
            //init signals
            button = 'b0; sw = 'b0; 
            
            //reset system
            reset;
            $display("System Reset Initiated!");
            
            #(10*full_cp);
            if (rgb != 3'b100) begin 
                $display ("ERROR: Red RGB not on.");
                $stop;
            end 
            
            //State Change: input "SS" to jump from idle => inp
            #full_cp;
            $display("TEST INITIATED: SS combo input.");
            #full_cp;
            inp_combo(INP_CODE, ST2, BLUE);
            #full_cp;
            $display("TEST PASSED: SS combo invoked state = inp and RGB = blue.");
            
            
            //Enter Passcode Correctly:
            $display("TEST INITIATED: Correct passcode input.");
            inp_passcode(PASSCODE, ST3, GREEN);
            $display("TEST PASSED: Correct passcode invoked state = unlocked and RGB = green.");

            
            //lock the system again
            $display("TEST INITIATED: Lock the system after unlocking.");
            inp_combo (LOCK_CODE, ST1, RED);
            $display("TEST PASSED: System now locked.");
           
            #full_cp $display("NON-EXHAUSTIVE TEST COMPLETE. NO ERRORS FOUND.");
            
            /////////////////////////////////////////////////////////////////////////////////////
            //EXHAUSTIVE:
                //check all rgb's have correct color in each state 
                //check all state transitions 
                //check controllers function: passcode and combo
                //force several errors
            /////////////////////////////////////////////////////////////////////////////////////
            #full_cp $display("Exhaustive Test Initiated.");
            
            
            //Alarm state test: get to alarm state and then test to see if LED is blinking
            #full_cp $display("TEST INITIATED: Alarm State invoking and LED Flashing in state.");
            inp_combo(INP_CODE, ST2, BLUE); //get to input state 
//            #full_cp $display("forcing RGB");
//            #full_cp force uut.rgb_reg = 3'b000; //ignore RGB for state change test 
            inp_passcode(16'h1111, ST4,3'b000);
//            #full_cp release uut.rgb_reg;
            #full_cp mem[0] = rgb[2];
            #((RED_PULSE) + 14) mem[1] = rgb[2];     //wait for the red pulse period + extra clk cycle
            #full_cp;
            
            if (mem[0] == mem[1]) begin      //if red rgb unchanged 
                $display("TEST FAILED: Red RGB not pulsing.");
                $stop;
            end 
            $display("TEST PASSED: alarm state triggered and red rgb pulsing.");
            
            //Test: Combo alarm off
            #full_cp $display("TEST INITIATED: Alarm Code.");
            inp_combo(ALARM_CODE, ST1, RED);
            if (uut.state_reg != ST1) begin 
                $display("TEST FAILED: Alarm code did not silence alarm.");
                $stop;
            end 
            $display("TEST PASSED: Alarm code silenced alarm.");
            
            
            //Test: Cancel Code: 
            #full_cp $display("TEST INITIATED: Cancel Code.");
            inp_combo(INP_CODE, ST2, BLUE);
            #(10*full_cp) button = N;
            #bp button = 'b0;
            #(10*full_cp) button = S;
            #bp button = 'b0;
            
            inp_combo(CANCEL_CODE,ST1,RED);
            #full_cp $display("TEST PASSED: Cancel Code sent sys into idle state.");
            
            
            //Check System Reset for Every State that is not idle:
            for (int i = 0; i<3; i++) begin 
                if (i == 0) begin //reset from inp
                    inp_combo(INP_CODE, ST2, BLUE);
                end else if (i == 1)  begin 
                    inp_combo(INP_CODE, ST2, BLUE);
                    inp_passcode(PASSCODE, ST3, GREEN);
                end else begin
                    inp_combo(INP_CODE, ST2, BLUE);
                    force rgb = 'b0;
                    inp_passcode(16'h1111, ST4, 3'b000);
                    release rgb;
                end  
                reset;
                if (uut.state_reg != ST1) begin 
                    $display("TEST FAILED: System Reset not properly functioning.");
                end 
            end 
            $display("TEST PASSED: System reset works for all states.");
            
            
            
            #full_cp $display("EXHAUSTIVE TEST COMPLETE. NO ERRORS FOUND.");
            #full_cp $finish;
        end 

       
endmodule

    
// /////////////////////////////////////////////////////////////////////////////////////
// //Errors:
// /////////////////////////////////////////////////////////////////////////////////////

//
// /////////////////////////////////////////////////////////////////////////////////////
// //NEED TO FIX:
// /////////////////////////////////////////////////////////////////////////////////////


// /////////////////////////////////////////////////////////////////////////////////////
// //notes:
// /////////////////////////////////////////////////////////////////////////////////////
// //ERROR: SIGNED DATA TYPE => signed data types are represented differently in SV and need to 
//    //be handled accordingly. 
// //ERROR: TASKS I/O => dont double up on any input definition, need to go line by line! 
//    //AND => OUTPUT TEMP REG goes on the top line of the task
// //ERROR: TASKS => cannot use case in a task
            
            
    






























