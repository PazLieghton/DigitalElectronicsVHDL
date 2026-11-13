-- Los tres canales comparten la ventana de medición y envían sus lecturas al controlador VGA.
entity Voltimetro is
    port (
        clk_i, rst_i : in bit;
        data_volt_in_i : in bit_vector(2 downto 0);
        data_volt_out_o : out bit_vector(2 downto 0);
        hs_o, vs_o, red_o, grn_o, blu_o : out bit
    );
end Voltimetro;

architecture estructural of Voltimetro is
    signal fin_ventana : bit;
    signal lectura1, lectura2, lectura3 : bit_vector(11 downto 0);
begin
    ventana : entity work.bin_counter(structural)
        port map (clk => clk_i, rst => rst_i, tc => fin_ventana);

    canal1 : entity work.canal_medicion(estructural)
        port map (clk_i => clk_i, rst_i => rst_i, entrada_i => data_volt_in_i(0),
                  fin_ventana_i => fin_ventana, feedback_o => data_volt_out_o(0),
                  lectura_o => lectura1);
    canal2 : entity work.canal_medicion(estructural)
        port map (clk_i => clk_i, rst_i => rst_i, entrada_i => data_volt_in_i(1),
                  fin_ventana_i => fin_ventana, feedback_o => data_volt_out_o(1),
                  lectura_o => lectura2);
    canal3 : entity work.canal_medicion(estructural)
        port map (clk_i => clk_i, rst_i => rst_i, entrada_i => data_volt_in_i(2),
                  fin_ventana_i => fin_ventana, feedback_o => data_volt_out_o(2),
                  lectura_o => lectura3);

    pantalla : entity work.Vga_lab(estructural)
        port map (clk_i => clk_i, reg1_i => lectura1, reg2_i => lectura2, reg3_i => lectura3,
                  hs_o => hs_o, vs_o => vs_o, red_o => red_o, grn_o => grn_o, blu_o => blu_o);
end estructural;
