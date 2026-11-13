-- Tres lecturas d.ddV con cinco celdas de 128 x 128 píxeles por fila.
library ieee;
use ieee.numeric_bit.all;

entity mux_logic is
    port (
        pixel_x, pixel_y : in  bit_vector(9 downto 0);
        reg1, reg2, reg3 : in  bit_vector(11 downto 0);
        char_out         : out bit_vector(3 downto 0);
        font_col, font_row : out bit_vector(2 downto 0);
        panel_o          : out bit_vector(1 to 3);
        lectura_fila_o   : out bit_vector(11 downto 0)
    );
end mux_logic;

architecture structural of mux_logic is
    constant COD_V       : bit_vector(3 downto 0) := "1010";
    constant COD_PUNTO   : bit_vector(3 downto 0) := "1011";
    constant COD_ESPACIO : bit_vector(3 downto 0) := "1100";

    signal panel : bit_vector(1 to 3);
    signal lectura : bit_vector(11 downto 0);
    signal bloque_y : unsigned(5 downto 0);
    signal origen_fuente : unsigned(2 downto 0);
    signal fila_texto : bit;
    signal codigo_celda : bit_vector(3 downto 0);
begin
    -- Cada panel ocupa diez bloques de 16 líneas. El texto ocupa los ocho centrales.
    bloque_y <= unsigned(pixel_y(9 downto 4));
    panel(1) <= '1' when bloque_y < 10 else '0';
    panel(2) <= '1' when bloque_y >= 10 and bloque_y < 20 else '0';
    panel(3) <= '1' when bloque_y >= 20 and bloque_y < 30 else '0';
    fila_texto <= '1' when (bloque_y >= 1 and bloque_y <= 8)
                        or (bloque_y >= 11 and bloque_y <= 18)
                        or (bloque_y >= 21 and bloque_y <= 28) else '0';

    -- La barra y las cifras de cada panel comparten la lectura capturada al inicio del cuadro.
    digitos : for i in lectura'range generate
        lectura(i) <= (panel(1) and reg1(i)) or (panel(2) and reg2(i)) or (panel(3) and reg3(i));
    end generate;
    lectura_fila_o <= lectura;
    panel_o <= panel;

    with pixel_x(9 downto 7) select
        codigo_celda <= lectura(11 downto 8) when "000",
                        COD_PUNTO            when "001",
                        lectura(7 downto 4)  when "010",
                        lectura(3 downto 0)  when "011",
                        COD_V                when "100",
                        COD_ESPACIO          when others;
    char_out <= codigo_celda when fila_texto = '1' else COD_ESPACIO;

    -- Cada punto de la ROM ocupa 16 x 16 píxeles. Las primeras filas de texto
    -- corresponden a los bloques 1, 11 y 21, cuyos tres bits inferiores son 1, 3 y 5.
    origen_fuente <= "011" when panel(2) = '1' else
                     "101" when panel(3) = '1' else "001";
    font_row <= bit_vector(bloque_y(2 downto 0) - origen_fuente);
    font_col <= pixel_x(6 downto 4);
end structural;
