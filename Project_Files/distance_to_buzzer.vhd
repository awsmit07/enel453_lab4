library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity distance_to_buzzer is
	generic(maxfreq: natural:= 5000;
			  scale: natural:=6 --how much does distance change frequency per 0.01cm 50000/(2^scale)*2
			 );
	port(clk: in std_logic;
		 reset_n: in std_logic;
		 distance: in std_logic_vector(12 downto 0);
		 buzzer: out std_logic
		);
end entity;

architecture behavioural of distance_to_buzzer is
	
	constant mincount: natural :=50000/maxfreq/2;
	constant countmod: natural :=499/(2**scale);
	constant maxcount: natural :=mincount+(3560/(2**scale))-countmod;
	
	signal countflag: std_logic;
	signal count_to: natural:=maxcount;
	signal buzzerval: std_logic;

	component downcounter is
		Generic ( period  : natural := 1000); -- number to count       
		PORT    ( clk     : in  STD_LOGIC; -- clock to be divided
				  reset_n : in  STD_LOGIC; -- active-high reset
				  enable  : in  STD_LOGIC:='1'; -- active-high enable
				  dynamic_period: in natural:=0;
				  zero    : out STD_LOGIC  -- creates a positive pulse every time current_count hits zero
										   -- useful to enable another device, like to slow down a counter
				  -- value  : out STD_LOGIC_VECTOR(integer(ceil(log2(real(period)))) - 1 downto 0) -- outputs the current_count value, if needed
			 );
	end component;

	begin
	
	buzzercounter: downcounter
		generic map(period => maxcount)
		port map(clk => clk,
					reset_n => reset_n,
					dynamic_period => count_to,
					zero => countflag
		);
	
	buzzergen: process(clk,reset_n)
	
		begin
		
		if(reset_n = '0') then
			buzzerval <= '0';
			count_to <= maxcount;
		elsif(rising_edge(clk)) then
			if(to_integer(unsigned(distance)) >= 3560) then
				count_to <= maxcount; --50000Hz/500Hz
			else
				count_to <= mincount+to_integer(shift_right(unsigned(distance),scale))-countmod;
			end if;
				
			if(countflag = '1') then
				buzzerval <= not buzzerval;
			end if;
				
		end if;
	
	end process;
	
	buzzer <= buzzerval;

end behavioural;