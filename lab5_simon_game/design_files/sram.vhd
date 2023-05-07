LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
ENTITY sram IS
    GENERIC (
        ADDR_WIDTH : NATURAL := 4; --max 10 values => 4 bits to cover
        MAX_DATA : NATURAL := 10;
        DATA_WIDTH : NATURAL := 4 --data is max 4 bits 
    );
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        wr : IN STD_LOGIC;
        rd1 : IN STD_LOGIC;
        rd2: IN STD_LOGIC;
        raddr1 : in STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
        raddr2 : in STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
        waddr : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
        din : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0); --data => 4 bit pattern number
        dout1 : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        dout2 : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE design OF sram IS

    --make array for SRAM memory 1
    TYPE RAM_array IS ARRAY (0 TO MAX_DATA) OF STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL RAM_sig1 : RAM_array;
    SIGNAL RAM_sig2 : RAM_array;

    --intermediate signals 
    SIGNAL dout_int1 : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL dout_int2 : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

BEGIN

    port1: PROCESS(clk, rst, wr, rd1)
    BEGIN
        IF rst = '1' THEN
            RAM_sig1 <= (OTHERS => (OTHERS => '0')); --reset memory 
        ELSIF rising_edge(clk) THEN
            IF wr = '1' THEN
                RAM_sig1(to_integer(unsigned(waddr))) <= din; --din placed in memory 
            ELSIF rd1 = '1' THEN
                dout_int1 <= RAM_sig1(to_integer(unsigned(raddr1))); --dout read from memory 
            ELSE
                RAM_sig1 <= RAM_sig1;
            END IF;
        END IF;
    END PROCESS;

    dout1 <= dout_int1;
    dout2 <= dout_int2;

    port2: PROCESS(clk, rst, wr, rd2)
    BEGIN
        IF rst = '1' THEN
            RAM_sig2 <= (OTHERS => (OTHERS => '0')); --reset memory 
        ELSIF rising_edge(clk) THEN
            IF wr = '1' THEN
                RAM_sig2(to_integer(unsigned(waddr))) <= din; --din placed in memory 
            ELSIF rd2 = '1' THEN
                dout_int2 <= RAM_sig2(to_integer(unsigned(raddr2))); --dout read from memory 
            ELSE
                RAM_sig2 <= RAM_sig2;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE;