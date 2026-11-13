-- Contador BCD de 000 a 999. Las tres décadas usan el mismo reloj.
-- El acarreo de las unidades habilita las decenas y el de las decenas habilita las centenas.
entity bcd_counter_3d is
    port (
        clk   : in  bit;
        rst   : in  bit;
        ena   : in  bit;
        q_out : out bit_vector(11 downto 0)
    );
end bcd_counter_3d;

architecture structural of bcd_counter_3d is
    component bcd_counter is
        port (
            clk   : in  bit;
            rst   : in  bit;
            ena   : in  bit;
            q_out : out bit_vector(3 downto 0);
            co    : out bit
        );
    end component;
    signal q_u, q_t, q_h : bit_vector(3 downto 0);
    signal co_u, co_t    : bit;
begin
    U1: bcd_counter port map(clk => clk, rst => rst, ena => ena,  q_out => q_u, co => co_u);
    T1: bcd_counter port map(clk => clk, rst => rst, ena => co_u, q_out => q_t, co => co_t);
    H1: bcd_counter port map(clk => clk, rst => rst, ena => co_t, q_out => q_h, co => open);

    q_out <= q_h & q_t & q_u;
end structural;
