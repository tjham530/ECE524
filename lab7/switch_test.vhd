LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;

entity switch_test is 
    -- generic(
    --         res_w : integer : 1920;
    --         res_h : integer : 1080
    -- );
    port (
            sw : in STD_LOGIC_VECTOR(3 downto 0);
            led : out STD_LOGIC_VECTOR(3 downto 0)
    );
end entity;

ARCHITECTURE test of switch_test is 

begin   

    led <= sw;

end ARCHITECTURE;