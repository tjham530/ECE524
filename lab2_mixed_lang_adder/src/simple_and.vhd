library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity simple_and is
   Port(
       a: in STD_LOGIC;
       b: in STD_LOGIC;
       c: out STD_LOGIC);
end simple_and;

architecture Behavioral of simple_and is

begin

   c <= a AND b;
  
end Behavioral;
