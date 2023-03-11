library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity rand_gen is
    generic
    (
        bits : natural := 8
    );
    port
    (
        clk, rst : in std_logic;
        ENA      : in std_logic;                                --stops generation upon user entering guess
--        seed     : in std_logic_vector (bits-1 downto 0);
        output   : out std_logic_vector (3 downto 0)
    );
end rand_gen;

architecture Behavioral of rand_gen is
    signal currstate  : std_logic_vector(bits-1 downto 0);
    signal nextstate  : std_logic_vector(bits-1 downto 0);
    signal feedback   : std_logic;
    signal gen_toggle : std_logic;
    signal seed       : std_logic_vector(7 downto 0);
begin
    
    seed <= x"44";

    rand_gen: process(clk, rst, ENA)
    begin
        if rst = '1' then 
            currstate <= seed;
            gen_toggle <= '0';
        elsif ENA = '1' then
            gen_toggle <= '1';
        elsif rising_edge(clk) and gen_toggle = '0' then
            currstate <= nextstate;  
        end if;
    end process;

    feedback <= currstate(4) xor currstate(3) xor currstate(2) xor currstate(0);
    nextstate <=  feedback & currstate(bits-1 downto 1);
    output <= currstate(7 downto 4);
end Behavioral;