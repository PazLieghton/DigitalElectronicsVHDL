-- Salida VGA de 640 x 480 píxeles con reloj de 25 MHz y sincronismos activos en bajo.
library ieee;
use ieee.numeric_bit.all;

entity Vga_lab is
    port (
        clk_i : in bit;
        reg1_i, reg2_i, reg3_i : in bit_vector(11 downto 0);
        hs_o, vs_o, red_o, grn_o, blu_o : out bit
    );
end Vga_lab;

architecture estructural of Vga_lab is
    signal h, v : bit_vector(9 downto 0);
    signal fin_linea, fin_cuadro, captura_cuadro : bit;
    signal reg1_frame, reg2_frame, reg3_frame : bit_vector(11 downto 0);
    signal font_col, font_row : bit_vector(2 downto 0);
    signal visible, hs, vs, visible_q, hs_q, vs_q : bit;
    signal rgb_salida : bit_vector(2 downto 0);
    signal caracter : bit_vector(3 downto 0);
    signal punto_rom : bit;

    signal panel : bit_vector(1 to 3);
    signal lectura_fila, avance, iguales : bit_vector(11 downto 0);
    signal fila_barra, columna_barra, en_barra, nivel_alcanzado : bit;
    signal relleno, escala, punto_barra : bit;
    signal rgb_barra, rgb_barra_q : bit_vector(2 downto 0);
begin
    horizontal : entity work.contador_binario10(estructural)
        generic map (LAST => "1100011111") -- 799
        port map (clk_i => clk_i, rst_i => '0', ena_i => '1',
                  q_o => h, ultimo_o => fin_linea);

    -- El contador vertical avanza un paso al terminar cada línea.
    vertical : entity work.contador_binario10(estructural)
        generic map (LAST => "1000001100") -- 524
        port map (clk_i => clk_i, rst_i => '0', ena_i => fin_linea,
                  q_o => v, ultimo_o => fin_cuadro);

    visible <= not (h(9) and (h(8) or h(7)))
           and not v(9) and not (v(8) and v(7) and v(6) and v(5));

    -- HS permanece bajo de 656 a 751 y VS de 490 a 491, extremos incluidos.
    hs <= not (h(9) and not h(8) and h(7)
           and (h(6) or h(5) or h(4))
           and not (h(6) and h(5) and h(4)));
    vs <= not (not v(9) and v(8) and v(7) and v(6) and v(5)
           and not v(4) and v(3) and not v(2) and v(1));

    -- Las tres lecturas cambian juntas entre dos cuadros.
    captura_cuadro <= fin_linea and fin_cuadro;
    frame1 : entity work.reg_12bit(structural)
        port map (clk => clk_i, rst => '0', ena => captura_cuadro,
                  d_in => reg1_i, q_out => reg1_frame);
    frame2 : entity work.reg_12bit(structural)
        port map (clk => clk_i, rst => '0', ena => captura_cuadro,
                  d_in => reg2_i, q_out => reg2_frame);
    frame3 : entity work.reg_12bit(structural)
        port map (clk => clk_i, rst => '0', ena => captura_cuadro,
                  d_in => reg3_i, q_out => reg3_frame);

    texto : entity work.mux_logic(structural)
        port map (pixel_x => h, pixel_y => v,
                  reg1 => reg1_frame, reg2 => reg2_frame, reg3 => reg3_frame,
                  char_out => caracter, font_col => font_col, font_row => font_row,
                  panel_o => panel, lectura_fila_o => lectura_fila);

    fuente : entity work.ROM(ROM_arq)
        port map (clk => clk_i, char_address => caracter,
                  font_col => font_col, font_row => font_row, data_out => punto_rom);

    -- Las barras ocupan ocho líneas a partir de y = 144, 304 y 464.
    fila_barra <= '1' when unsigned(v(9 downto 3)) = 18
                        or unsigned(v(9 downto 3)) = 38
                        or unsigned(v(9 downto 3)) = 58 else '0';
    -- Los 330 píxeles de la escala dejan 155 de margen a cada lado. Cada píxel vale 0,01 V.
    columna_barra <= '1' when unsigned(h) >= 155 and unsigned(h) <= 484 else '0';
    en_barra <= fila_barra and columna_barra;

    -- El barrido cuenta píxeles en BCD hasta igualar la lectura del canal.
    -- Se reutiliza el mismo contador en las tres barras.
    contador_barra : entity work.bcd_counter_3d(structural)
        port map (clk => clk_i, rst => fin_linea, ena => relleno, q_out => avance);
    iguales <= not (avance xor lectura_fila);
    nivel_alcanzado <= iguales(11) and iguales(10) and iguales(9) and iguales(8)
                   and iguales(7) and iguales(6) and iguales(5) and iguales(4)
                   and iguales(3) and iguales(2) and iguales(1) and iguales(0);
    relleno <= en_barra and not nivel_alcanzado;

    -- Una base punteada conserva la referencia de fondo de escala al medir cero.
    escala <= en_barra and v(2) and v(1) and v(0) and not h(1) and not h(0);
    punto_barra <= relleno or escala;
    rgb_barra(2) <= punto_barra and (panel(1) or panel(3));
    rgb_barra(1) <= punto_barra and (panel(1) or panel(2));
    rgb_barra(0) <= punto_barra and (panel(2) or panel(3));

    -- La ROM entrega el punto un ciclo después. La visibilidad, el color y los
    -- sincronismos llevan el mismo retardo para que correspondan al mismo píxel.
    ret_hs : entity work.ffd(ffd_arq)
        port map (clk => clk_i, rst => '0', d => hs, q => hs_q);
    ret_vs : entity work.ffd(ffd_arq)
        port map (clk => clk_i, rst => '0', d => vs, q => vs_q);
    ret_visible : entity work.ffd(ffd_arq)
        port map (clk => clk_i, rst => '0', d => visible, q => visible_q);
    ret_rgb : for i in rgb_barra'range generate
        ff : entity work.ffd(ffd_arq)
            port map (clk => clk_i, rst => '0', d => rgb_barra(i), q => rgb_barra_q(i));
    end generate;

    rgb_salida(2) <= visible_q and (punto_rom or rgb_barra_q(2));
    rgb_salida(1) <= visible_q and (punto_rom or rgb_barra_q(1));
    rgb_salida(0) <= visible_q and (punto_rom or rgb_barra_q(0));

    -- Registrar la mezcla final evita propagar transitorios de las compuertas RGB.
    -- Los sincronismos reciben el mismo ciclo adicional de retardo.
    salida_roja : entity work.ffd(ffd_arq)
        port map (clk => clk_i, rst => '0', d => rgb_salida(2), q => red_o);
    salida_verde : entity work.ffd(ffd_arq)
        port map (clk => clk_i, rst => '0', d => rgb_salida(1), q => grn_o);
    salida_azul : entity work.ffd(ffd_arq)
        port map (clk => clk_i, rst => '0', d => rgb_salida(0), q => blu_o);
    salida_hs : entity work.ffd(ffd_arq)
        port map (clk => clk_i, rst => '0', d => hs_q, q => hs_o);
    salida_vs : entity work.ffd(ffd_arq)
        port map (clk => clk_i, rst => '0', d => vs_q, q => vs_o);
end estructural;
