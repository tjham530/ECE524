library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;   
use std.textio.all;                 --for reading from files
use ieee.std_logic_textio.all;      --for reading from files
use std.env.finish;

---------------------------------------------------------------------
--entity signed adder ROM-based function:
    --when we implement, need to select 4 or 8 bits. the rest will
        --handle itself
---------------------------------------------------------------------
entity rom_adder_tb is 
    --n/a
end entity;

architecture Behavior of rom_adder_tb is 
    --instance of component
    component rom_adder is
        generic(
                ADDR_WIDTH : integer := 16;      --2^8 inputs 
                DATA_WIDTH : integer := 9       --4 bits per input    
        );
        port(
                clk    : in std_logic;
                addr_r : in std_logic_vector(ADDR_WIDTH-1 downto 0); 
                data   : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );  
    end component;

    --intermediate signals
    signal clk_tb    : std_logic;
    signal addr_r_tb : std_logic_vector(15 downto 0);
    signal data_tb   : std_logic_vector(8 downto 0);

    --other signals
    constant half_CP : time := 1 ns;

begin 
    uut: rom_adder 
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
        ---------------------------------------------------------------------
        --four bit test code
        ---------------------------------------------------------------------
    
--        --add a = "0011" | b = "0100" => addr_r = "0011_0100" => line 52 + 1 (text files start at line 1)
--        addr_r_tb <= "00110100";
--        wait for 10ns;

--        --add a = "1111" | b = "0000" => addr_r = "0011_1000" => line 56 + 1 (text files start at line 1)
--        addr_r_tb <= "00111000";
--        wait for 10ns;

        ---------------------------------------------------------------------
        --eight bit test code
        ---------------------------------------------------------------------
    
        --add a = 2'x00 and b = 2'x11 => line 17 + 1
        addr_r_tb <= x"0011";
        wait for 10ns;

        --add a = 2'x00 and b = 2'x11 => line 156 + 1
        addr_r_tb <= x"009C";
        wait for 10ns;

        finish;
    end process;


end architecture;