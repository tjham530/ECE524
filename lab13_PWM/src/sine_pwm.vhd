library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity sine_pwm is  
    generic(
        resolution : integer := 8;
        gradient_max : integer := 2499999;
        step_count : integer := 256
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        position : out integer range 0 to step_count - 1;    --output to feed to the servo
        rgb : out std_logic_vector(2 downto 0)
    );
end entity;

architecture behavioral of sine_pwm is
    
    --sine function:
    signal addr: unsigned(resolution-1  downto 0);  --mem address 
    subtype addr_range is integer range 0 to 2**resolution - 1; 
    type rom_type is array (addr_range) of unsigned(resolution - 1 downto 0);

        function init_rom return rom_type is
            variable rom_v : rom_type;
            variable angle : real;
            variable sin_scaled : real;
        begin
            for i in addr_range loop
                angle := real(i) * ((2.0 * MATH_PI) / 2.0**resolution);             --angle value increment by 1 deg to MAX =  resolution 
                sin_scaled := (1.0 + sin(angle)) * (2.0**resolution - 1.0) / 2.0;   --sin value for the degree value
                rom_v(i) := to_unsigned(integer(round(sin_scaled)), resolution);
            end loop;
            return rom_v;
        end init_rom;

    --ROM data 
    constant rom : rom_type := init_rom;
    signal sin_data: unsigned(resolution-1 downto 0);

    --design signals 
    signal pwm_out : std_logic;
    signal j : integer := 0;
    signal duty : std_logic_vector(resolution downto 0);
    constant dvsr : integer := 4882;

begin 
    -------------------------------------------------------------------
    --instance:
    -------------------------------------------------------------------
    switcher: entity work.pwm_switcher 
        generic map(
            resolution => resolution,
            dvsr => dvsr
        )
        port map(
            clk => clk,
            rst => rst,
            duty => duty, 
            pwm_out => pwm_out 
        );

    -------------------------------------------------------------------
    --MAIN CODE:
    -------------------------------------------------------------------
    main: process (clk, rst) 
        variable grad_count : integer;
        variable gradient_pulse : std_logic;
    begin 
        if (rst = '1') then 
            grad_count := 0;
            gradient_pulse := '0';
            j <= 0;
        elsif (rising_edge(clk)) then 
            if (grad_count < gradient_max) then 
                grad_count := grad_count + 1;
                gradient_pulse := '0';
            else  
                grad_count := 0;
                gradient_pulse := '1';
            end if;
            
            if (gradient_pulse = '1') then 
                j <= j + 1;
            end if;

            if (j = 256) then 
                j <= 0;
            end if; 
        end if;
    end process;

    -------------------------------------------------------------------
    --OUTPUTS:
    -------------------------------------------------------------------
    rgb(0) <= pwm_out;
    rgb(1) <= '0';
    rgb(2) <= '0';
    duty <= '0' & std_logic_vector(rom(j));
    position <= to_integer(rom(j));
    
end behavioral ; 

