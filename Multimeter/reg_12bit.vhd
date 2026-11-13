-- Registro de 12 bits. Una habilitación común permite capturar los tres dígitos BCD a la vez.
entity reg_12bit is
    port (
        clk   : in  bit;
        rst   : in  bit;
        ena   : in  bit;
        d_in  : in  bit_vector(11 downto 0);
        q_out : out bit_vector(11 downto 0)
    );
end reg_12bit;

architecture structural of reg_12bit is
    component ffd_en is
        port(
            clk_i : in  bit;
            rst_i : in  bit;
            ena_i : in  bit;
            d_i   : in  bit;
            q_o   : out bit
        );
    end component;
begin
    ff_gen: for i in 0 to 11 generate
        f: ffd_en port map(clk_i => clk, rst_i => rst, ena_i => ena,
                        d_i => d_in(i), q_o => q_out(i));
    end generate;
end structural;
