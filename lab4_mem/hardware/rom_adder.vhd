library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;   
use std.textio.all;                 --for reading from files
use ieee.std_logic_textio.all;      --for reading from files

---------------------------------------------------------------------
--entity signed adder ROM-based function:
    --when we implement, need to select DATA_WIDTH as 5 or 9 bits 
---------------------------------------------------------------------
entity rom_adder is
    generic(
            ADDR_WIDTH : integer := 16;      --2^8 inputs 
            DATA_WIDTH : integer := 9       --4 bits per input + OVRFLW   
    );
    port(
            clk    : in std_logic;
            addr_r : in std_logic_vector(ADDR_WIDTH-1 downto 0); 
            data   : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );  

end entity;

architecture Behavioral of rom_adder is
    ---------------------------------------------------------------------
    --definitions for array
    ---------------------------------------------------------------------
    constant ROM_DEPTH : integer := 2**ADDR_WIDTH; 
    type rom_type is array (0 to (2**ADDR_WIDTH)-1) of std_logic_vector((DATA_WIDTH-1) downto 0);   --define 64 rows with 4 bit numbers in each
    
    ---------------------------------------------------------------------
    --build rom array
    ---------------------------------------------------------------------
    impure function read_rom return rom_type is
        file text_file_5_bit : text open READ_MODE is "C:/Users/Tyler/Desktop/LUTs/LUT_5bit.txt";
        file text_file_9_bit : text open READ_MODE is "C:/Users/Tyler/Desktop/LUTs/LUT_9bit.txt";
        variable file_line   : line;
        variable rom_content : rom_type;                                    --rom array place holder 
        variable value : std_logic_vector(DATA_WIDTH-1 downto 0);           --place holder for num accessed
    begin 
        for i in 0 to ROM_DEPTH-1 loop 
            if ADDR_WIDTH = 8 then
                readline(text_file_5_bit, file_line);       --access file line
            else 
                readline(text_file_9_bit, file_line);
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
    --rom access from pseudo-decoder input 
    ---------------------------------------------------------------------
    --addresses are by line of the text file
    --read the addr_r and find the line connected to it 
        --ex: add a = "0001" and b = "0100", then we are going to line "0001_0100", or line 20
    process(clk)
    begin
        if rising_edge(clk) then
            data <= rom(to_integer(unsigned(addr_r)));      --read rom position of addr_r and assign to data
        end if;
    end process;
    
end Behavioral;
