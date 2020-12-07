library ieee;
use ieee.std_logic_1164.all;

entity tb_sevseg_blink is
end tb_sevseg_blink;

architecture tb of tb_sevseg_blink is
    -- Declare Components
    component sevseg_blink
        port
        (
            clk: in std_logic;
            reset_n: in std_logic:= '1';
            dist: in std_logic_vector(12 downto 0);
            blink_dist: in std_logic_vector(12 downto 0);
            clears: out std_logic_vector(5 downto 0):= (others => '0')
        );
    end component;


    -- Input signals
    signal reset_n: std_logic := '0';
    signal clk: std_logic := '0';
    signal dist: std_logic_vector(12 downto 0) := "0011111001111";
    signal blink_dist: std_logic_vector(12 downto 0) := "0011111010000";

    -- Output signals
    signal clears: std_logic_vector(5 downto 0);

    --Time Constant
    constant clk_period: time:= 20 ns;

begin
    uut: sevseg_blink
    port map
    (
        clk => clk,
        reset_n => reset_n,
        dist => dist,
        blink_dist => blink_dist,
        clears => clears
    );

    -- Begin Clock
    clk <= not clk after clk_period/2;

    -- Stimulus Process
    stim_process: process begin
        reset_n <= '1';

        wait for 80000*clk_period;

        dist <= "0000111110100";
        wait for 80000*clk_period;

        dist <= "0011111010001";

        wait for 1000 * clk_period;

    end process;
end tb;