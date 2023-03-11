library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_module_tb is
--  Port ( );
end top_module_tb;

architecture Behavioral of top_module_tb is
constant n : integer := 2;

signal x_tb:std_logic_vector(n-1 downto 0);
signal y_tb:std_logic_vector(n-1 downto 0);
signal clk_tb:std_logic;
signal rst_tb:std_logic;
signal s_tb:std_logic_vector(n downto 0);

constant CP : time := 10ns;

component top_module
   Port ( x : in STD_LOGIC_VECTOR (n-1 downto 0);
          y : in STD_LOGIC_VECTOR (n-1 downto 0);
          clk : in STD_LOGIC;
          rst : in STD_LOGIC;
          s : out STD_LOGIC_VECTOR (n downto 0));
end component top_module;

begin

top_module_i: top_module
port map(
   x => x_tb,
   y => y_tb,
   clk => clk_tb,
   rst => rst_tb,
   s => s_tb
);

process
begin
clk_tb <= '1';
wait for CP/2;
clk_tb <= '0';
wait for CP/2;
end process;

process
begin
wait for CP;
rst_tb <= '1';
wait for CP;
rst_tb <= '0';
wait;
end process;

process
begin
   wait for 4*CP;
   x_tb <= "01";
   y_tb <= "01";
   wait for CP;
   x_tb <= "10";
   y_tb <= "01";
   wait for CP;
   x_tb <= "10";
   y_tb <= "10";
   wait for CP;
   x_tb <= "11";
   y_tb <= "11";
   wait for CP;
   x_tb <= "10";
   y_tb <= "10";
   wait for CP;
   x_tb <= "00";
   y_tb <= "11";
   wait;
end process;

end Behavioral;

