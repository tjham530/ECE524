library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;   
use std.textio.all;                 --for reading from files
use ieee.std_logic_textio.all;      --for reading from files
use std.env.finish;

entity rom_temp_conversion_tb is
    --n/a
end entity;

architecture Behavior of rom_temp_conversion_tb is
    
    --intermediate signals
    signal clk_tb    : std_logic;
    signal addr_r_tb : std_logic_vector(6 downto 0);
    signal data_tb   : std_logic_vector(7 downto 0);

    --other signals
    constant half_CP : time := 1 ns;
    constant ADDR_WIDTH : natural := 7;
    constant DATA_WIDTH : natural := 8;
    
    
begin
    uut: entity  work.rom_temp_conversion 
        generic map
        (
            ADDR_WIDTH => ADDR_WIDTH,
            DATA_WIDTH => DATA_WIDTH
        )
        port map
        (
            clk => clk_tb,
            addr_r => addr_r_tb,
            data => data_tb
        );

    --clock generation
    process 
    begin
        clk_tb <= '0';
        wait for half_CP;
        clk_tb <= '1';
        wait for half_CP;
    end process;

    --input values:
    process
    begin
        --check line 160
        addr_r_tb <= "0001100";
        wait for 10ns;
   
        --check line 78
        addr_r_tb <= "0000111";
        wait for 10ns;
   
        finish;
    end process;
end architecture;