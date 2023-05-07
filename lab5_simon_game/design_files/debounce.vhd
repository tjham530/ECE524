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
        rst    : in std_logic;
        result : out std_logic); --debounced signal
end debounce;

architecture Behavioral of debounce is
    signal cnt_set  : std_logic;                      --output of single edge detector
    signal d_3      : std_logic;                      -- input of third FF
    signal ENA      : std_logic;    
--    constant debounce_per : integer := 1250000;     --10ms wait period


     constant debounce_per : integer := 10;      --sim data value
begin

    --component: signal pulse detector 
    single_pulse_detector: entity work.single_pulse_detector
        port map
        (
            clk => clk,
            rst => rst,
            input_signal => button,
            output_pulse => cnt_set,        --output of AND gate into counter
            q_2 => d_3
        );
    
    --component: clock counter 
    counter: process(cnt_set, clk, button)
        variable count: integer := 0;
        variable ena_ind: integer := 0;
    begin 
        if cnt_set = '1' then --rising edge => start debounce count 
            count := 0;
            ENA <= '0';
        elsif rising_edge(clk) then  --count while ENA not high
            if button = '1' then 
                if count = debounce_per then        --wait for debounce time then enable
                    ENA <= '1';
                end if;
                count := count + 1;
            else 
                ENA <= '0';
                count := 0;
            end if;
        end if;
    end process;
   

    --component: final flip flop #3
    FF3: process(clk, rst, ENA)
    begin 
        if rst = '1' or ENA = '0' then
            result <= '0';
        elsif rising_edge(clk) and ENA = '1' then 
            result <= d_3;                      --D3 gets rising edge on clock pulse
        end if;
    end process;
end Behavioral;


