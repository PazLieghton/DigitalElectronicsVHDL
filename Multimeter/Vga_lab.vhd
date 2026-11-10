-- VGA: tres lecturas BCD reales, una por canal, con barras de comprobacion.
-- Entrada: 25 MHz, ya divididos por el top-level original.
-- 640x480 visibles, 800x525 totales, HS/VS activos en cero.
-- Nueva logica sintetizable: solo instancias, cables y compuertas.

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
    signal visible, hs, vs, hs_q, vs_q : bit;
    signal fila0, fila1, fila2, texto_en, texto_en_q : bit;
    signal caracter : bit_vector(3 downto 0);
    signal punto_rom, texto_pixel : bit;
    signal barra_y, marca_x : bit;
    signal rgb_fondo, rgb_fondo_q : bit_vector(2 downto 0);
begin
    horizontal : entity work.contador_binario10(estructural)
        generic map (LAST => "1100011111") -- 799
        port map (clk_i => clk_i, rst_i => '0', ena_i => '1',
                  q_o => h, ultimo_o => fin_linea);

    -- El reloj sigue siendo 25 MHz: fin_linea es ENABLE, no otro reloj.
    vertical : entity work.contador_binario10(estructural)
        generic map (LAST => "1000001100") -- 524
        port map (clk_i => clk_i, rst_i => '0', ena_i => fin_linea,
                  q_o => v, ultimo_o => fin_cuadro);

    -- Visible: h=0..639, v=0..479. Decodificacion con compuertas.
    visible <= not (h(9) and (h(8) or h(7)))
           and not v(9) and not (v(8) and v(7) and v(6) and v(5));

    -- HS bajo en 656..751; VS bajo en 490..491.
    hs <= not (h(9) and not h(8) and h(7)
           and (h(6) or h(5) or h(4))
           and not (h(6) and h(5) and h(4)));
    vs <= not (not v(9) and v(8) and v(7) and v(6) and v(5)
           and not v(4) and v(3) and not v(2) and v(1));

    -- Tres filas de 32 pixeles de alto; caracteres 8x8 ampliados x4.
    fila0 <= not v(9) and not v(8) and v(7) and not v(6) and not v(5);
    fila1 <= not v(9) and not v(8) and v(7) and v(6) and v(5);
    fila2 <= not v(9) and v(8) and not v(7) and v(6) and not v(5);
    texto_en <= visible and (fila0 or fila1 or fila2);

    -- Congelar las tres lecturas durante un cuadro: evita mezclar digitos.
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
                  char_out => caracter, font_col => font_col, font_row => font_row);

    fuente : entity work.ROM(ROM_arq)
        port map (clk => clk_i, char_address => caracter,
                  font_col => font_col, font_row => font_row,
                  data_out => punto_rom);

    -- Barras arriba y marcadores de canal junto a los textos.
    barra_y <= not v(9) and not v(8) and not v(7) and (v(6) xor v(5));
    marca_x <= not h(9) and not h(8) and h(7) and not h(6);
    rgb_fondo(2) <= visible and ((barra_y and not h(9) and not h(8) and h(7))
                              or (marca_x and fila0));
    rgb_fondo(1) <= visible and ((barra_y and not h(9) and h(8) and not h(7))
                              or (marca_x and fila1));
    rgb_fondo(0) <= visible and ((barra_y and not h(9) and h(8) and h(7))
                              or (marca_x and fila2));

    -- La ROM es SINCRONICA: retrasar tambien las otras senales un ciclo.
    ret_hs : entity work.ffd_en(adaptador)
        port map (clk_i => clk_i, rst_i => '0', ena_i => '1', d_i => hs, q_o => hs_q);
    ret_vs : entity work.ffd_en(adaptador)
        port map (clk_i => clk_i, rst_i => '0', ena_i => '1', d_i => vs, q_o => vs_q);
    ret_texto : entity work.ffd_en(adaptador)
        port map (clk_i => clk_i, rst_i => '0', ena_i => '1', d_i => texto_en, q_o => texto_en_q);
    ret_rgb : for i in 0 to 2 generate
        ff : entity work.ffd_en(adaptador)
            port map (clk_i => clk_i, rst_i => '0', ena_i => '1',
                      d_i => rgb_fondo(i), q_o => rgb_fondo_q(i));
    end generate;

    texto_pixel <= punto_rom and texto_en_q;
    red_o <= rgb_fondo_q(2) or texto_pixel;
    grn_o <= rgb_fondo_q(1) or texto_pixel;
    blu_o <= rgb_fondo_q(0) or texto_pixel;
    hs_o <= hs_q;
    vs_o <= vs_q;
end estructural;
