library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity half_adder is
   Port ( x : in STD_LOGIC;
          y : in STD_LOGIC;
          sum : out STD_LOGIC;
          carry : out STD_LOGIC);
end half_adder;

architecture Behavioral of half_adder is

component simple_xor is
   Port ( a : in STD_LOGIC;
          b : in STD_LOGIC;
          c : out STD_LOGIC);
end component;

component simple_and is
   Port ( a : in STD_LOGIC;
          b : in STD_LOGIC;
          c : out STD_LOGIC);
end component;

begin 
    xor_i: simple_xor port map(
       a => x,
       b => y,
       c => sum
    );
    
    and_i: simple_and port map(
       a => x,
       b => y,
       c => carry
    );
    
end Behavioral;