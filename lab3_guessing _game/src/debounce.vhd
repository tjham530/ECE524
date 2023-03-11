library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity debounce is
    generic
    (
        clk_freq    : integer := 50_000_000; --system clock frequency in Hz
        stable_time : integer := 10);        --time button must remain stable in ms
    port
    (
        clk    : in std_logic;   --input clock
        button : in std_logic;   --input signal to be debounced
        result : out std_logic); --debounced signal
end debounce;

architecture Behavioral of debounce is
    signal cnt_set  : std_logic;                      --output of single edge detector
    signal d_3      : std_logic;                      -- input of third FF
    signal q_cnt    : std_logic;                      --output of clk counter
    signal ENA      : std_logic;           
    
begin

    --component: signal pulse detector 
    single_pulse_detector: entity work.single_pulse_detector
        port map
        (
            clk => clk,
            input_signal => button,
            output_pulse => cnt_set,
            q_2 => d_3
        );
    
    --component: clock counter 
    counter: process(cnt_set, clk, ENA)
        variable count: integer := 0;
    begin 
        if cnt_set = '1' then 
            count := 0;
        elsif count = (10/1000)*clk_freq then  --500K clock wait = 10ms 
            q_cnt <= '1';
        elsif (rising_edge(clk) and (not ENA = '1')) then  
            count := count + 1;
        end if;
    end process;
    
    ENA <= q_cnt;

    --component: final flip flop #3
    FF3: process(clk, ENA)
    begin 
        if rising_edge(clk) and ENA = '1' then 
            result <= d_3;
        end if;
    end process;
end Behavioral;


