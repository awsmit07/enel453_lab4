library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity synchronizer_10bit is
	generic(nbits: integer:=10);
	port(clk: in std_logic;
		  reset_n: in std_logic;
		  inputs: in std_logic_vector(nbits - 1 downto 0);
		  outputs: out std_logic_vector(nbits - 1 downto 0)
		  );
end entity;

architecture structural of synchronizer_10bit is

signal middleD: std_logic_vector(nbits - 1 downto 0);

component register_16bit is
	generic(
		nbits: integer:=16
	);
	port(clk: in std_logic;
		reset_n: in std_logic;
		enable: in std_logic:='1';
		d: in std_logic_vector((nbits-1) downto 0);
		q: out std_logic_vector((nbits-1) downto 0)
		);
end component;

begin

reg1: register_16bit generic map(nbits)
							port map(clk => clk,
									  reset_n => reset_n,
									  d => inputs,
									  q => middleD
									  );
reg2: register_16bit generic map(nbits)
							port map(clk => clk,
									  reset_n => reset_n,
									  d => middleD,
									  q => outputs
									  );
									  
end architecture;		  