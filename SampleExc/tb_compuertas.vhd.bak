
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_compuertas is
end tb_compuertas;

architecture Behavioral of tb_compuertas is
    signal A, B : STD_LOGIC := '0';
    signal Y_AND, Y_OR, Y_XOR, Y_NOT : STD_LOGIC;
begin
    DUT: entity work.compuertas
        port map (
            A => A, B => B,
            Y_AND => Y_AND, Y_OR => Y_OR,
            Y_XOR => Y_XOR, Y_NOT => Y_NOT
        );

    process
    begin
        -- A,B = 00
        A <= '0'; B <= '0'; wait for 10 ns;
        assert Y_AND = '0' report "ERROR AND 00" severity error;
        assert Y_OR  = '0' report "ERROR OR 00"  severity error;
        assert Y_XOR = '0' report "ERROR XOR 00" severity error;
        assert Y_NOT = '1' report "ERROR NOT 00" severity error;

        -- A,B = 01
        A <= '0'; B <= '1'; wait for 10 ns;
        assert Y_AND = '0' report "ERROR AND 01" severity error;
        assert Y_OR  = '1' report "ERROR OR 01"  severity error;
        assert Y_XOR = '1' report "ERROR XOR 01" severity error;
        assert Y_NOT = '1' report "ERROR NOT 01" severity error;

        -- A,B = 10
        A <= '1'; B <= '0'; wait for 10 ns;
        assert Y_AND = '0' report "ERROR AND 10" severity error;
        assert Y_OR  = '1' report "ERROR OR 10"  severity error;
        assert Y_XOR = '1' report "ERROR XOR 10" severity error;
        assert Y_NOT = '0' report "ERROR NOT 10" severity error;

        -- A,B = 11
        A <= '1'; B <= '1'; wait for 10 ns;
        assert Y_AND = '1' report "ERROR AND 11" severity error;
        assert Y_OR  = '1' report "ERROR OR 11"  severity error;
        assert Y_XOR = '0' report "ERROR XOR 11" severity error;
        assert Y_NOT = '0' report "ERROR NOT 11" severity error;

        wait;
    end process;
end Behavioral;