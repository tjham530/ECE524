library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.env.stop;

entity single_pulse_detector_tb is
--n/a
end single_pulse_detector_tb;

architecture Behavioral of single_pulse_detector_tb is
    constant CP            : time := 10ns;
    signal clk_tb          : std_logic := '0';
    signal input_signal_tb : std_logic := '0';
    signal output_pulse_tb : std_logic;
    signal q_2_tb          : std_logic;    
begin

    tb: entity work.single_pulse_detector
        port map
        (
            clk => clk_tb,
            input_signal => input_signal_tb,
            output_pulse => output_pulse_tb,
            q_2 => q_2_tb
        );
    
    --forever clk pulse
    process 
    begin 
        clk_tb <= '0';
        wait for CP/2;
        clk_tb <= '1';
        wait for CP/2;
    end process;
    
    --init reset and button push
    process 
    begin
        input_signal_tb <= '0';
        wait for CP;
        input_signal_tb <= '1';
        wait for CP;
        input_signal_tb <= '0';
        wait for CP*3;
        input_signal_tb <= '1';
        wait for CP;
        input_signal_tb <= '0';
        wait for CP*3;
        stop;   
    end process;
    
end Behavioral;