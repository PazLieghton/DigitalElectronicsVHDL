-- Un canal: muestreo sigma-delta, cuenta de unos y registro del resultado.
-- fin_ventana_i se comparte entre los tres canales.
entity canal_medicion is
    port (
        clk_i, rst_i, entrada_i, fin_ventana_i : in bit;
        feedback_o : out bit;
        lectura_o : out bit_vector(11 downto 0)
    );
end canal_medicion;

architecture estructural of canal_medicion is
    signal muestra_q, cuenta_ena, cuenta_rst : bit;
    signal cuenta_bcd : bit_vector(11 downto 0);
begin
    entrada : entity work.sigma_delta(structural)
        port map (clk => clk_i, rst => rst_i,
                  data_volt_in => entrada_i, data_volt_out => muestra_q);

    -- El RC de la guia se realimenta con Q negada.
    feedback_o <= not muestra_q;

    -- Timer 0..329: contar unos. Timer 330: guardar y limpiar.
    cuenta_ena <= muestra_q and not fin_ventana_i;
    cuenta_rst <= rst_i or fin_ventana_i;
    contador : entity work.bcd_counter_3d(structural)
        port map (clk => clk_i, rst => cuenta_rst,
                  ena => cuenta_ena, q_out => cuenta_bcd);

    -- En el mismo flanco, el registro recibe el valor ANTERIOR al reset.
    resultado : entity work.reg_12bit(structural)
        port map (clk => clk_i, rst => rst_i, ena => fin_ventana_i,
                  d_in => cuenta_bcd, q_out => lectura_o);
end estructural;
