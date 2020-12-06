library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity distance_to_LEDR is
	port(clk: in std_logic;
			reset_n: in std_logic;
			distance: std_logic_vector(12 downto 0);
			LEDR: out std_logic_vector(9 downto 0)
		);
end entity;

--Distance limits: 399-3959 (3560)

architecture structural of distance_to_LEDR is

signal duty_cycle: std_logic_vector(8 downto 0);
signal pwm_out: std_logic;

component PWM_DAC is
   Generic ( width : integer := 9);
   Port    ( reset_n    : in  STD_LOGIC;
             clk        : in  STD_LOGIC;
             duty_cycle : in  STD_LOGIC_VECTOR (width-1 downto 0);
             pwm_out    : out STD_LOGIC
           );
end component;

begin

led_pwm: PWM_DAC
	port map(reset_n => reset_n,
				clk => clk,
				duty_cycle => duty_cycle,
				pwm_out => pwm_out
	);
	
LEDR <= (others=>'1') when pwm_out = '1' and to_integer(unsigned(distance)) < 3560 else (others=>'0');
--
duty_cycle <= std_logic_vector(to_unsigned(512-to_integer(shift_right(unsigned(distance),3))+50,9));
	
end structural;