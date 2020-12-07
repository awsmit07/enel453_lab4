-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 6.12.2020 23:01:14 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_distance_to_buzzer is
end tb_distance_to_buzzer;

architecture tb of tb_distance_to_buzzer is

    component distance_to_buzzer
        port (clk      : in std_logic;
              reset_n  : in std_logic;
              distance : in std_logic_vector (12 downto 0);
              buzzer   : out std_logic);
    end component;

    signal clk      : std_logic;
    signal reset_n  : std_logic;
    signal distance : std_logic_vector (12 downto 0);
    signal buzzer   : std_logic;

    constant TbPeriod : time := 20 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : distance_to_buzzer
    port map (clk      => clk,
              reset_n  => reset_n,
              distance => distance,
              buzzer   => buzzer);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        distance <= (others => '0');

        -- Reset generation
        -- EDIT: Check that reset_n is really your reset signal
        reset_n <= '0';
        wait for 100 ns;
        reset_n <= '1';
        wait for 100 ns;
        -- EDIT Add stimuli here
		  for i in 12 downto 11 loop
				distance <= (i => '1',others => '0');
				wait for 10ms;
		  end loop;
        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_distance_to_buzzer of tb_distance_to_buzzer is
    for tb
    end for;
end cfg_tb_distance_to_buzzer;