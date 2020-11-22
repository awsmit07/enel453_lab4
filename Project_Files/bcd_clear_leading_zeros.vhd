library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd_clear_leading_zeros is
	generic(enable_modes: unsigned(3 downto 0) :=X"f");
	port(clk: in std_logic;
			reset_n: in std_logic;
			mode: in std_logic_vector(1 downto 0):="00";
			bcd: in std_logic_vector(15 downto 0);
			dp: in std_logic_vector(3 downto 0);
			clears: out std_logic_vector(3 downto 0)
	);
end entity;

architecture behavioural of bcd_clear_leading_zeros is

signal counter: integer:=0;
signal clears_buffer: std_logic_vector(3 downto 0):=X"0";
signal bcd_buffer: std_logic_vector(15 downto 0):=X"0000";
signal dp_buffer: std_logic_vector(15 downto 0):=X"0000";

constant mask: unsigned(3 downto 0):=X"1";

begin

calc_zeros: process(clk,reset_n) is
begin
	if reset_n = '0' or ((shift_left(mask,to_integer(unsigned(mode))) and enable_modes) = X"0")  then
		counter <= 0;
		clears <= (others => '0');
	elsif rising_edge(clk) then
		if counter = 0 then
			bcd_buffer <= bcd;
			dp_buffer(3 downto 0) <= dp;
			counter <= counter+1;
		elsif unsigned(dp_buffer) sll (counter-1) > X"0004" and counter < 4 then
			clears_buffer(4-counter) <= '0';
			counter <= counter+1;
		elsif counter = 1 then
			if bcd_buffer(15 downto 12) = X"0" then
				clears_buffer(3) <= '1';
			else
				clears_buffer(3) <= '0';
			end if;
			counter <= counter+1;
		elsif counter < 4 then
			if bcd_buffer(15-((counter-1)*4) downto 12-((counter-1)*4)) = X"0" and clears_buffer(4-(counter-1)) = '1' then
				clears_buffer(3-counter+1) <= '1';
			else
				clears_buffer(3-counter+1) <= '0';
			end if;
			counter <= counter+1;
		else
			clears <= clears_buffer;
			counter <= 0;
		end if;
	end if;
end process;
end behavioural;