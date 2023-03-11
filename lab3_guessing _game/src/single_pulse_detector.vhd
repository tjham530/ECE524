library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity single_pulse_detector is
    port
    (
        clk          : in std_logic;   
        input_signal : in std_logic;                --button push
        output_pulse : out std_logic;               --output to start the counter
        q_2          : out std_logic                --sends the 2nd FF signal to the third 
        );
end single_pulse_detector;

architecture Behavioral of single_pulse_detector is
    signal states: std_logic_vector(1 downto 0);    --state0 = q_1 and state1 = q_2
begin
    edge_detect: process(clk)
    begin 
        if rising_edge(clk) then 
            states(0) <= input_signal;
            states(1) <= states(0);
        end if;
    end process;

    output_pulse <= states(0) AND (not states(1));   --edited from XOR gate to only pulse once
    q_2 <= states(1);                                --pass signal to port
    
end Behavioral;
