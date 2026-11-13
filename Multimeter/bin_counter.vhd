-- Temporizador común a los tres canales. Los estados 0 a 329 permiten contar
-- 330 muestras. En el estado 330 se guarda la lectura y comienza otra ventana.
-- Para una escala de 3,30 V, cada muestra alta cuenta como una centésima de voltio.
entity bin_counter is
    port (
        clk : in  bit;
        rst : in  bit;
        tc  : out bit
    );
end bin_counter;

architecture structural of bin_counter is
    component ffd_en is
        port(clk_i, rst_i, ena_i, d_i : in bit; q_o : out bit);
    end component;
    signal q, d, t       : bit_vector(8 downto 0);
    signal tc_int, rst_int : bit;
begin
    -- 330 es el primer estado en el que estos cuatro bits valen uno.
    tc_int  <= q(8) and q(6) and q(3) and q(1);
    rst_int <= rst or tc_int;

    -- Cada bit conmuta cuando todos los bits inferiores valen uno.
    t(0) <= '1';
    t(1) <= q(0);
    t(2) <= q(1) and q(0);
    t(3) <= q(2) and q(1) and q(0);
    t(4) <= q(3) and q(2) and q(1) and q(0);
    t(5) <= q(4) and q(3) and q(2) and q(1) and q(0);
    t(6) <= q(5) and q(4) and q(3) and q(2) and q(1) and q(0);
    t(7) <= q(6) and q(5) and q(4) and q(3) and q(2) and q(1) and q(0);
    t(8) <= q(7) and q(6) and q(5) and q(4) and q(3) and q(2) and q(1) and q(0);

    d <= q xor t;

    ff_gen: for i in 0 to 8 generate
        f: ffd_en port map(clk, rst_int, '1', d(i), q(i));
    end generate;

    tc <= tc_int;
end structural;
