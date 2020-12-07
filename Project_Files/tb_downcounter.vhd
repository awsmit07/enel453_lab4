library ieee;
use ieee.std_logic_1164.all;

entity tb_downcounter is
end tb_downcounter;

architecture tb of tb_downcounter is
    -- Declare Components
    component downcounter
        generic
        (
            period: natural := 2
        );
        port
        (
            clk: in std_logic;
            reset_n: in std_logic;
            enable: in std_logic;
            dynamic_period: in natural:= 0;
            zero: out std_logic
        );
    end component;

    -- Generic Signals
    signal period: natural := 3;

    -- Input signals
    signal reset_n: std_logic := '0';
    signal clk: std_logic := '0';
    signal enable: std_logic := '1';

    -- Output signals
    signal zero: std_logic;

    --Time Constant
    constant clk_period: time:= 20 ns;

begin
    uut: downcounter
    generic map
    (
        period => period
    )
    port map
    (
        clk => clk,
        reset_n => reset_n,
        enable => enable,
        dynamic_period => period,
        zero => zero
    );
    -- Begin Clock
    clk <= not clk after clk_period/2;

    -- Stimulus Process
    stim_process: process begin
        reset_n <= '1';
        wait for 4*clk_period;

        period <= 2;
        wait for 6*clk_period;

        wait;

    end process;

end tb;