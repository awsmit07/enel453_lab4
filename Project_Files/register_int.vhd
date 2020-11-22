library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

entity register_int is
    port
    (
        clk: in std_logic;
        reset_n: in std_logic;
        enable: in std_logic:='1';
        d: in integer;
        q: out integer
    );
end entity;

architecture behavioral of register_int is
begin
    reg:process(clk, reset_n) is
    begin
        if(reset_n = '0') then
            q <= 0;
        elsif(rising_edge(clk) and enable = '1') then
            q <= d;
        end if;

    end process;
end architecture;