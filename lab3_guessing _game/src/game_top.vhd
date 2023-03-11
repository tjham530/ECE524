library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity top_module is
    port
    (
        clk        : in std_logic;                       --clk
        rst        : in std_logic;                       --button 0: sys reset
        start      : in std_logic;                       --button 1: start game
        enter      : in std_logic;                       --button 2: enter
        show       : in std_logic;                       --button 3: reveal numbers
        switches   : in std_logic_vector (3 downto 0);   --guessing input
        leds       : out std_logic_vector (3 downto 0);  --display correct value
        red_led    : out std_logic;                      --guess to access 
        blue_led   : out std_logic;                      --guess too low
        green_led  : out std_logic                       --correct guess
    );
end top_module;

architecture Behavioral of top_module is
    
    --clk division constants: 
    constant base_clk      : integer := 125_000_000;
    constant adjusted_clk  : integer := base_clk/4;         --divide by two for high/low and another two for base 2Hz

    --enum types for states:
    type states is (st0, st1, st2, st3);
    signal currstate  : states;
    signal nextstate  : states;

    --intermediate signals:
--    signal seed_int   : std_logic_vector(7 downto 0);           --sets the seed value for rand gen
    signal rand_out   : std_logic_vector(3 downto 0);           --output of rand_gen
    signal button_out : std_logic_vector(3 downto 0);           --value receving from debounce entities 
    signal io_green   : std_logic := '0';                       --signal to overwrite mult drivers
    signal cnt        : integer;
begin
    ------------------------------------------------------------------------------------------------
    --component instantiation
    ------------------------------------------------------------------------------------------------
    --total sys reset
    rst_debounce: entity work.debounce 
        port map
        (
            clk => clk,
            button => rst,
            result => button_out(0)             --rst = bit 0
        );
    
    --debounce for start (button 1)
    B1_debounce: entity work.debounce 
        port map
        (
            clk => clk,
            button => start,
            result => button_out(1)             --start = bit 1
        );
        
    --debounce for enter (button 2)
    B2_debounce: entity work.debounce 
        port map
        (
            clk => clk,
            button => enter,
            result => button_out(2)             --enter = bit 2
        ); 
        
    --debounce for show (button 3)
    B3_debounce: entity work.debounce 
        port map
        (
            clk => clk,
            button => show,
            result => button_out(3)             --enter = bit 3
        );
    
    --add rand_gen component 
    rand_gen: entity work.rand_gen
        port map
        (
            clk => clk,
            rst => button_out(0),                  --use debounce b/c we want seed to tx and rx at same time
            ENA => enter,                          --b/c we latch immediately, we dont care ab debounce
            output => rand_out
        );

    ------------------------------------------------------------------------------------------------
    --Main
    ------------------------------------------------------------------------------------------------
    --FSM state change 
    current_state: process(clk, button_out(0))
    begin
        if rising_edge(clk) then
            currstate <= nextstate;
        end if;
    end process;
    
    --FSM line up next state and handle processes in between state changes
    next_state: process(currstate, button_out)
    begin
        case currstate is 
            when st0 =>
                leds <= "0000";
                red_led <= '0';
                blue_led <= '0';   
                if button_out(1) = '1' then
                    nextstate <= st1;                                           --start guessing
                else 
                    nextstate <= currstate; 
                end if;
            when st1 =>
                if (button_out(2) = '1') AND (switches /= rand_out) then
                    nextstate <= st2;                                           --enter and set high/low
                    if switches > rand_out then
                        red_led <= '1';
                        blue_led <= '0';
                    elsif switches < rand_out then
                        red_led <= '0';
                        blue_led <= '1';
                    else
                        red_led <= '0';
                        blue_led <= '0';
                    end if;
                elsif ((button_out(2)= '1') AND (switches = rand_out)) then
                    nextstate <= st3;                                           --enter and blink green
                elsif button_out(0) = '1' then
                    nextstate <= st0;
                else 
                    nextstate <= currstate; 
                end if;
            when st2 =>
                if button_out(3) = '1' then
                    leds <= rand_out;                                            --show answer 
                elsif button_out(1) = '1' then
                    nextstate <= st1;                                        --guess again 
                    red_led <= '0';
                    blue_led <= '0';
                elsif button_out(0) = '1' then
                    nextstate <= st0;
                else 
                    nextstate <= currstate;
                end if;   
            when st3 =>
                if button_out(0) = '1' then
                    nextstate <= st0; 
                else 
                    nextstate <= currstate;
                end if;   
        end case;
    end process;

    
    blink_green: process(clk, rst)           --clk needs to awaken bc its what we are counting       
    begin 
        if rst = '1' then
            io_green <= '0';
            cnt <= 0;
        elsif rising_edge(clk) AND currstate = st3 then
            cnt <= cnt + 1;
            if cnt = adjusted_clk then 
                io_green <= (NOT io_green);
                cnt <= 0;
            end if;
        end if;
    end process;
    
    green_led <= io_green;              --assign green led to its driver (wire)
    
end Behavioral;


    --initial issue: rst
        --when the FSM button(0) is changed to rst, it works
        --issue localized to "states" in the pulse detector for rst_debounce
            --never change values bc rst => states <=  "00"
            --**fix** need to isolate ports and properly control the TB. Rst at beginning then ...
                --button reset after 
        
    --additional issue: fix timing of random number gen?

    --rev2: after final design completion: remove rst from the debounce module FF 
                    --tie rst together 
                    
    --rev3: the kill switch to the RNG and FSM rst are added.
        --issue1: rand gen kills one clk too late
            --tried to put variable so it updates instantly in process 
        --issue2: rst button has to be pushed immediately
            --need to add: active lovw 
        --solution1: give it the initial pulse instead of the debounced pulse
        --solution2: give the debounced rst, not original

    --rev 4: added clk divider
        --need to tst: clk divider
        --need to check green LED
    
    --fixes with board:
        --clk issue with constraint file?
        --debounce isnt long enough?
