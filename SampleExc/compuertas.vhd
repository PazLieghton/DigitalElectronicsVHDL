library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity compuertas is
    Port (
        A     : in  STD_LOGIC;
        B     : in  STD_LOGIC;
        Y_AND : out STD_LOGIC;
        Y_OR  : out STD_LOGIC;
        Y_XOR : out STD_LOGIC;
        Y_NOT : out STD_LOGIC
    );
end compuertas;

architecture Behavioral of compuertas is
begin
    Y_AND <= A and B;
    Y_OR  <= A or B;
    Y_XOR <= A xor B;
    Y_NOT <= not A;
end Behavioral;