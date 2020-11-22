library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Define MUX component
entity MUX4TO1 is port
(
    in0: in std_logic_vector(15 downto 0):=(others =>'0');
    in1: in std_logic_vector(15 downto 0):=(others =>'0');
    in2: in std_logic_vector(15 downto 0):=(others =>'0');
    in3: in std_logic_vector(15 downto 0):=(others =>'0');
    s: in std_logic_vector(1 downto 0):=(others =>'0');
    mux_out: out std_logic_vector(15 downto 0)
);
end MUX4TO1;

-- Define behavior of 4:1 mux
architecture BEHAVIOR of MUX4TO1 is begin
    with s select mux_out<=
        in0 when "00",
        in1 when "01",
        in2 when "10",
        in3 when "11",
        "XXXXXXXXXXXXXXXX" when others;
end BEHAVIOR; -- can also be written as "end;"
