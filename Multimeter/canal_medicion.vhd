-- Un canal de medición cuenta las muestras altas durante la ventana común.
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

    -- La red RC recibe la muestra invertida por el pin de realimentación.
    feedback_o <= not muestra_q;

    -- El último ciclo de la ventana se reserva para guardar la lectura.
    cuenta_ena <= muestra_q and not fin_ventana_i;
    cuenta_rst <= rst_i or fin_ventana_i;
    contador : entity work.bcd_counter_3d(structural)
        port map (clk => clk_i, rst => cuenta_rst,
                  ena => cuenta_ena, q_out => cuenta_bcd);

    -- El registro captura la cuenta en el mismo flanco que pone el contador a cero.
    resultado : entity work.reg_12bit(structural)
        port map (clk => clk_i, rst => rst_i, ena => fin_ventana_i,
                  d_in => cuenta_bcd, q_out => lectura_o);
end estructural;
