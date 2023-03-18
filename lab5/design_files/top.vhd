library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity top is
    generic( 
        ADDR_WIDTH : natural := 4;      --max 10 values => 4 bits to cover
        MAX_DATA : natural := 10;       --pattern guess max
        DATA_WIDTH : natural := 4       --data is max 4 bits 
    );
    port
    (
        clk        : in std_logic;                       --clk
        buttons    : in std_logic_vector(3 downto 0);
        leds       : out std_logic_vector (3 downto 0);  --display correct value
        blue_led   : out std_logic;                      
        green_led  : out std_logic;                       
        red_led : out std_logic
    );
end entity;

architecture Behavioral of top is

    --enum types for states:
    type states is (init, gen, flash, guess, check, correct, incorrect, max, delay);
    signal currstate  : states;
    signal nextstate  : states;
    signal after_delay_state : states;
    
    --constants
    constant clk_freq : integer := 125_000_000;  --1.25 * 10^8   clk/s
    constant stable_time : integer := 10;
    constant bits : integer := 8;
    
    
--    constant five_ms : integer := 6_250_000;  
--    constant two_seconds : integer := 250000000;
--    constant three_seconds : integer := 375000000;
    
    --sim values
    constant five_ms : integer := 10;
    constant two_seconds : integer := 10;
    constant three_seconds : integer := 10;
    
    --intermediate signals
    signal button_out : std_logic_vector(3 downto 0); 
    signal pattern : std_logic_vector(3 downto 0);
    signal io_green: std_logic;
    signal io_blue: std_logic;
    signal flash_num : integer;
    signal toggle_correct: std_logic;
    signal toggle_done: std_logic;
    signal delay_toggle: std_logic;

    --memory signals 
    signal wr_en : std_logic;
    signal rd_en1 : std_logic;
    signal rd_en2 : std_logic;
    signal waddr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal raddr1 : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal raddr2 : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal din_top : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal dout_top1 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal dout_top2 : std_logic_vector(DATA_WIDTH-1 downto 0);

    --game signals 
    signal level : std_logic_vector(3 downto 0);         --tells us the number of patterns to read out
    signal start : std_logic;
    signal rst : std_logic;  
    signal guess_int : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal guess_state : std_logic_vector(1 downto 0); --toggles state machine for incorrect or correct: (null, correct, incorrect)

begin    
    ------------------------------------------------------------------------------------------
    --Current State Logic 
    ------------------------------------------------------------------------------------------
    current_state: process(clk, rst)
    begin
        if rst = '1' then 
            currstate <= init;
        elsif rising_edge(clk) then
            currstate <= nextstate;
        end if;
    end process;

    ------------------------------------------------------------------------------------------
    --Next State Logic 
    ------------------------------------------------------------------------------------------
    next_state: process(currstate, start, waddr, raddr1, raddr2, guess_state, toggle_correct, button_out, delay_toggle)
        variable delay_count : integer := 0;
    begin
        case currstate is 
            when init => 
                if start = '1' then    --btn1 held for 3s, start toggled
                    nextstate <= delay; 
                    after_delay_state <= gen;
                else 
                    nextstate <= currstate;
                    after_delay_state <= after_delay_state;
                    level <= "0000";
                    flash_num <= 0;
                    wr_en <= '0';
                    rd_en1 <= '0';
                    rd_en2 <= '0';
                end if; 
            when gen  =>
                wr_en <= '1';
                if unsigned(waddr) = "1010" then 
                    nextstate <= delay; 
                    after_delay_state <= flash;
                    wr_en <= '0';
                else 
                    nextstate <= currstate;
                    after_delay_state <= after_delay_state;
                end if;
            when flash =>  
                rd_en1 <= '1';
                if unsigned(raddr1) > unsigned(level) then  
                    nextstate <= delay; 
                    after_delay_state <= guess;
                    rd_en1 <= '0';
                else 
                    nextstate <= currstate;
                end if;
            when guess => 
                rd_en2 <= '1'; 
                if (unsigned(button_out) /= "0000") then
                    guess_int <= button_out;
                    nextstate <= delay; 
                    after_delay_state <= check;
                else
                    nextstate <= currstate;
                    after_delay_state <= after_delay_state;
                    guess_int <= "0000";
                end if;
            when check => 
                if unsigned(guess_state) = "10" then 
                    nextstate <= delay; 
                    after_delay_state <= incorrect;
                    rd_en2 <= '0';
                    guess_int <= "0000";
                elsif unsigned(guess_state) = "01" then
                    if unsigned(level) /= "1001" then
                        if unsigned(raddr2) <= unsigned(level) then 
                            after_delay_state <= guess;
                        else   
                            after_delay_state <= correct;
                        end if;
                        nextstate <= delay; 
                    else 
                        nextstate <= max;   
                    end if;         
                    guess_int <= "0000";       
                else 
                    nextstate <= currstate;
                    after_delay_state <= after_delay_state;
                end if;
            when correct  => 
                flash_num <= 2;
                if toggle_correct = '1' then 
                    nextstate <= delay; 
                    after_delay_state <= flash;
                    level <= std_logic_vector(unsigned(level) + "0001");
                else 
                    nextstate <= currstate;
                    after_delay_state <= after_delay_state;
                end if;
            when incorrect  => 
                flash_num <= 2*to_integer(unsigned(level));
            when max  => 
                flash_num <= 50_000_000;    --make really large so it flashes forever
            when delay =>
                if delay_toggle = '1' then 
                    nextstate <= after_delay_state;
                else 
                    nextstate <= currstate;
                    after_delay_state <= after_delay_state;
                end if;
            when others => 
                nextstate <= currstate;
        end case;
    end process;
    
    ------------------------------------------------------------------------------------------
    --State Delay
    ------------------------------------------------------------------------------------------
    delayp: process (clk, currstate)
        variable delay_count : integer := 0;
    begin
        if currstate = delay then 
            if delay_count = five_ms then 
                delay_count := 0;
                delay_toggle <= '1';
            else 
                delay_count := delay_count + 1;
            end if;
        else 
            delay_toggle <= '0';
        end if;
    end process;
    
    ------------------------------------------------------------------------------------------
    --System Reset Triggered: push button 0 and 3 
    ------------------------------------------------------------------------------------------
    rst <= button_out(0) and button_out(3);
    
    --red_led <= rst;  --used to sense if rst has been activated

    ------------------------------------------------------------------------------------------
    --Game Start Triggered: push button 1 and button 2
    ------------------------------------------------------------------------------------------
    start <= button_out(1) and button_out(2);

    ------------------------------------------------------------------------------------------
    --State Gen: Full Pattern Generation: 
    ------------------------------------------------------------------------------------------
    genr: process (clk, currstate, waddr, rst)
    begin  
        if rst = '1' then    
            waddr <= "0000";   --init adddr to zero on start or restart
            din_top <= pattern;
        elsif currstate = gen then 
            if (rising_edge(clk) and (unsigned(waddr) <= "1010")) then 
                din_top <= pattern;
                waddr <=  std_logic_vector(unsigned(waddr) + "0001");
            end if;
        end if;
    end process; 
    
    ------------------------------------------------------------------------------------------
    --State Flash: 
    ------------------------------------------------------------------------------------------
    flashp: process (clk, currstate, raddr1)
        variable flash_count : integer := 0;     --count to 2 second to ensure LEDs flash long enough
        variable ind    : integer := 0; -- 0 => off | 1 => on  
    begin
        if currstate /= flash then 
            raddr1 <= "0000";
        elsif (currstate = flash and (unsigned(raddr1) <= unsigned(level) and rising_edge(clk))) then --if flashing 
            if flash_count < two_seconds then --wait 2 seconds, turn LEDs on or off
                flash_count := flash_count + 1;
            elsif ind = 0 and flash_count >= two_seconds then --if off and reached 2 sec, LEDs on
                flash_count := 0;   --reset blink count 
                leds <= dout_top1;
                ind := 1;
            else 
                leds <= "0000";
                flash_count := 0;
                raddr1 <= std_logic_vector(unsigned(raddr1) + "0001");  --read next num out of memory 
                ind := 0;
            end if;
        end if; 
    end process;

    ------------------------------------------------------------------------------------------
    --State Guess
    ------------------------------------------------------------------------------------------
--    submit_guess: process(clk, button_out, currstate)    
--    begin 
--        if (currstate /= guess and currstate /= check) then  --reset if not on correct state
--            guess_int <= "0000";
--        else 
--            if rising_edge(clk) and unsigned(button_out) /= "0000" then  
--                guess_int <= button_out;
--            end if;
--        end if;
--    end process;

    ------------------------------------------------------------------------------------------
    --State Check 
    ------------------------------------------------------------------------------------------
    checkp: process(clk, currstate, guess_int)
    begin
        if (currstate /= check and currstate /= guess) then --return read address to 0 for next pattern read and check
            raddr2 <= "0000";
        elsif currstate /= check then       --reset guess comparison for next check 
            guess_state <= "00";
        elsif (rising_edge(clk) and currstate = check) then
            if unsigned(guess_int) = unsigned(dout_top2) then 
                guess_state <= "01";    --correct  
                raddr2 <= std_logic_vector(unsigned(raddr2) + "0001");
            else 
                guess_state <= "10";    --incorrect
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------------
    --State Incorrect
    ------------------------------------------------------------------------------------------
    incorrectp: process(clk, currstate, toggle_done)
            variable clk_count : integer := 0;
            variable flash_cnt: integer := 0;        --++ everytime we turn off and on
        begin 
            if currstate /= incorrect then
                clk_count := 0;
                io_blue <= '0';
                toggle_done <= '0'; 
            elsif rising_edge(clk) and currstate = incorrect then 
                clk_count := clk_count + 1;
                if (clk_count > two_seconds and flash_cnt < flash_num and toggle_done = '0') then 
                    io_blue <= not io_blue;
                    clk_count := 0;
                    flash_cnt := flash_cnt + 1;
                elsif flash_cnt >= flash_num then 
                    toggle_done <= '1';
                else 
                    clk_count := clk_count + 1; 
                end if;
            end if;
        end process;
        
    blue_led <= io_blue; 
    ------------------------------------------------------------------------------------------
    --State Correct or Max
    ------------------------------------------------------------------------------------------
    correctp: process(clk, currstate, toggle_correct)
        variable clk_count : integer;
        variable flash_cnt: integer;        --++ everytime we turn off and on
    begin 
        if currstate /= correct and currstate /= max then 
            clk_count := 0;
            io_green <= '0';
            toggle_correct <= '0'; 
            flash_cnt := 0;
        elsif (rising_edge(clk) and (currstate = correct or currstate = max)) then 
            clk_count := clk_count + 1;
            if (clk_count > two_seconds) and (flash_cnt < flash_num) and (toggle_correct = '0') then 
                io_green <= not io_green;
                clk_count := 0;
                flash_cnt := flash_cnt + 1;
            elsif flash_cnt >= flash_num then 
                toggle_correct <= '1'; 
            end if;
        end if;
    end process;
    
    green_led <= io_green; 

    ------------------------------------------------------------------------------------------
    --Instancing
    ------------------------------------------------------------------------------------------
    --sram
    memory: entity work.sram 
        generic map(
            DATA_WIDTH => DATA_WIDTH, 
            ADDR_WIDTH => ADDR_WIDTH, 
            MAX_DATA => MAX_DATA
        )        
        port map(
            clk => clk, 
            rst => rst, 
            wr => wr_en,
            rd1 => rd_en1, 
            rd2 => rd_en2,
            raddr1 => raddr1,
            raddr2 => raddr2,
            waddr => waddr, 
            din => din_top,
            dout1 => dout_top1,
            dout2 => dout_top2
        );
    
    --pattern generator
    RNG: entity work.rand_gen
        generic map(
            bits => bits 
        )
        port map(
            clk => clk, 
            rst => rst, 
            pattern => pattern
        );

    --button 0
    btn0: entity work.debounce 
        generic map(
            clk_freq => clk_freq,
            stable_time => stable_time
        )
        port map(
            clk => clk, 
            rst => rst, 
            button => buttons(0),
            result => button_out(0)

        );
    
    --button 1
    btn1: entity work.debounce 
        generic map(
            clk_freq => clk_freq,
            stable_time => stable_time
        )
        port map(
            clk => clk, 
            rst => rst, 
            button => buttons(1),
            result => button_out(1)
        );
    
    --button 2
    btn2: entity work.debounce 
        generic map(
            clk_freq => clk_freq,
            stable_time => stable_time
        )
        port map(
            clk => clk, 
            rst => rst, 
            button => buttons(2),
            result => button_out(2)
        );

    --button 3:
    btn3: entity work.debounce 
        generic map(
            clk_freq => clk_freq,
            stable_time => stable_time
        )
        port map(
            clk => clk, 
            rst => rst, 
            button => buttons(3),
            result => button_out(3)
        );
        
end architecture;

--issues:
    --need to check all logic process sensitivity lists, all rsts, all button functions
    --ensure that functions are chosen based on start or rst
    --rst all variables
    --init all rst 

    --do i need to have all cases be unsigned comparison?