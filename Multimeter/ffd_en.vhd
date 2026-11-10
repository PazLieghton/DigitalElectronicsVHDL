-- Adaptador con habilitacion. Tu ffd.vhd original conserva sus cuatro puertos.
entity ffd_en is
    port (
        clk_i, rst_i, ena_i, d_i : in bit;
        q_o : out bit
    );
end ffd_en;

architecture adaptador of ffd_en is
    signal q_int, d_int : bit;
begin
    d_int <= (ena_i and d_i) or (not ena_i and q_int);
    base_ff : entity work.ffd(ffd_arq)
        port map (clk => clk_i, rst => rst_i, d => d_int, q => q_int);
    q_o <= q_int;
end adaptador;
