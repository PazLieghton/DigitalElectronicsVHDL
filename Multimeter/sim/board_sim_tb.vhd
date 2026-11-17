library ieee;
use ieee.std_logic_1164.all;

-- Cada pin de entrada recibe una secuencia ideal con la densidad de unos solicitada.
entity board_sim_tb is
    generic (
        CANAL1_CV : natural range 0 to 330 := 42;
        CANAL2_CV : natural range 0 to 330 := 165;
        CANAL3_CV : natural range 0 to 330 := 330;
        ARCHIVO_IMAGEN : string := "imagen.ppm"
    );
end entity;

architecture prueba of board_sim_tb is
    type tres_naturales is array (1 to 3) of natural;
    type tres_colores is array (1 to 3) of std_logic_vector(2 downto 0);
    constant consignas : tres_naturales := (CANAL1_CV, CANAL2_CV, CANAL3_CV);
    constant colores : tres_colores := ("110", "011", "101");
    signal osc : std_logic := '0';
    signal p1 : std_logic_vector(1 to 24);
    signal p2_io1 : std_logic_vector(3 to 11);
    signal p2_in : std_logic_vector(12 to 15) := (others => '0');
    signal p2_io2 : std_logic_vector(16 to 25);
    signal muestras : std_logic_vector(1 to 3) := (others => '0');
begin
    placa : entity work.acyiib(voltimetro_3canales)
        port map (osc, p1, p2_io1, p2_in, p2_io2);

    p2_in(13) <= muestras(1);  -- P89
    p2_in(12) <= muestras(2);  -- P88
    p2_io2(22) <= muestras(3); -- P100

    simular : process
        type archivo_binario is file of character;
        file imagen : archivo_binario open write_mode is ARCHIVO_IMAGEN;
        constant salto : character := character'val(10);
        constant cabecera : string := "P6" & salto & "640 480" & salto & "255" & salto;
        variable residuo, longitud : tres_naturales := (others => 0);
        variable puntos_linea, puntos_previos : tres_naturales := (others => 0);
        variable fase : natural range 0 to 330 := 0;
        variable pixel_x, pixel_y : natural;
        variable rgb : std_logic_vector(2 downto 0);
    begin
        for i in cabecera'range loop
            write(imagen, cabecera(i));
        end loop;

        -- El primer cuadro permite completar las mediciones y capturarlas para VGA.
        for cuadro in 0 to 1 loop
            for y in 0 to 524 loop
                puntos_linea := (others => 0);
                for x in 0 to 799 loop
                    -- La muestra tomada en 329 llega al contador en 330, cuando
                    -- se guarda la lectura. En ese ciclo conservamos la muestra.
                    if fase /= 329 then
                        for canal in consignas'range loop
                            residuo(canal) := residuo(canal) + consignas(canal);
                            if residuo(canal) >= 330 then
                                residuo(canal) := residuo(canal) - 330;
                                muestras(canal) <= '1';
                            else
                                muestras(canal) <= '0';
                            end if;
                        end loop;
                    end if;
                    fase := (fase + 1) mod 331;

                    -- Dos perÃ­odos del oscilador de 50 MHz producen un pÃ­xel.
                    wait for 10 ns;
                    osc <= '1';
                    wait for 10 ns;
                    osc <= '0';
                    assert (p2_io1(11) & p2_io1(4) & p2_io1(5)) = not muestras
                        report "Realimentacion incorrecta en P87, P74 o P75" severity failure;
                    -- La etapa final de salida entrega el píxel del ciclo anterior.
                    if x = 0 then
                        pixel_x := 799;
                        if y = 0 then pixel_y := 524; else pixel_y := y - 1; end if;
                    else
                        pixel_x := x - 1;
                        pixel_y := y;
                    end if;
                    assert p2_io1(7) = '0' or p2_io1(7) = '1' severity failure;
                    assert p2_io2(21) = '0' or p2_io2(21) = '1' severity failure;
                    assert (cuadro = 0 and x = 0 and y = 0) or (p2_io1(7) = '0') = (pixel_x >= 656 and pixel_x <= 751)
                        report "Sincronismo horizontal incorrecto en P79" severity failure;
                    assert (cuadro = 0 and x = 0 and y = 0) or (p2_io2(21) = '0') = (pixel_y >= 490 and pixel_y <= 491)
                        report "Sincronismo vertical incorrecto en P99" severity failure;

                    rgb := p2_io2(19) & p2_io2(16) & p2_io1(10); -- P96, P92, P86
                    if pixel_x >= 640 or pixel_y >= 480 then
                        assert rgb = "000" report "Color fuera del area visible" severity failure;
                    elsif cuadro = 1 then
                        for color in rgb'range loop
                            case rgb(color) is
                                when '0' => write(imagen, character'val(0));
                                when '1' => write(imagen, character'val(255));
                                when others => assert false report "Salida RGB indefinida" severity failure;
                            end case;
                        end loop;
                        for canal in consignas'range loop
                            if rgb = colores(canal) then
                                puntos_linea(canal) := puntos_linea(canal) + 1;
                            end if;
                        end loop;
                    end if;

                    wait for 10 ns;
                    osc <= '1';
                    wait for 10 ns;
                    osc <= '0';
                end loop;
                -- El relleno se repite en lÃ­neas consecutivas y mide un pÃ­xel por
                -- centivoltio. La lÃ­nea punteada de la escala aparece una sola vez.
                for canal in consignas'range loop
                    if puntos_linea(canal) > 0 and puntos_linea(canal) = puntos_previos(canal) then
                        longitud(canal) := puntos_linea(canal);
                    end if;
                end loop;
                puntos_previos := puntos_linea;
            end loop;
        end loop;
        for canal in consignas'range loop
            assert longitud(canal) = consignas(canal)
                report "Canal" & integer'image(canal) & ": barra de" & integer'image(longitud(canal)) &
                       " pixeles, se esperaban" & integer'image(consignas(canal)) severity failure;
        end loop;
        file_close(imagen);
        report "Captura VGA de 640 x 480 verificada." severity note;
        wait;
    end process;
end architecture;
