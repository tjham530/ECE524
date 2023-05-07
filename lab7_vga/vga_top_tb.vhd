LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
use std.env.stop;

entity vga_top_tb is 

end entity;

architecture test  of vga_top_tb is
    signal CLK_I : STD_LOGIC := '0';
    signal sw   : std_logic_vector(3 downto 0) := "0000";
    signal VGA_HS_O : std_logic;
    signal VGA_VS_O : std_logic;
    signal VGA_R : std_logic_vector(3 downto 0);
    signal VGA_B : std_logic_vector(3 downto 0);
    signal VGA_G : std_logic_vector(3 downto 0);
    signal btn : std_logic_vector(3 downto 0) := "0000";

    constant CP : time := 1ns;
    constant UT : time := 4us;
begin
    UUT: entity work.vga_top 
        port map(
            CLK_I => CLK_I,
            sw => sw, 
            btn => btn,
            VGA_HS_O => VGA_HS_O,
            VGA_VS_O => VGA_VS_O,
            VGA_R => VGA_R,
            VGA_B => VGA_B,
            VGA_G => VGA_G
        );

    --forever clk pulse
    process
    begin 
        CLK_I <= '0';
        wait for CP/2;
        CLK_I <= '1';
        wait for CP/2;
    end process;

    --main process
    process 
    begin 
        --init 
        sw <= "0000";
        btn <= "0000";
        wait for UT;

        --Case 2: red
        sw <= "0001";
        wait for UT;
        --case 3: green
        sw <= "0010";
        wait for UT;
        --case 4: three RGB regions 
        sw <= "0100";
        wait for UT;
        --case 5: 8 regions w/ diff colors 
        sw <= "0101";
        wait for UT;

        --case 6: shades of gray
        sw <= "0110";
        wait for UT;

        --case 7: horz stripes 
        sw <= "0111";
        wait for UT;

        --case 8:vert stripes 
        sw <= "1000";
        wait for UT;

        --case 9: checker board
        sw <= "1001";
        wait for UT;

        --case 10: checker with inner 
        sw <= "1010";
        wait for UT;

        --case 11: moving ball
        sw <= "1110";
        wait for UT;

        stop;
    end process;
end architecture;