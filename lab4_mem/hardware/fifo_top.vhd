library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_top is
    generic(
        ADDR_WIDTH : integer := 3;      --8 possible words 
        DATA_WIDTH : integer := 8;
        WORD_TOT   : integer := 3       --should equal addr width
    );
    port(
        clk, reset : in std_logic;
        rd, wr : in std_logic;
        w_data : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        empty : out std_logic;
        full : out std_logic;
        r_data : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        almost_empty : out std_logic;
        almost_full : out std_logic;
        word_count: out std_logic_vector(WORD_TOT DOWNTO 0)
    );
end fifo_top;

architecture reg_file_arch of fifo_top is
    signal full_tmp : std_logic;
    signal wr_en : std_logic;
    signal w_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal r_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
begin
    -- write enabled only when FIFO is not full
    wr_en <= wr and (not full_tmp);
    full <= full_tmp;

    -- instantiate fifo control unit
    ctrl_unit : entity work.fifo_ctrl
        generic map
        (
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
            empty => empty,
            full => full_tmp,
            w_addr => w_addr,
            r_addr => r_addr,
            almost_empty => almost_empty,
            almost_full => almost_full,
            word_count => word_count
        );
    -- instantiate register file
    reg_file_unit : entity work.reg_file
        generic map
        (
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        port map
        (
            clk => clk,
            w_addr => w_addr,
            r_addr => r_addr,
            w_data => w_data,
            r_data => r_data,
            wr_en => wr_en
        );
        
end reg_file_arch;
