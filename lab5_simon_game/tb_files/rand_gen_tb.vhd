library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.env.stop;

entity rand_gen_tb is
--n/a
end entity;

architecture Behavioral of rand_gen_tbs is
    constant bits    : natural := 8;
    constant CP      : time := 10ns;
    signal clk_tb    : std_logic;
    signal rst_tb    : std_logic;
    signal pattern_tb : std_logic_vector(3 downto 0);
    
begin
    
    tb: entity work.rand_gen
        port map
        (
            clk => clk_tb,
            rst => rst_tb,
            pattern => pattern_tb
        );
    
    --forever clk pulse
    process 
    begin 
        clk_tb <= '0';
        wait for CP/2;
        clk_tb <= '1';
        wait for CP/2;
    end process;
    
    --rst and seed inputs
    process
    begin
        rst_tb <= '1';
        wait for CP;
        rst_tb <= '0';
        wait for 20*CP;
        stop;
    end process;

end Behavioral;

