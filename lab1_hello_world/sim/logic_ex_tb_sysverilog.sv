`timescale 1ns / 1ps

module logic_ex_tb_sysverilog;

  logic [1:0] SW;
  logic [3:0] LED;

  logic_ex u_logic_ex (.*);

  // Stimulus
  initial begin
    $printtimescale(logic_ex_tb_sysverilog);
    SW = '0;
    for (int i = 0; i < 4; i++) begin
      $display("Setting switches to %2b", i[1:0]);
      SW  = i[1:0];
      #100;
    end
    $display("PASS: logic_ex test PASSED!");
    $stop;
  end

  // Checking
  always @(LED) begin
    
    if (!SW[0] !== LED[0]) begin
      $display("FAIL: NOT Gate mismatch");
      $stop;
    end
    
    if (&SW[1:0] !== LED[1]) begin
      $display("FAIL: AND Gate mismatch");
      $stop;
    end

    if (|SW[1:0] !== LED[2]) begin
      $display("FAIL: OR Gate mismatch");
      $stop;
    end

    if (^SW[1:0] !== LED[3]) begin
      $display("FAIL: XOR Gate mismatch");
      $stop;
    end

  end
endmodule // logic_ex_tb_sysverilog
