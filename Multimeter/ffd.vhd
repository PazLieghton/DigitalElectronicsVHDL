-- Biestable D de flanco ascendente con borrado sincrónico activo en alto.
entity ffd is
	port(
		clk	: in bit;
		rst : in bit;
		d	: in bit;
		q	: out bit
	);
end ffd;

architecture ffd_arq of ffd is
begin
	process(clk) 
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				q <= '0';
			else
				q <= d;
			end if;
		end if; 
	end process;
end;

-- Con la habilitación en cero, la realimentación de Q conserva el dato.
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
