library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-----------------------------------------------------------------------------
--ENTITY: 
    --function:
        --the single pulse dector will receive input of any button or SW
        --sends signal to debounce to either debounce its input or send 
            --a single pulse on its behalf
        --this debounce is for a single pulse button debouncer: every 
            --button push will send one pulse on behalf of its assigned btn
            --thus, q_2 will be taken out of this code
-----------------------------------------------------------------------------
entity single_pulse_detector is
    port
    (
        clk          : in std_logic; 
        rst          : in std_logic;  
        input_signal : in std_logic;                --button push
        output_pulse : out std_logic               --output to start the counter
    );
end single_pulse_detector;

architecture Behavioral of single_pulse_detector is
    signal states: std_logic_vector(1 downto 0);    --state0 = q_1 and state1 = q_2
begin
    edge_detect: process(clk, rst)
    begin 
        if rst = '1' then  
            states <= "00";
        elsif rising_edge(clk) then 
            states(0) <= input_signal;
            states(1) <= states(0);
        end if;
    end process;

    output_pulse <= (not states(1)) and states(0);   --detecting rising edge
    
end Behavioral;
