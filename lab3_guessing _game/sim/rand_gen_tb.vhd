library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.env.stop;

entity rand_gen_tb is
--n/a
end rand_gen_tb;

architecture Behavioral of rand_gen_tb is
    constant bits    : natural := 8;
    constant CP      : time := 10ns;
    signal clk_tb    : std_logic;
    signal rst_tb    : std_logic;
    signal ENA_tb    : std_logic := '0';
    signal seed_tb   : std_logic_vector(bits-1 downto 0) := b"1010_1010";
    signal output_tb : std_logic_vector(3 downto 0);
    
begin
    
    tb: entity work.rand_gen
        port map
        (
            clk => clk_tb,
            rst => rst_tb,
            ENA => ENA_tb,
            seed => seed_tb,
            output => output_tb
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
        wait for 10*CP;
        ENA_tb <= '1';
        wait for CP;
        ENA_tb <= '0';
        wait for 10*CP;
        stop;
    end process;

end Behavioral;