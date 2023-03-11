library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity fifo_ctrl_tb is
end fifo_ctrl_tb;

architecture fifo_ctrl_test of fifo_ctrl_tb is

    --tb signals 
    signal clk_tb, reset_tb : std_logic := '0';
    signal rd_tb, wr_tb : std_logic := '0';
    signal empty_tb, full_tb: std_logic;
    signal almost_full_tb : std_logic;
    signal almost_empty_tb : std_logic;
    signal word_count_tb : std_logic_vector(3 downto 0);
    signal w_addr_tb : std_logic_vector(2 downto 0);
    signal r_addr_tb : std_logic_vector(2 downto 0);

    --other signals
    constant CP : time := 1 ns;
    constant ADDR_WIDTH : integer := 3;
    constant DATA_WIDTH : integer := 8;
    constant WORD_TOT : integer := 3;

begin

    UUT: entity work.fifo_ctrl 
        generic map
        (
            ADDR_WIDTH => ADDR_WIDTH,
            DATA_WIDTH => DATA_WIDTH,
            WORD_TOT => WORD_TOT
        )
        port map
        (
            clk => clk_tb,
            reset => reset_tb,
            rd => rd_tb,
            wr => wr_tb,
            empty => empty_tb,
            full => full_tb,
            almost_empty => almost_empty_tb,
            almost_full => almost_full_tb,
            word_count => word_count_tb,
            w_addr => w_addr_tb,
            r_addr => r_addr_tb
        );

  --clock generation
    process 
    begin
        clk_tb <= '0';
        wait for CP/2;
        clk_tb <= '1';
        wait for CP/2;
    end process;

    --main process:
    process 
    begin 
        --reset to start
        reset_tb <= '1';
        wait for CP;
        reset_tb <= '0';
        wait for CP;

        --wr for 8
        wr_tb <= '1';
        wait for CP;
        wr_tb <= '0';
        wait for CP;
        wr_tb <= '1';
        wait for CP;
        wr_tb <= '0';
        wait for CP;
        wr_tb <= '1';
        wait for CP;
        wr_tb <= '0';
        wait for CP;
        wr_tb <= '1';
        wait for CP;
        wr_tb <= '0';
        wait for CP;
        wr_tb <= '1';
        wait for CP;
        wr_tb <= '0';
        wait for CP;
        wr_tb <= '1';
        wait for CP;
        wr_tb <= '0';
        wait for CP;
        wr_tb <= '1';
        wait for CP;
        wr_tb <= '0';
        wait for CP;
        wr_tb <= '1';
        wait for CP;
        wr_tb <= '0';
        wait for CP;


        --read for 4
        rd_tb <= '1';
        wait for CP;
        rd_tb <= '0';
        wait for CP;
        rd_tb <= '1';
        wait for CP;
        rd_tb <= '0';
        wait for CP;
        rd_tb <= '1';
        wait for CP;
        rd_tb <= '0';
        wait for CP;
        rd_tb <= '1';
        wait for CP;
        rd_tb <= '0';
        wait for CP;
        finish;
    end process;
end fifo_ctrl_test;

--assumed error: something to do with the port mapping / generic
    --not even saba's code is working at all
--place intermediate values into sim view and track problem
--place intermediate values into sim view and track problem