library ieee;
use ieee.std_logic_1164.all;
entity reg_file is 
  generic(
     ADDR_WIDTH : natural := 3;
     DATA_WIDTH : natural := 8
  );
  port(
     clk    : in  std_logic;
     wr_en  : in  std_logic;
     w_addr : in  std_logic_vector(ADDR_WIDTH -1 downto 0);
     r_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
     w_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
     r_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end reg_file;

architecture explicit_arch of reg_file is
    type mem_2d_type is array (0 to 2 ** ADDR_WIDTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    
    signal array_reg : mem_2d_type;
    signal en        : std_logic_vector(ADDR_WIDTH - 1 downto 0);
begin

    -- 4 registers
    process(clk)
    begin
        if rising_edge(clk) then
            if en = "111" then
                array_reg(7) <= w_data;
            elsif en = "110" then
                array_reg(6) <= w_data;
            elsif en = "101" then
                array_reg(5) <= w_data;
            elsif en = "100" then
                array_reg(4) <= w_data;
            elsif en = "011" then
                array_reg(3) <= w_data;
            elsif en = "010" then
                array_reg(2) <= w_data;
            elsif en = "001" then 
                array_reg(1) <= w_data;
            else 
                array_reg(0) <= w_data;
            end if;
        end if;
    end process;

    -- decoding logic for write address
    process(wr_en, w_addr)
    begin
        if (wr_en = '0') then
            en <= (others => '0');
        else
            case w_addr is
                when "000"   => en <= "000";
                when "001"   => en <= "001";
                when "010"   => en <= "010";
                when "011"   => en <= "011";
                when "100"   => en <= "100";
                when "101"   => en <= "101";
                when "110"   => en <= "110";
                when others =>  en <= "111";
            end case;
        end if;
    end process;

        -- read multiplexing
    with r_addr select r_data <=
        array_reg(0) when "000",
        array_reg(1) when "001",
        array_reg(2) when "010",
        array_reg(3) when "011",
        array_reg(4) when "100",
        array_reg(5) when "101",
        array_reg(6) when "110",
        array_reg(7) when others;

end explicit_arch;



