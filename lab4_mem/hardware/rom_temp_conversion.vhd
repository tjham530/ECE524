library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;   
use std.textio.all;                 --for reading from files
use ieee.std_logic_textio.all;      --for reading from files

-- F => C addr range: 212-32   = 180
-- C to F => addr range: 100-0 = 100 

---------------------------------------------------------------------
--entity function:
    --if ADDR_WIDTH = 8 => F to C
    --else: C to F
---------------------------------------------------------------------
entity rom_temp_conversion is
    generic(
            ADDR_WIDTH : INTEGER := 8;
            DATA_WIDTH : INTEGER := 8       --data has general format of 8 bits
    );
    port(
            clk    : in std_logic;
            addr_r : in std_logic_vector(ADDR_WIDTH-1 downto 0); 
            data   : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );  

end entity;

architecture Behavioral of rom_temp_conversion is
    ---------------------------------------------------------------------
    --definitions for array
    ---------------------------------------------------------------------
    type rom_type is array (0 to (2**ADDR_WIDTH)-1)
        of std_logic_vector((DATA_WIDTH-1) downto 0);   --define 64 rows with 4 bit numbers in each
    constant ROM_DEPTH : integer := 2**ADDR_WIDTH; 
  
    ---------------------------------------------------------------------
    --build rom array
    ---------------------------------------------------------------------
    impure function read_rom return rom_type is
        file text_file_CTF : text open READ_MODE is "/Desktop/far_LUT.txt";
        file text_file_FTC : text open READ_MODE is "/Desktop/cel_LUT.txt";

        variable file_line   : line;
        variable rom_content : rom_type;                                    --rom array place holder 
        variable value : std_logic_vector(DATA_WIDTH-1 downto 0);           --place holder for num accessed
    begin 
        for i in 0 to ROM_DEPTH-1 loop 
            if ADDR_WIDTH = 8 then
                readline(text_file_FTC, file_line);       --access file line
            else 
                readline(text_file_CTF, file_line);
            end if;
            read(file_line, value);                         --read file line
            rom_content(i) := value;                        --save to temp array
        end loop;
        return rom_content;                                 --send to rom array
    end function;
    
    --signal that immediately gets function return value
    signal rom : rom_type := read_rom;

begin
    ---------------------------------------------------------------------
    --access temp conversion data
    ---------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            data <= rom(to_integer(unsigned(addr_r)));      --read rom position of addr_r and assign to data
        end if;
    end process;
    
end Behavioral;
