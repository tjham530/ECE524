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
        clk, rst : in std_logic;                                --stops generation upon user entering guess
        pattern   : out std_logic_vector (3 downto 0)            --output is now two bits => designates which LED to light
    );
end rand_gen;

architecture Behavioral of rand_gen is
    signal currstate  : std_logic_vector(bits-1 downto 0);
    signal nextstate  : std_logic_vector(bits-1 downto 0);
    signal feedback   : std_logic;
    signal seed       : std_logic_vector(7 downto 0);
    signal rand_num   : unsigned(1 downto 0);
    signal prev_num   : unsigned(1 downto 0);
begin
    
    seed <= x"44";

    rand_gen: process(clk, rst)
    begin
        if rst = '1' then 
            currstate <= seed;
        elsif rising_edge(clk) then
            currstate <= nextstate;  
        end if;
    end process;

    feedback <= currstate(4) xor currstate(3) xor currstate(2) xor currstate(0);
    nextstate <=  feedback & currstate(bits-1 downto 1);
    
    rand_num <= unsigned(nextstate(6 downto 5));
    prev_num <= unsigned(currstate(6 downto 5));
    
    pattern_sel: process(rst, rand_num, prev_num)
    begin 
        if rst = '1' then 
            pattern <= "1000";
        else
            if rand_num = "01" and prev_num /= "01" then 
                pattern <= "0001";
            elsif rand_num = "10" and prev_num /= "10" then 
                pattern <= "0010";
            elsif rand_num = "11" and prev_num /= "11" then 
                pattern <= "0100";
            else 
                pattern <= "1000";
            end if;
         end if;
    end process;
    
end Behavioral;