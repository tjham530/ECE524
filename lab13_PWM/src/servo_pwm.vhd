library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.round;

entity servo_pwm is
    generic (
        clk_hz : real := 125000000.00;
        pulse_hz : real := 100.00; -- PWM pulse frequency
        min_pulse_us : real := 1000.00; -- uS pulse width at min position
        max_pulse_us : real := 2000.00; -- uS pulse width at max position
        step_count : positive := 256 -- number of steps from min to max
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        position : in integer range 0 to step_count - 1;
        pwm : out std_logic
    );
end entity;

architecture Behavioral of servo_pwm is

    --clock count function and constants:
    function cycles_per_us (us_count : real) return integer is
    begin
     return integer(round(clk_hz / 1.0e6 * us_count));
    end function;
    
    constant min_count : integer := cycles_per_us(min_pulse_us);    --min pulse width for servo PWM
    constant max_count : integer := cycles_per_us(max_pulse_us);    --max pulse width for servo PWM
    constant min_max_range_us : real := max_pulse_us - min_pulse_us;
    constant step_us : real := min_max_range_us / real(step_count - 1);
    constant cycles_per_step : positive := cycles_per_us(step_us);
    constant counter_max : integer := integer(round(clk_hz / pulse_hz)) - 1;       --DVSR for PWM counter
    signal counter : integer range 0 to counter_max;
    signal duty_cycle : integer range 0 to max_count;
    
begin

    --count to max pulse width 
    COUNTER_PROC : process(clk)    --counter that counts to max PWM pulse out
    begin
        if rising_edge(clk) then
            if rst = '1' then
                counter <= 0;
            else
                if counter < counter_max then   
                    counter <= counter + 1;
                else
                    counter <= 0;
                end if;
            end if;
        end if;
    end process;

    --count to PWM duty cycle 
    PWM_PROC : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pwm <= '0';
            else
                pwm <= '0';
                if counter < duty_cycle then
                    pwm <= '1';
                end if;
           end if;
        end if;
    end process;


    --set duty cycle value based on position
    DUTY_CYCLE_PROC : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                duty_cycle <= min_count;
            else
                duty_cycle <= (position * cycles_per_step) + min_count;
            end if;
        end if;
    end process;

end Behavioral;


-------------------------------------------------------------------------------
--how to send in position:
-------------------------------------------------------------------------------
--the desired position affects the duty cycle. duty cycle affects pulse width 
--the number of steps we have in between 0 deg and 180 deg is the number of 
    --places we can move to in between max and min 

--when we send a pulse value, the motor moves to that value. Its a potential 
    --that the motor wishes to make neutral again. 

--so if a 1ms pulse cycle is sent, the potential is at 0 deg, and the servo will move there
    --until that potential is made neutral

--so we want the commanded position to send a duty cycle value that will highlight a potential 

--SOLUTION:
    -- 1. have sin wave code control position
    -- 2. have a counter increment and decrement the position values 




        
                    