----------------------------------------------------------------------------------
-- bin_counter : temporizador de la ventana de medicion (compartido por los canales)
--   Cuenta 0..330 y vuelve a 0  ->  periodo = 331 ciclos de reloj.
--   tc = '1' durante el ciclo en que cuenta 330 (fin de ventana).
--   Durante los 330 ciclos anteriores (0..329) el contador BCD cuenta "unos", asi
--   que  cuentas = 330 * (densidad de unos) = Vin * 100  ->  X.XX V directo.
--   330 = 1 0100 1010b  -> primera vez que q(8), q(6), q(3) y q(1) valen '1'.
----------------------------------------------------------------------------------
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
    tc_int  <= q(8) and q(6) and q(3) and q(1);   -- 330
    rst_int <= rst or tc_int;                     -- reset sincronico al llegar a 330

    -- Contador binario con FFs tipo T (D = Q xor T)
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