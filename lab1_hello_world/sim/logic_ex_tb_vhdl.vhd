library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.stop;

entity logic_ex_tb_vhdl is
    --  Port ( );
end logic_ex_tb_vhdl;

architecture Behavioral of logic_ex_tb_vhdl is
    ----------------------------------------------------------------------------------
    --component: logic_ex
    ----------------------------------------------------------------------------------
    component logic_ex is 
        port(
              SW: in std_logic_vector(1 downto 0);
              LED: out std_logic_vector(3 downto 0)  
        );
    end component;
    
    ----------------------------------------------------------------------------------
    --intermediate signals:
    ----------------------------------------------------------------------------------
    signal SW: std_logic_vector(1 downto 0);
    signal LED: std_logic_vector(3 downto 0);
    
begin
    ----------------------------------------------------------------------------------
    --Unit Under Test: 
    ----------------------------------------------------------------------------------
    uut: logic_ex port map(SW => SW, LED => LED);
    
    ----------------------------------------------------------------------------------
    --Testing: changing switch values
    ----------------------------------------------------------------------------------   
    process
    begin
        SW <= "00";
	    wait for 100ns;
        switch_change: for j in 1 to 4 loop
            SW <= std_logic_vector(to_unsigned(j, SW'length));
            wait for 100ns;
        end loop;   
        report "PASS: logic_ex test PASSED!";
        stop;         
    end process;
    
    process(LED)
    begin
	   if LED /= "XXXX" then
            --inverter
            if((NOT SW(0)) /= LED(0)) then
                report "FAIL: NOT Gate mismatch";
                stop;
            end if;
            
            --and gate
            if((SW(1) AND SW(0)) /= LED(1)) then
                report "FAIL: AND Gate mismatch";
                stop;
            end if;
            
            --or gate
            if((SW(1) OR SW(0)) /= LED(2)) then
                report "FAIL: OR Gate mismatch";
                stop;       
            end if;
            
            --xor gate
            if ((SW(1) XOR SW(0)) /= LED(3)) then
                report "FAIL: XOR Gate mismatch";
                stop;
            end if;
	   end if;
    end process;                                                                                                                           
end Behavioral;
