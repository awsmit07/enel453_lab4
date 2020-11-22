library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

entity register_16bit is
	generic(
		nbits: integer:=16
	);
	port(clk: in std_logic;
		reset_n: in std_logic;
		enable: in std_logic:='1';
		d: in std_logic_vector((nbits-1) downto 0);
		q: out std_logic_vector((nbits-1) downto 0)
		);
end entity;

architecture behavioral of register_16bit is
begin
reg:process(clk, reset_n) is
begin
	if(reset_n = '0') then
		q <= (others => '0');
	elsif(rising_edge(clk) and enable = '1') then
		q <= d;
	end if;

end process;
end architecture;