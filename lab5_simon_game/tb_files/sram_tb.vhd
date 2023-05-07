library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.env.stop;

entity sram_tb is
    --n/a
end entity;

architecture Behavioral of sram_tb is

    constant CP      : time := 1ns;
    constant ADDR_WIDTH : NATURAL := 4;
    CONSTANT MAX_DATA : NATURAL := 10;
    CONSTANT DATA_WIDTH : NATURAL := 4;
    
    signal clk    : std_logic;
    signal rst    : std_logic;
    signal wr : std_logic;
    signal rd1 : std_logic;
    signal rd2 : std_logic;
    signal raddr1: std_logic_vector(ADDR_WIDTH -1 downto 0);
    signal raddr2: std_logic_vector(ADDR_WIDTH -1 downto 0);
    signal waddr: std_logic_vector(ADDR_WIDTH -1 downto 0);
    signal din: std_logic_vector(DATA_WIDTH -1 downto 0);
    signal dout1: std_logic_vector(DATA_WIDTH -1 downto 0);
    signal dout2: std_logic_vector(DATA_WIDTH -1 downto 0);
    
begin
    
    tb: entity work.sram
        generic map(
            ADDR_WIDTH => ADDR_WIDTH,
            DATA_WIDTH => DATA_WIDTH,
            MAX_DATA => MAX_DATA
        )
        port map
        (
            clk => clk,
            rst => rst,
            wr => wr, 
            rd1 => rd1,
            rd2 => rd2,
            raddr1 => raddr1, 
            raddr2 => raddr2,
            waddr => waddr,
            din => din, 
            dout1 => dout1,
            dout2 => dout2
        );
    
    --forever clk pulse
    process
    begin 
        clk <= '0';
        wait for CP/2;
        clk <= '1';
        wait for CP/2;
    end process;
    
    --main process
    process 
    begin 
        --init inputs 
        rst <= '0'; 
        wr <= '0';
        rd1 <= '0';
        rd2 <= '0';
        waddr <= "0000";
        raddr1 <= "0000";
        raddr2 <= "0000";
        din <= "0000";
        wait for CP;
        
        --write line high 
        wr <= '1';
        wait for CP;
        
        --write data 
        din <= "0001";
        waddr <= "0001";
        wait for CP;
        din <= "0010";
        waddr <= "0010";
        wait for CP;
        din <= "0011";
        waddr <= "0011";
        wait for CP;
        din <= "0100";
        waddr <= "0100";
        wait for CP;
        din <= "0101";
        waddr <= "0101";
        wait for CP;
        din <= "0110";
        waddr <= "0110";
        wait for CP;
        din <= "0111";
        waddr <= "0111";
        wait for CP;
        din <= "1000";
        waddr <= "1000";
        wait for CP;
        din <= "1001";
        waddr <= "1001";
        wait for CP;
        
        --write low 
        wr <= '0';
        wait for CP;
        
        --read 1 high
        rd1 <= '1';
        wait for CP;
        
        --read data into dout1
        raddr1 <= "0001";
        wait for CP;
        raddr1 <= "0010";
        wait for CP;
        raddr1 <= "0011";
        wait for CP;
        raddr1 <= "0100";
        wait for CP;
        raddr1 <= "0101";
        wait for CP;
        raddr1 <= "0110";
        wait for CP;
        raddr1 <= "0111";
        wait for CP;
        raddr1 <= "1000";
        wait for CP;
        raddr1 <= "1001";
        wait for CP;
        
        --read 1 low, read 2 high 
        rd2 <= '1';
        rd1 <= '0';
        wait for CP;
        
        --read data dout2
        raddr2 <= "0001";
        wait for CP;
        raddr2 <= "0010";
        wait for CP;
        raddr2 <= "0011";
        wait for CP;
        raddr2 <= "0100";
        wait for CP;
        raddr2 <= "0101";
        wait for CP;
        raddr2 <= "0110";
        wait for CP;
        raddr2 <= "0111";
        wait for CP;
        raddr2 <= "1000";
        wait for CP;
        raddr2 <= "1001";
        wait for CP;
        stop;
    end process;
end Behavioral;