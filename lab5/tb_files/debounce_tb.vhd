library ieee;
use ieee.std_logic_1164.all;
use std.env.stop;

entity debounce_tb is
--n/a
end debounce_tb;

architecture Behavioral of debounce_tb is
    constant CP      : time := 1ns;
    signal clk_tb    : std_logic;
    signal button_tb : std_logic := '0';
    signal result_tb : std_logic;
    signal rst_tb : std_logic;
begin

    tb: entity work.debounce 
        port map
        (
            rst => rst_tb,
            clk => clk_tb,
            button => button_tb,
            result => result_tb
        );
    
     --forever clk pulse
    process 
    begin 
        clk_tb <= '0';
        wait for CP/2;
        clk_tb <= '1';
        wait for CP/2;
    end process;
    
     --init button push
    process 
    begin
        button_tb <= '0';
        rst_tb <= '0';
        wait for 5*CP;
        
        --sys reset
        rst_tb <= '1';
        wait for CP;
        rst_tb <= '0';
        wait for 5*CP;
        
        --debounce test 
        button_tb <= '1';
        wait for 60*CP;
        button_tb <= '0';
        wait for 100*CP;
        
        --press button
        button_tb <= '1';
        wait for 20*CP;
        button_tb <= '0';
        wait for 30*CP;
        
        --test rst
        rst_tb <= '1';
        wait for 10*CP;
        stop;   
    end process;

end Behavioral;