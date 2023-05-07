library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.env.stop;

entity top_tb is
    --n/a
end entity;

architecture Behavioral of top_tb is

    constant CP      : time := 1ns;
    constant ADDR_WIDTH : NATURAL := 4;
    CONSTANT MAX_DATA : NATURAL := 10;
    CONSTANT DATA_WIDTH : NATURAL := 4;
    
    signal clk    : std_logic;
    signal leds    : std_logic_vector(3 downto 0);
    signal blue_led : std_logic;
    signal green_led : std_logic;
    signal buttons : std_logic_vector(3 downto 0);
    signal red_led : std_logic;
    
begin
    
    tb: entity work.top
        generic map(
            ADDR_WIDTH => ADDR_WIDTH,
            DATA_WIDTH => DATA_WIDTH,
            MAX_DATA => MAX_DATA
        )
        port map
        (
            clk => clk,
            buttons => buttons,
            leds => leds,
            blue_led => blue_led,
            green_led => green_led,
            red_led => red_led
        );
    
    --forever clk pulse
    process
    begin 
        clk <= '0';
        wait for CP/2;
        clk <= '1';
        wait for CP/2;
    end process;
    
    --main process
    process 
    begin 
        --init inputs 
        buttons <= "0000";
        wait for 20*CP;
        
        --initial reset
        buttons(0) <= '1';
        buttons(3) <= '1';
        wait for 20*CP;
        buttons(0) <= '0';
        buttons(3) <= '0';
        wait for 20*CP;
        
        --User Starts 
        buttons(1) <= '1';
        buttons(2) <= '1';
        wait for 20*CP;
        buttons(1) <= '0';
        buttons(2) <= '0';
        wait for 200*CP;
        
        --User guesses: 
        buttons(3) <= '1';
        wait for 40*CP;
        buttons(3) <= '0';
        wait for 100*CP;
        
        
--        --user inputs correct guess -> check -> correct -> flash
--        buttons(3) <= '1';
--        wait for 3*CP;
--        buttons(3) <= '0';
--        wait for 100*CP;
        
--        --guess next pattern correct: 8 , 2
        buttons(3) <= '1';
        wait for 20*CP;
        buttons(3) <= '0';
        wait for 30*CP;
        buttons(1) <= '1';
        wait for 20*CP;
        buttons(3) <= '0';
        wait for 200*CP;
        
        --guess next pattern: 8, 8, 2
        buttons(3) <= '1';
        wait for CP;
        buttons(3) <= '0';
        wait for 5*CP;
        buttons(3) <= '1';
        wait for CP;
        buttons(3) <= '0';
        wait for 5*CP;
        buttons(1) <= '1';
        wait for CP;
        buttons(1) <= '0';
        wait for 120*CP;
        
        --guess wrong:
        buttons(1) <= '1';
        wait for CP;
        buttons(1) <= '0';
        wait for 5*CP; 
        buttons(1) <= '1';
        wait for CP;
        buttons(1) <= '0';
        wait for 100*CP;
        
        --system reset 
        buttons(0) <= '1';
        buttons(3) <= '1';
        wait for 20*CP;
        buttons(0) <= '0';
        buttons(3) <= '0';
        wait for 4*CP;
        
        --system repeat
        buttons(1) <= '1';
        buttons(2) <= '1';
        wait for 20*CP;
        buttons(1) <= '0';
        buttons(2) <= '0';
        wait for 40*CP;
        stop;
    end process;
end Behavioral;