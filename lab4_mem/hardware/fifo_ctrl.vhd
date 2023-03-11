library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_ctrl is
  generic(
     ADDR_WIDTH : integer := 3;
     DATA_WIDTH : integer := 8;
     WORD_TOT   : integer := 3
  );       
  port(
     clk, reset   : in  std_logic;
     rd, wr       : in  std_logic;
     empty, full  : out std_logic;
     almost_full  : out std_logic; --assert '1' when capacity > 75%
     almost_empty : out std_logic; --assert '1' when capacity < 25%
     word_count    : out std_logic_vector(WORD_TOT downto 0); --indicates occupancy of FIFO buffer (bit count)
     w_addr       : out std_logic_vector(ADDR_WIDTH-1 downto 0);
     r_addr       : out std_logic_vector(ADDR_WIDTH-1 downto 0)
  );
end fifo_ctrl;

architecture arch of fifo_ctrl is
    signal w_ptr_reg  : std_logic_vector(ADDR_WIDTH-1 downto 0);    -- write pointer for circular que
    signal w_ptr_next : std_logic_vector(ADDR_WIDTH-1 downto 0);    -- next value of pointer (FSM)   
    signal w_ptr_succ : std_logic_vector(ADDR_WIDTH-1 downto 0);    --
    signal r_ptr_reg  : std_logic_vector(ADDR_WIDTH-1 downto 0);    -- read pointer for circular que
    signal r_ptr_next : std_logic_vector(ADDR_WIDTH-1 downto 0);    -- next val for read pointer (FSM)
    signal r_ptr_succ : std_logic_vector(ADDR_WIDTH-1 downto 0);    -- 
    signal full_reg   : std_logic;  -- indicator for full
    signal full_next  : std_logic;  -- next value for full 
    signal empty_reg  : std_logic;  -- empty indicator
    signal empty_next : std_logic;  -- next value for empty
    signal wr_op      : std_logic_vector(1 downto 0);   

    --added signals: status registers to pass to ports
    signal almost_full_reg   : std_logic;  
    signal almost_full_next  : std_logic;   
    signal almost_empty_reg  : std_logic; 
    signal almost_empty_next : std_logic;       
    signal word_count_reg     : std_logic_vector(WORD_TOT downto 0); 
    signal word_count_next    : std_logic_vector(WORD_TOT downto 0); 
    signal word_count_succ    : std_logic_vector(WORD_TOT downto 0);
    signal word_count_prev    : std_logic_vector(WORD_TOT downto 0);
    
    constant WCNT : integer := 8;

begin

-- FSM state change: register for read and write pointers
    process(clk, reset)
    begin
        if (reset = '1') then
            w_ptr_reg <= (others => '0');
            r_ptr_reg <= (others => '0');
            full_reg  <= '0';
            empty_reg <= '1';
            word_count_reg <= (others => '0');
            almost_full_reg <= '0';
            almost_empty_reg <= '0';
        elsif (clk'event and clk = '1') then
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg  <= full_next;
            empty_reg <= empty_next;
            almost_full_reg <= almost_full_next;
            almost_empty_reg <= almost_empty_next;
            word_count_reg <= word_count_next;
        end if;
    end process;

    -- succ: values are always adding one to the current values of the reg, reference to next position
    w_ptr_succ     <= std_logic_vector(unsigned(w_ptr_reg) + 1);       
    r_ptr_succ     <= std_logic_vector(unsigned(r_ptr_reg) + 1);
    word_count_prev <= std_logic_vector(unsigned(word_count_reg) - 1);    --every time a word is written, 8 bits add / sub
    word_count_succ <= std_logic_vector(unsigned(word_count_reg) + 1);
    

    -- next-state logic for case statement in FSM
    wr_op <= wr & rd;

    process(w_ptr_reg, w_ptr_succ, r_ptr_reg, r_ptr_succ,
            wr_op, empty_reg, full_reg, almost_empty_reg, almost_full_reg,
            word_count_reg, word_count_prev, word_count_succ)
    begin
        --equalize the current and next state: thus, the cases can affect only the necessary ones
        w_ptr_next <= w_ptr_reg;
        r_ptr_next <= r_ptr_reg;
        full_next  <= full_reg;
        empty_next <= empty_reg;
        almost_full_next <= almost_full_reg;
        almost_empty_next <= almost_empty_reg;
        word_count_next <= word_count_reg; 

        case wr_op is
            when "00" =>                   -- no op
            when "01" =>                   -- read
                if (empty_reg /= '1') then  -- not empty
                    r_ptr_next <= r_ptr_succ;
                    full_next  <= '0';
                    word_count_next <= word_count_prev;   --read => drop count by 1
                    if (unsigned(word_count_prev) < (WCNT/4)) then   -- if count < 25%, 
                        almost_empty_next <= '1';
                    else 
                        almost_empty_next <= '0';
                    end if;

                    if (unsigned(word_count_prev) > ((WCNT*3)/4)) then -- if count > 75%, 
                        almost_full_next <= '1';
                    else 
                        almost_full_next <= '0';
                    end if;

                    if (r_ptr_succ = w_ptr_reg) then
                        empty_next <= '1';
                    end if;
                end if;
            when "10" =>                   -- write
                if (full_reg /= '1') then   -- not full
                    w_ptr_next <= w_ptr_succ;
                    empty_next <= '0';
                    word_count_next <= word_count_succ;   --write => inc count by 1
                    if (unsigned(word_count_succ) < (WCNT/4)) then   -- if count < 25%, 
                        almost_empty_next <= '1';
                    else 
                        almost_empty_next <= '0';
                    end if;

                    if (unsigned(word_count_succ) > ((WCNT*3)/4)) then -- if count > 75%, 
                        almost_full_next <= '1';
                    else 
                        almost_full_next <= '0';
                    end if;

                    if (w_ptr_succ = r_ptr_reg) then
                        full_next <= '1';
                    end if;
                end if;
            when others =>                 -- write/read;
                w_ptr_next <= w_ptr_succ;
                r_ptr_next <= r_ptr_succ;
        end case;
    end process;

    -- output
    w_addr       <= w_ptr_reg;
    r_addr       <= r_ptr_reg;
    full         <= full_reg;
    empty        <= empty_reg;
    almost_empty <= almost_empty_reg;
    almost_full  <= almost_full_reg;
    word_count    <= word_count_reg;

end arch;


