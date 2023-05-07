`timelibrary IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-----------------------------------------------------------------------------
--ENTITY: 
    --function:
        --this code will receive an alert that a btn has been pressed
        --it will then send out a pulse to the main code that is x clks long
        --this code is meant to toggle state machines primarily
-----------------------------------------------------------------------------
entity debounce_pulse is
   generic(
       DEBOUNCE_PERIOD : integer := 63000000; --clocks to wait for dbn pulse to send
       PULSE_PER : integer := 1
   );
    port
    (
        clk    : in std_logic;   --input clock
        rst    : in std_logic;
        button : in std_logic;   --input signal to be debounced
        result : out std_logic      --debounced signal
     ); 
end debounce_pulse;

architecture Behavioral of debounce_pulse is
    --signals
    signal detector  : std_logic;           --output of single edge detector   
    signal pulse_toggle : std_logic;        --toggles output pulse 
    signal  pulse_out : std_logic;
    signal dbn_count : integer;
    signal pulse_count : integer; 

begin
    --------------------------------------------------------------------------
    --INST
    --------------------------------------------------------------------------
    --component: signal pulse detector 
    single_pulse_detector: entity work.single_pulse_detector
        port map
        (
            clk => clk,
            rst => rst,
            input_signal => button,
            output_pulse => detector
        );
    
    --------------------------------------------------------------------------
    --CLOCK COUNTER FOR WAIT PER AND PULSE OUT
    --------------------------------------------------------------------------
    counter: process(detector, clk, rst)
    begin 
        if ((detector = '1') or (rst = '1')) then --rst or pulse detected begin
            dbn_count <= 0;
            pulse_count <= 0;
            pulse_out <= '0';
            pulse_toggle <= '0';
        elsif rising_edge(clk) then --ctrl output pulse 
            if (pulse_toggle = '1') then 
                if (pulse_count = PULSE_PER) then --wait x clocks then kill pulse
                    pulse_toggle <= '0';
                    pulse_out <= '0';
                else 
                    pulse_out <= '1';
                    pulse_count <= pulse_count + 1;
                end if;
            else   --ctrl debounce period 
                if dbn_count = DEBOUNCE_PERIOD then    
                    pulse_toggle <= '1';    
                else 
                    dbn_count <= dbn_count + 1;
                    pulse_toggle <= '0';
                end if;
            end if;
        end if;
    end process;
    
    --reg to port
    result <= pulse_out;

end Behavioral;
