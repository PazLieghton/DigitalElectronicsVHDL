-- Contador sincronico de 10 bits, estructural, con habilitacion.
-- LAST es el ultimo estado incluido: por ejemplo 799 o 524 en binario.

entity contador_binario10 is
    generic (LAST : bit_vector(9 downto 0));
    port (
        clk_i, rst_i, ena_i : in bit;
        q_o                : out bit_vector(9 downto 0);
        ultimo_o           : out bit
    );
end contador_binario10;

architecture estructural of contador_binario10 is
    signal q, d, t, coincide : bit_vector(9 downto 0);
    signal ultimo, reset_ff : bit;
begin
    -- Comparador XNOR seguido de AND: Q coincide con LAST.
    ultimo <= coincide(9) and coincide(8) and coincide(7) and coincide(6)
          and coincide(5) and coincide(4) and coincide(3) and coincide(2)
          and coincide(1) and coincide(0);

    -- El retorno a cero ocurre en el siguiente flanco habilitado.
    reset_ff <= rst_i or (ultimo and ena_i);

    -- Condiciones de conmutacion de cada bit (acarreo).
    t(0) <= ena_i;
    t(1) <= t(0) and q(0);
    t(2) <= t(1) and q(1);
    t(3) <= t(2) and q(2);
    t(4) <= t(3) and q(3);
    t(5) <= t(4) and q(4);
    t(6) <= t(5) and q(5);
    t(7) <= t(6) and q(6);
    t(8) <= t(7) and q(7);
    t(9) <= t(8) and q(8);

    bits_ff : for i in 0 to 9 generate
        coincide(i) <= not (q(i) xor LAST(i));
        d(i) <= q(i) xor t(i);
        ff : entity work.ffd(ffd_arq)
            port map (clk => clk_i, rst => reset_ff, d => d(i), q => q(i));
    end generate;

    q_o <= q;
    ultimo_o <= ultimo;
end estructural;
