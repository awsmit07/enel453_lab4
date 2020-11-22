-- Calculates the moving average of 256 samples of 12-bit data
-- Authors: Dan Tran and Ranbir Briar, ENEL 453 students F2019

-- Note, use Q_high_res if you need it. Uncomment in 3 places.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity averager256 is
    generic
    ( -- Note, these are the generic default values. The actual values are in the instantiation generic map.
        N    : INTEGER := 8; -- 8; -- log2(number of samples to average over), e.g. N=8 is 2**8 = 256 samples
        X    : INTEGER := 4; -- X = log4(2**N), e.g. log4(2**8) = log4(4**4) = log4(256) = 4 (bit of resolution gained)
        bits : INTEGER := 11 -- number of bits in the input data to be averaged
    );
    port
    (
        clk     : in  std_logic;
        EN      : in  std_logic; -- takes a new sample when high for each clock cycle
        reset_n : in  std_logic; -- active-low
        Din     : in  std_logic_vector(bits downto 0); -- input sample for moving average calculation
        Q       : out std_logic_vector(bits downto 0)  -- 12-bit moving average of 256 samples
        -- Q_high_res :  out std_logic_vector(X+bits downto 0) -- (4+11 downto 0) -- first add (i.e. X) must match X constant in ADC_Data
    );                                                    -- moving average of ADC with additional bits of resolution:
    end averager256;                                       -- 256 average can give an additional 4 bits of ADC resolution, depending on conditions
                                                          -- so you get 12-bits plus 4-bits = 16-bits (is this real?)
architecture rtl of averager256 is

subtype REG is std_logic_vector(bits downto 0);

type Register_Array is array (natural range <>) of REG;

signal REG_ARRAY : Register_Array(2**N downto 1);

type temporary is array(integer range <>) of integer;
signal tmp : temporary((2**N)-1 downto 1);

signal tmplast : std_logic_vector(2**N-1 downto 0);
constant Zeros : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');


--signal tmp_Q2 : integer;

component register_int is
    port
    (
        clk: in std_logic;
        reset_n: in std_logic;
        enable: in std_logic:='1';
        d: in integer;
        q: out integer
    );
end component;

begin

    shift_reg : process(clk, reset_n)
    begin

        -- If reset is low then 0 output
        if(reset_n = '0') then
            LoopA1: for i in 1 to 2**N loop
                REG_ARRAY(i) <= Zeros;
            end loop LoopA1;
            Q <= (others => '0');
            -- Q_high_res <= (others => '0');

        elsif rising_edge(clk) then
            if EN = '1' then

                REG_ARRAY(1) <= Din;
                -- Shift data through shift register
                LoopA2: for i in 1 to 2**N-1 loop
                    REG_ARRAY(i+1) <= REG_ARRAY(i);
                end loop LoopA2;

                -- Not related to shift register. Output tmplast to Q
                Q <= tmplast(N+bits downto N);
                -- Q_high_res <= tmplast(N+bits downto N-X);

            end if;
        end if;
    end process shift_reg;

    LoopB1: for i in 1 to (2**N)/2 generate
        signal tmp_D1 : integer;
		  begin
        reg1: register_int
        port map
        (
            clk => clk,
            reset_n => reset_n,
            d => tmp_D1,
            q => tmp(i)
        );
        tmp_D1 <= to_integer(unsigned(REG_ARRAY((2*i)-1))) + to_integer(unsigned(REG_ARRAY(2*i)));
    end generate LoopB1;

    LoopB2: for i in ((2**N)/2)+1 to (2**N)-1 generate
        signal tmp_D2 : integer;
		  begin
        reg2: register_int
        port map
        (
            clk => clk,
            reset_n => reset_n,
            d => tmp_D2,
            q => tmp(i)
        );
        tmp_D2 <= tmp(2*(i-(2**N)/2)-1) + tmp(2*(i-(2**N)/2));
    end generate LoopB2;

    tmplast <= std_logic_vector(to_unsigned(tmp((2**N)-1), tmplast'length));

end rtl;
