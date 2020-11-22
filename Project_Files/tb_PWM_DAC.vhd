library ieee;
use ieee.std_logic_1164.all;

entity tb_PWM_DAC is
end tb_PWM_DAC;

architecture tb of tb_PWM_DAC is

    -- Declare Component
    component PWM_DAC
        generic
        (
            width: integer:= 9
        );
        port
        (
            reset_n: in std_logic;
            clk: in std_logic;
            duty_cycle: in std_logic_vector(width - 1 downto 0);
            pwm_out: out std_logic
        );
    end component;

    -- Generic Constants
    constant width: integer:= 8; -- Set width to 1 byte for testbench

    -- Input Signals
    signal reset_n: std_logic:= '0';
    signal clk: std_logic:= '0';
    -- Set duty cycle to dec 26 or ~1/16
    signal duty_cycle: std_logic_vector(width - 1 downto 0):= X"10";

    -- Output Signals
    signal pwm_out: std_logic;

    --Time Constant
    constant clk_period: time:= 20 ns;
    constant PWM_period: time:= clk_period * 2**width;
    signal pwm_clk: std_logic:= '0';

begin
    uut: PWM_DAC
    generic map
    (
        width => width
    )
    port map
    (
        reset_n => reset_n,
        clk => clk,
        duty_cycle => duty_cycle,
        pwm_out => pwm_out
    );

    -- Begin Clock
    clk <= not clk after clk_period/2;

    -- Start a PWM clock which is the output with 50% duty cycle for
    -- comparison
    pwm_clk <= not pwm_clk after PWM_period/2;

    -- Stimulus Process
    stim_process: process begin
        reset_n <= '1';

        -- Display initial PWM
        wait for 2*PWM_period;

        -- Set PWM to 1/2
        duty_cycle <= X"80"; --Set duty cycle to dec 128 or 1/2
        wait for 2 * PWM_period;

        -- Set PWM to 15/16
        duty_cycle <= X"F0"; --Set duty cycle to dec 240 or 15/16
        wait for 2 * PWM_period;

        --clk <= '0';
        wait;
    end process;
end tb;
