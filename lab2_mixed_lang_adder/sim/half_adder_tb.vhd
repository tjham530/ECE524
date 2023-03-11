library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity half_adder_tb is
--  Port ( );
end half_adder_tb;

architecture Behavioral of half_adder_tb is

component half_adder is
   Port ( x : in STD_LOGIC;
          y : in STD_LOGIC;
          sum : out STD_LOGIC;
          carry : out STD_LOGIC);
end component;

signal x_tb : STD_LOGIC;
signal y_tb : STD_LOGIC;
signal sum_tb :  STD_LOGIC;
signal carry_tb : STD_LOGIC;
signal clk_tb: std_logic;

begin

uut: half_adder port map (
   x => x_tb,
   y => y_tb,
   sum => sum_tb,
   carry => carry_tb);

process
begin
clk_tb <= '1';
wait for 5ns;
clk_tb <= '0';
wait for 5ns;

end process;

process
   begin
       x_tb <= '0';
       y_tb <= '0';
       wait for 10 ns;
       x_tb <= '0';
       y_tb <= '1';
       wait for 10 ns;
       x_tb <= '1';
       y_tb <= '0';
       wait for 10 ns;
       x_tb <= '1';
       y_tb <= '1';
       wait;
end process;

end Behavioral;


