library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity top_level is
    Port ( clk                           : in  STD_LOGIC;
           reset_n                       : in  STD_LOGIC;
		     SW                            : in  STD_LOGIC_VECTOR (9 downto 0);
			  freeze							     : in  STD_LOGIC;
           LEDR                          : out STD_LOGIC_VECTOR (9 downto 0);
           HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 : out STD_LOGIC_VECTOR (7 downto 0)
          );

end top_level;

architecture Behavioral of top_level is

Signal Num_Hex0, Num_Hex1, Num_Hex2, Num_Hex3, Num_Hex4, Num_Hex5 : STD_LOGIC_VECTOR (3 downto 0):= (others=>'0');
Signal DP_in:  STD_LOGIC_VECTOR (5 downto 0);
Signal blank:  STD_LOGIC_VECTOR (5 downto 0):="110000";
Signal binary: STD_LOGIC_VECTOR (15 downto 0);
Signal bcd:           STD_LOGIC_VECTOR(15 DOWNTO 0);
Signal display_binary: STD_LOGIC_VECTOR(15 downto 0);
signal mux_binary: STD_LOGIC_VECTOR(15 downto 0);
signal bcd_binary: std_logic_vector(12 downto 0);
signal sync_sw: std_logic_vector(9 downto 0);
signal debounced_freeze: std_logic;
signal dist_binary: std_logic_vector(12 downto 0) := (others=>'0');
signal volt_binary: std_logic_vector(12 downto 0) := (others=>'0');
signal adc_binary: std_logic_vector(15 downto 0) := (others=>'0');
signal ph: std_logic_vector(12 downto 0);

constant dec_cm: std_logic_vector(5 downto 0):="000100";
constant dec_v: std_logic_vector(5 downto 0):="001000";
constant zero: std_logic_vector(15 downto 0):=X"0000";

Component SevenSegment is
    Port( Num_Hex0,Num_Hex1,Num_Hex2,Num_Hex3,Num_Hex4,Num_Hex5 : in  STD_LOGIC_VECTOR (3 downto 0);
          Hex0,Hex1,Hex2,Hex3,Hex4,Hex5                         : out STD_LOGIC_VECTOR (7 downto 0);
          DP_in,Blank                                           : in  STD_LOGIC_VECTOR (5 downto 0)
			);
End Component ;

Component binary_bcd IS
   PORT(
      clk     : IN  STD_LOGIC;                      --system clock
      reset_n : IN  STD_LOGIC;                      --active low asynchronus reset_n
      binary  : IN  STD_LOGIC_VECTOR(12 DOWNTO 0);  --binary number to convert
      bcd     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)   --resulting BCD number
		);
END Component;

component synchronizer_10bit is
	generic(nbits: integer:=10);
	port(clk: in std_logic;
		  reset_n: in std_logic;
		  inputs: in std_logic_vector(nbits - 1 downto 0);
		  outputs: out std_logic_vector(nbits - 1 downto 0)
		  );
end component;

component MUX4TO1 is
	port(
		in0     : in  std_logic_vector(15 downto 0):=(others =>'0');
		in1     : in  std_logic_vector(15 downto 0):=(others =>'0');
		in2     : in  std_logic_vector(15 downto 0):=(others =>'0');
		in3     : in  std_logic_vector(15 downto 0):=(others =>'0');
		s       : in  std_logic_vector(1 downto 0):=(others =>'0');
		mux_out : out std_logic_vector(15 downto 0)
	);
end component;

component debounce IS
  GENERIC(
    clk_freq    : INTEGER := 50_000_000;  --system clock frequency in Hz
    stable_time : INTEGER := 10;         --time button must remain stable in ms
	 reset_result: INTEGER :=0);
  PORT(
    clk     : IN  STD_LOGIC;  --input clock
    reset_n : IN  STD_LOGIC;  --asynchronous active low reset
    button  : IN  STD_LOGIC;  --input signal to be debounced
    result  : OUT STD_LOGIC); --debounced signal
END component;

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

component ADC_Data is
    Port( clk      : in STD_LOGIC;
	       reset_n  : in STD_LOGIC; -- active-low
			 voltage  : out STD_LOGIC_VECTOR (12 downto 0); -- Voltage in milli-volts
			 distance : out STD_LOGIC_VECTOR (12 downto 0); -- distance in 10^-4 cm (e.g. if distance = 33 cm, then 3300 is the value)
			 ADC_raw  : out STD_LOGIC_VECTOR (11 downto 0); -- the latest 12-bit ADC value
          ADC_out  : out STD_LOGIC_VECTOR (11 downto 0)  -- moving average of ADC value, over 256 samples,
         );                                              -- number of samples defined by the averager module
end component;

component bcd_clear_leading_zeros is
	generic(enable_modes: unsigned(3 downto 0) :=X"f");
	port(clk: in std_logic;
			reset_n: in std_logic;
			mode: in std_logic_vector(1 downto 0);
			bcd: in std_logic_vector(15 downto 0);
			dp: in std_logic_vector(3 downto 0);
			clears: out std_logic_vector(3 downto 0)
	);
end component;

begin
   Num_Hex0 <= display_binary(3  downto  0);
   Num_Hex1 <= display_binary(7  downto  4);
   Num_Hex2 <= display_binary(11 downto  8);
   Num_Hex3 <= display_binary(15 downto 12);
   Num_Hex4 <= "0000";
   Num_Hex5 <= "0000";
   --DP_in    <= "000000"; -- position of the decimal point in the display (1=LED on,0=LED off)
   --blank    <= "110000"; -- blank the 2 MSB 7-segment displays (1=7-seg display off, 0=7-seg display on)

blanks_ins: bcd_clear_leading_zeros
	generic map("0101")
	port map(clk => clk,
				reset_n => reset_n,
				mode => sync_sw(9 downto 8),
				bcd => display_binary,
				dp => dp_in(3 downto 0),
				clears => blank(3 downto 0)
	);

SevenSegment_ins: SevenSegment

                  PORT MAP( Num_Hex0 => Num_Hex0,
                            Num_Hex1 => Num_Hex1,
                            Num_Hex2 => Num_Hex2,
                            Num_Hex3 => Num_Hex3,
                            Num_Hex4 => Num_Hex4,
                            Num_Hex5 => Num_Hex5,
                            Hex0     => Hex0,
                            Hex1     => Hex1,
                            Hex2     => Hex2,
                            Hex3     => Hex3,
                            Hex4     => Hex4,
                            Hex5     => Hex5,
                            DP_in    => DP_in,
									 blank    => blank
                          );

bcd_ins: binary_bcd
   PORT MAP(
      clk      => clk,
      reset_n  => reset_n,
      binary   => bcd_binary,
      bcd      => bcd
   );

register_16bit_freezedv: register_16bit
	port map(
		clk => clk,
		reset_n => reset_n,
		enable => debounced_freeze,
		d => mux_binary,
		q => display_binary
	);

display_mux: MUX4TO1
	port map(
		s => sync_sw(9 downto 8),
		in0 => bcd,
		in1 => bcd,
		in2 => adc_binary,
		in3 => binary,
		mux_out => mux_binary
	);

bcd_mux: MUX4TO1
	port map(s(0) => sync_sw(8),
				s(1) => zero(0),
				in0(12 downto 0) => dist_binary,
				in0(15 downto 13) => zero(2 downto 0),
				in1(12 downto 0) => volt_binary,
				in1(15 downto 13) => zero(2 downto 0),
				mux_out(12 downto 0) => bcd_binary,
				mux_out(15 downto 13) => ph(2 downto 0)
	);

dec_mux: MUX4TO1
	port map(s => sync_sw(9 downto 8),
				in0(5 downto 0) => dec_cm,
				in0(15 downto 6) => zero(9 downto 0),
				in1(5 downto 0) => dec_v,
				in1(15 downto 6) => zero(9 downto 0),
				mux_out(5 downto 0) => dp_in,
				mux_out(15 downto 6) => ph(12 downto 3)
	);

synchronizer_10bit_sw: synchronizer_10bit
	port map(
		clk => clk,
		reset_n => reset_n,
		inputs => sw,
		outputs => sync_sw
		);

debounce_freeze: debounce
-- Stable time set to 0 for testbenches. Set to 30 for use on hardware
	generic map(stable_time => 30,reset_result => 1) 
	port map(
		clk => clk,
		reset_n => reset_n,
		button => freeze,
		result => debounced_freeze
		);

dist_adc: ADC_Data
	port map(clk => clk,
				reset_n => reset_n,
				voltage => volt_binary,
				distance => dist_binary,
				ADC_out => adc_binary(11 downto 0)
				);

LEDR(9 downto 0) <=sync_sw(9 downto 0); -- gives visual display of the switch inputs to the LEDs on board
binary <= "00000000" & sync_sw(7 downto 0);


end Behavioral;

--Colton was here