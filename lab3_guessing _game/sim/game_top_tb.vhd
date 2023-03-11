library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.env.stop;

entity top_module_tb is

end top_module_tb;

architecture Behavioral of top_module_tb is
    constant CP         : time := 10ns;
    signal clk_tb       : std_logic;                       
    signal show_tb      : std_logic;                       
    signal enter_tb     : std_logic;                       
    signal switches_tb  : std_logic_vector(3 downto 0) := "0000";                       
    signal leds_tb      : std_logic_vector(3 downto 0);                       
    signal red_led_tb   : std_logic;                       
    signal green_led_tb : std_logic;                       
    signal blue_led_tb  : std_logic;   
    signal rst_tb       : std_logic;
    signal start_tb   : std_logic;              
         
begin
    tb: entity work.top_module
        port map
        (
            clk => clk_tb,
            start => start_tb,
            rst => rst_tb,
            enter => enter_tb,
            show => show_tb,
            switches => switches_tb,
            leds => leds_tb,
            red_led => red_led_tb,
            green_led => green_led_tb,
            blue_led => blue_led_tb
        );
        
    --forever clk pulse
    process 
    begin 
        clk_tb <= '0';
        wait for CP/2;
        clk_tb <= '1';
        wait for CP/2;
    end process;
    
    --main process
    process
    begin
        --initiate ports
        start_tb <= '0';
        rst_tb <= '0';
        enter_tb <= '0';
        show_tb <= '0';
        wait for 2*CP;
        
        --set to st0 button
        rst_tb <= '1';
        wait for CP;
        rst_tb <= '0';
        wait for 3*CP;
        
        --user pushes the start button
        start_tb <= '1';        
        wait for CP;           
        start_tb <= '0';
        switches_tb <= "0001";    --user enters the value on the boards switches
        wait for 3*CP;
        
        --user guesses low and pushes enter button
        enter_tb <= '1';          --user enters their value
        wait for CP;
        enter_tb <= '0';
        wait for 5*CP;
        
        --user wants to re-guess
        start_tb <= '1';
        wait for CP;
        start_tb <= '0';
        wait for 5*CP;
        
        --user guesses high and pushes enter button
        enter_tb <= '0';
        switches_tb <= "1111";    --user enters the value on the boards switches
        wait for 5*CP;
        enter_tb <= '1';
        wait for CP;
        enter_tb <= '0';
        wait for CP;
         
        --user wants to show LEDs
        show_tb <= '1';
        wait for CP;
        show_tb <= '0';
        wait for 3*CP;
        
        --user wants to re-gues
        start_tb <= '1';
        wait for CP;
        
        --guess right answer
        start_tb <= '0';
        switches_tb <= "1001";    --user enters the value on the boards switches
        wait for 5*CP;
        enter_tb <= '1';
        wait for CP;
        enter_tb <= '0';
        wait for CP;
        
        --wait for 20 clks to see pulses
        wait for 40*CP;
        
        --restart 
        rst_tb <= '1';
        wait for 10*CP;
        stop;  
    end process;
end Behavioral;