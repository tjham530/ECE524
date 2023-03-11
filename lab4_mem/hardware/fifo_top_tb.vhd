library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity fifo_top_tb is 
    --n/a
end fifo_top_tb;


architecture test of fifo_top_tb is 

    constant ADDR_WIDTH : natural := 3;
    constant DATA_WIDTH : natural := 8;
    constant WORD_TOT : natural := 3;
    constant CP : time := 1ns;
    signal clk, reset, rd, wr : std_logic;
    signal w_data : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal empty : std_logic;
    signal full : std_logic;
    signal r_data : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal almost_empty : std_logic;
    signal almost_full : std_logic;
    signal word_count : std_logic_vector(WORD_TOT downto 0);


begin 

    --port map for fifo_top    
    uut: entity work.fifo_top 
        generic map(
            ADDR_WIDTH => ADDR_WIDTH,
            DATA_WIDTH => DATA_WIDTH,
            WORD_TOT => WORD_TOT
        )
        port map 
        (
            clk => clk,
            reset => reset, 
            rd => rd,
            wr => wr,
            w_data => w_data,
            empty => empty, 
            full => full, 
            r_data => r_data, 
            almost_empty => almost_empty, 
            almost_full => almost_full, 
            word_count => word_count
        );

    --clock generation 
    process 
    begin 
        clk <= '0';
        wait for CP/2;
        clk <= '1';
        wait for CP/2;
    end process; 

    --main code
    process
    begin 
        --init 
        reset <= '0';
        rd <= '0';
        wr <= '0';
        w_data <=  b"0000_0000";
        wait for CP;

        --initial reset 
        reset <= '1';
        wait for CP;

        --wr enable 
        reset <= '0';
        wr <= '1';
        wait for CP;

        --write data 1:
        w_data <= b"1111_1111";
        wait for CP;
        
        --write data 2:
        w_data <= b"1010_1010";
        wait for CP;

        --read data1: 
        wr <= '0'; 
        rd <= '1';
        wait for CP;
        
        --write data3:
        rd <= '0';
        wr <= '1';
        wait for CP;
        w_data <= b"0000_1111";
        wait for CP;
        
        --write data4:
        w_data <= b"1111_0000";
        wait for CP;
        
        --write data5:
        w_data <= x"54";
        wait for CP;
        
        --write data6:
        w_data <= x"67";
        wait for CP;
        
        --write data7:
        w_data <= x"A1";
        wait for CP;
        
        --write data8:
        w_data <= x"BB";
        wait for CP;
        
        --write data9:
        w_data <= x"11";
        wait for CP;
        
        --read data2:
        wr <= '0'; 
        rd <= '1';
        wait for CP;
        rd <= '0';
        wait for CP;
        finish;
    end process;

end architecture;

