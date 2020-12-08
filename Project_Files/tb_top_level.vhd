library ieee;
use ieee.std_logic_1164.all;

entity tb_top_level is
end tb_top_level;

architecture tb of tb_top_level is

    component top_level
        port
        (
            clk     : in std_logic;
            reset_n : in std_logic;
            SW      : in std_logic_vector (9 downto 0);
            freeze  : in std_logic;
            LEDR    : out std_logic_vector (9 downto 0);
            HEX0    : out std_logic_vector (7 downto 0);
            HEX1    : out std_logic_vector (7 downto 0);
            HEX2    : out std_logic_vector (7 downto 0);
            HEX3    : out std_logic_vector (7 downto 0);
            HEX4    : out std_logic_vector (7 downto 0);
            HEX5    : out std_logic_vector (7 downto 0)
        );
    end component;

    -- Test modes
    type StateType is (dist, volt, avg, hex);
    signal state: StateType:= dist;

    -- Input Signals
    signal clk     : std_logic:= '0';
    signal reset_n : std_logic:= '0'; -- Active low
    signal SW      : std_logic_vector (9 downto 0):= "0000000000";
    signal freeze  : std_logic:= '1'; -- Active low

    -- Output Signals
    signal LEDR    : std_logic_vector (9 downto 0);
    signal HEX0    : std_logic_vector (7 downto 0);
    signal HEX1    : std_logic_vector (7 downto 0);
    signal HEX2    : std_logic_vector (7 downto 0);
    signal HEX3    : std_logic_vector (7 downto 0);
    signal HEX4    : std_logic_vector (7 downto 0);
    signal HEX5    : std_logic_vector (7 downto 0);

    -- Clock control signals
    constant tb_clk_period : time := 20 ns;
    signal sim_ended : std_logic := '0';

begin
    -- Instantiate UUT
    uut : top_level port map
    (
        clk     => clk,
        reset_n => reset_n,
        SW      => SW,
        freeze  => freeze,
        LEDR    => LEDR,
        HEX0    => HEX0,
        HEX1    => HEX1,
        HEX2    => HEX2,
        HEX3    => HEX3,
        HEX4    => HEX4,
        HEX5    => HEX5
    );

    -- Clock generation
    clk <= not clk after tb_clk_period/2 when sim_ended /= '1' else '0';

    -- Simulation process
    stimuli : process
    begin
        assert false report "top_level testbench started";
        -- Setup time
        wait for 80*tb_clk_period;

        -- Add data to switches for simulation purposes.
        SW(7 downto 0) <= "10101010"; -- AA hex or 170 dec

        -- Set reset high to test distance operation
        reset_n <= '1';
        wait for 3000*tb_clk_period;

        -- Set reset low to test reset operation
        reset_n <= '0';
        wait for 500*tb_clk_period;

        reset_n <= '1';
        wait for 500*tb_clk_period;

        -- Test hold functionality
        freeze <= '0';
        wait for 500*tb_clk_period;
        freeze <= '1';

        -- Test voltage function
        SW(9 downto 8) <= "01";
        state <= volt;
        wait for 5000*tb_clk_period;
        -- Set reset low to test reset operation
        reset_n <= '0';
        wait for 500*tb_clk_period;

        reset_n <= '1';
        wait for 500*tb_clk_period;

        -- Test hold functionality
        freeze <= '0';
        wait for 500*tb_clk_period;
        freeze <= '1';

        -- Test Moving Average
        SW(9 downto 8) <= "10";
        state <= avg;
        wait for 5000*tb_clk_period;
        -- Set reset low to test reset operation
        reset_n <= '0';
        wait for 500*tb_clk_period;

        reset_n <= '1';
        wait for 500*tb_clk_period;

        -- Test hold functionality
        freeze <= '0';
        wait for 500*tb_clk_period;
        freeze <= '1';

        -- Test Hex Switch Mode
        SW(9 downto 8) <= "11";
        state <= hex;
        wait for 5000*tb_clk_period;
        -- Set reset low to test reset operation
        reset_n <= '0';
        wait for 500*tb_clk_period;

        reset_n <= '1';
        wait for 500*tb_clk_period;

        -- Test hold functionality
        freeze <= '0';
        wait for 500*tb_clk_period;
        SW(7 downto 0) <= X"55";
        wait for 500*tb_clk_period;
        freeze <= '1';
        wait for 500*tb_clk_period;
        -- Stop the clock and hence terminate the simulation
        --sim_ended <= '1';
        assert false report "top_level testbench completed";
        wait;
    end process;

end tb;