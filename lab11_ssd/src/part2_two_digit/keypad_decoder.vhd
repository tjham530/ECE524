library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity keypad_decoder is
--    generic(
--        SYS_CLK : integer := 50000000; 
--        COL_WAIT_TIME : integer := 1
--    );
    port (
        clk : in STD_LOGIC;
        rst: in std_logic;
        row : in STD_LOGIC_VECTOR (3 downto 0);
        col : out STD_LOGIC_VECTOR (3 downto 0);
        decode_out : out STD_LOGIC_VECTOR (3 downto 0);
        is_a_key_pressed: out std_logic
       );
end keypad_decoder;

architecture Behavioral of keypad_decoder is

   signal sclk : STD_LOGIC_VECTOR(19 downto 0);
   signal decode_reg: std_logic_vector(3 downto 0);
   signal is_a_key_pressed_reg: std_logic;
   
   constant col_wait : integer := (100000);   --clk_frew * (desired wait time) = desired clks
   constant row_wait : integer := 8;
   
begin 
   -------------------------------------------------------------------------------------
   --main controller:
   -------------------------------------------------------------------------------------
   process (clk, rst)
   begin
       if rst = '1' then
           decode_reg <= (others => '0');
           is_a_key_pressed_reg <= '0';
           col <= (others => '0');
           sclk <= (others => '0');
       elsif rising_edge(clk) then
           if sclk = col_wait then        --pull down col 1
               col <= "0111";
               sclk <= sclk + 1;
           elsif sclk = (col_wait + row_wait) then --check rows in col 1
               --R1
               if row = "0111" then
                   decode_reg <= "0001"; --1
                   is_a_key_pressed_reg <= '1';
                   --R2
               elsif row = "1011" then
                   decode_reg <= "0100"; --4
                   is_a_key_pressed_reg <= '1';
                   --R3
               elsif row = "1101" then
                   decode_reg <= "0111"; --7
                   is_a_key_pressed_reg <= '1';
                   --R4
               elsif row = "1110" then
                   decode_reg <= "0000"; --0
                   is_a_key_pressed_reg <= '1';
               else
                   decode_reg <= decode_reg;
                   is_a_key_pressed_reg <= '0';
               end if;
               sclk <= sclk + 1;
            elsif sclk = (2*col_wait) then    --pull down col 2
               --C2
               col <= "1011";
               sclk <= sclk + 1;
               -- check row pins
            elsif sclk = ((2*col_wait)+row_wait) then --check rows in col 2
               --R1
               if row = "0111" then
                   decode_reg <= "0010"; --2
                   is_a_key_pressed_reg <= '1';
               --R2
               elsif row = "1011" then
                   decode_reg <= "0101"; --5
                   is_a_key_pressed_reg <= '1';
                   --R3
               elsif row = "1101" then
                   decode_reg <= "1000"; --8
                   is_a_key_pressed_reg <= '1';
                   --R4
               elsif row = "1110" then
                   decode_reg <= "1111"; --F
                   is_a_key_pressed_reg <= '1';
               else
                   decode_reg <= decode_reg;
                   is_a_key_pressed_reg <= '0';
               end if;
               sclk <= sclk + 1;
           elsif sclk = (3*col_wait) then
               --C3
               col <= "1101";
               sclk <= sclk + 1;
               -- check row pins
           elsif sclk = ((3*col_wait)+row_wait) then
               --R1
               if row = "0111" then
                   decode_reg <= "0011"; --3  
                   is_a_key_pressed_reg <= '1';
                   --R2
               elsif row = "1011" then
                   decode_reg <= "0110"; --6
                   is_a_key_pressed_reg <= '1';
                   --R3
               elsif row = "1101" then
                   decode_reg <= "1001"; --9
                   is_a_key_pressed_reg <= '1';
                   --R4
               elsif row = "1110" then
                   decode_reg <= "1110"; --E
                   is_a_key_pressed_reg <= '1';
               else
                   decode_reg <= decode_reg;
                   is_a_key_pressed_reg <= '0';
               end if;
               sclk <= sclk + 1;
               --4ms
           elsif sclk = (4*col_wait) then
               --C4
               col <= "1110";
               sclk <= sclk + 1;
               -- check row pins
           elsif sclk = ((4*col_wait)+row_wait) then
               --R1
               if row = "0111" then
                   decode_reg <= "1010"; --A
                   is_a_key_pressed_reg <= '1';
                   --R2
               elsif row = "1011" then
                   decode_reg <= "1011"; --B
                   is_a_key_pressed_reg <= '1';
                   --R3
               elsif row = "1101" then
                   decode_reg <= "1100"; --C
                   is_a_key_pressed_reg <= '1';
                   --R4
               elsif row = "1110" then
                   decode_reg <= "1101"; --D
                   is_a_key_pressed_reg <= '1';
               else
                   decode_reg <= decode_reg;
                   is_a_key_pressed_reg <= '0';
               end if;
               sclk <= (others=>'0');
           else
               sclk <= sclk + 1;
           end if;
        end if;
   end process;
   
   ---------------------------------------------------------------------------
   --comb assignments
   ---------------------------------------------------------------------------
   is_a_key_pressed <= is_a_key_pressed_reg;
   decode_out <= decode_reg;

end Behavioral;











