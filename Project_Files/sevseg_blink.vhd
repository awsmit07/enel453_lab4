library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity sevseg_blink is
    -- Controls blinking of the seven segment display
    --
    -- clk: system clock
    --
    -- reset_n: asyncronous active low reset
    --
    -- dist: the 13 bit distance value measured in intervals of 0.0001m
    --
    -- blink_dist: the distance below which to start blinking
    --
    -- clears: outputs an array of either all ones or zeros. If one then
    -- the display will be cleared. If zero then the display will be on.
    -- clears will turn on and off to blink the LEDs.

    port
    (
        clk: in std_logic;
        reset_n: in std_logic:= '1';
        dist: in std_logic_vector(12 downto 0);
        blink_dist: in std_logic_vector(12 downto 0);
        clears: out std_logic_vector(5 downto 0):= (others => '0')
    );
end sevseg_blink;



architecture behavioral of sevseg_blink is

    -- Downcounter creates a 64Hz Clock
    component downcounter
        generic
        (
            period: natural := 15625000
        );
        port
        (
            clk: in std_logic;
            reset_n: in std_logic;
            enable: in std_logic;
	    dynamic_period: in integer;
            zero: out std_logic
        );
    end component;

    -- Clock of 64Hz (the fastest the LEDs will blink)
    -- Note is not a 50% duty cycle
    signal clk_64: std_logic;

    -- Clock adjusted to output frequency
    signal tmp_clk: std_logic;
    -- Clock of adjustable frequency below 20Hz with 50% duty
    signal out_clk: std_logic := '0';

    -- Signal to enable the clk_64
    signal enable: std_logic;

    -- Period multiplier for outputing signals
    signal period_multiplier: integer := 1;

    signal tmp_clear: std_logic_vector(5 downto 0) := (others => '0');


begin
    -- Instantiate the downcounter to make 64Hz clock
    clk_to_64: downcounter
        generic map
        (
            781250 -- hardware mode. Set clock output to 64Hz for visible output
            -- 2500 -- Simulation Mode. Set clock to 20kHz for faster simulations
        )
        port map
        (
            clk => clk,
            reset_n => reset_n,
            enable => enable,
            dynamic_period => 0,
            zero => clk_64
        );

    -- Instantiate the downcounter to make the output clock;
    --clk_to_out:
    set_out_clk: downcounter
        generic map
        (
            2
        )
        port map
        (
            clk => clk_64,
            reset_n => reset_n,
            enable => enable,
            dynamic_period => period_multiplier,
            zero => tmp_clk
        );

    -- The output clock will be half tmp_clk frequency but with 50% duty
    -- cycle
    mk_outclk: process(tmp_clk)
    begin
        if rising_edge(tmp_clk) then
            out_clk <= not out_clk;
        end if;
    end process;

    -- Compute period multiplier
    compute: process(dist, blink_dist, clk)
    begin
        if(enable = '1' and rising_edge(clk)) then
            -- Take the floor of the distance in CM and subtract floor
            -- of the minimum distance (3cm)
            period_multiplier <= to_integer(unsigned(dist))/100 - 3;
        end if;
    end process;


    -- Comparitor process
    compare: process(blink_dist, dist, clk)
    begin
        if(rising_edge(clk)) then
            -- Check if blink_dist > dist
            if(to_integer(unsigned(blink_dist)) > to_integer(unsigned(dist))) then
                enable <= '1';
                -- Set tmp_clear to follow the output clock
                tmp_clear <= (others => out_clk);

            -- If dist > blink_dist or we are reseting set clears to 0
            else
                tmp_clear <= "000000";
                enable <= '0';
            end if;
        end if;
    end process;

    -- Output Process
    output: process(clk, reset_n)
    begin
        if(reset_n = '0') then
            clears <= "000000";
        elsif(rising_edge(clk)) then
            clears <= tmp_clear;
        end if;
    end process;


end behavioral;