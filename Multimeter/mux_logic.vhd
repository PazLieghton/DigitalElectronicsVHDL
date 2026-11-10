----------------------------------------------------------------------------------
-- mux_logic : generador de texto (logica de control de la pantalla)
--
--  Celdas de caracter de 32x32 px (cada pixel de la fuente 8x8 se ve de 4x4):
--     columna de caracter = pixel_x(9..5)   fila de caracter = pixel_y(8..5)
--     font_col = pixel_x(4..2)               font_row = pixel_y(4..2)
--
--  Pantalla (3 lineas, una por canal):
--       col:  6   7   8   9   10  11  12  13
--             n  ' '  d   .   d   d  ' '  V        n = numero de canal (1,2,3)
--  filas de caracter: 4 -> canal 1, 7 -> canal 2, 10 -> canal 3
--
--  Direcciones de la ROM (ROM_EP2C5.vhd): '0'..'9' = 0..9, 'V' = 10, '.' = 11, ' ' = 12
----------------------------------------------------------------------------------
entity mux_logic is
    port (
        pixel_x  : in  bit_vector(9 downto 0);
        pixel_y  : in  bit_vector(9 downto 0);
        reg1     : in  bit_vector(11 downto 0);   -- canal 1 (cent & dec & uni)
        reg2     : in  bit_vector(11 downto 0);
        reg3     : in  bit_vector(11 downto 0);
        char_out : out bit_vector(3 downto 0);
        font_col : out bit_vector(2 downto 0);
        font_row : out bit_vector(2 downto 0)
    );
end mux_logic;

architecture structural of mux_logic is
    constant K_V   : bit_vector(3 downto 0) := "1010";
    constant K_DOT : bit_vector(3 downto 0) := "1011";
    constant K_SP  : bit_vector(3 downto 0) := "1100";

    signal row1, row2, row3, text_row : bit;
    signal col6, col8, col9, col10, col11, col13, used_col : bit;
    signal sel6, sel8, sel9, sel10, sel11, sel13, sel_sp   : bit;

    signal r1v, r2v, r3v                       : bit_vector(3 downto 0);
    signal s6v, s8v, s9v, s10v, s11v, s13v, spv : bit_vector(3 downto 0);
    signal ch_code, dig_v, dig_d, dig_c        : bit_vector(3 downto 0);
begin
    -- Filas de caracter: y(8..5) = 0100 (4), 0111 (7), 1010 (10)
    row1 <= (not pixel_y(9)) and (not pixel_y(8)) and pixel_y(7) and (not pixel_y(6)) and (not pixel_y(5));
    row2 <= (not pixel_y(9)) and (not pixel_y(8)) and pixel_y(7) and pixel_y(6) and pixel_y(5);
    row3 <= (not pixel_y(9)) and pixel_y(8) and (not pixel_y(7)) and pixel_y(6) and (not pixel_y(5));
    text_row <= row1 or row2 or row3;

    -- Columnas de caracter: x(9..5) = 6 (00110), 8 (01000), 9 (01001),
    --                                  10 (01010), 11 (01011), 13 (01101)
    col6  <= (not pixel_x(9)) and (not pixel_x(8)) and pixel_x(7) and pixel_x(6) and (not pixel_x(5));
    col8  <= (not pixel_x(9)) and pixel_x(8) and (not pixel_x(7)) and (not pixel_x(6)) and (not pixel_x(5));
    col9  <= (not pixel_x(9)) and pixel_x(8) and (not pixel_x(7)) and (not pixel_x(6)) and pixel_x(5);
    col10 <= (not pixel_x(9)) and pixel_x(8) and (not pixel_x(7)) and pixel_x(6) and (not pixel_x(5));
    col11 <= (not pixel_x(9)) and pixel_x(8) and (not pixel_x(7)) and pixel_x(6) and pixel_x(5);
    col13 <= (not pixel_x(9)) and pixel_x(8) and pixel_x(7) and (not pixel_x(6)) and pixel_x(5);
    used_col <= col6 or col8 or col9 or col10 or col11 or col13;

    -- Seleccion final (fila de texto Y columna de texto)
    sel6   <= text_row and col6;
    sel8   <= text_row and col8;
    sel9   <= text_row and col9;
    sel10  <= text_row and col10;
    sel11  <= text_row and col11;
    sel13  <= text_row and col13;
    sel_sp <= not (text_row and used_col);       -- todo lo demas: espacio

    -- Replicas de 4 bits para poder usar and/or sobre vectores
    r1v  <= (others => row1);
    r2v  <= (others => row2);
    r3v  <= (others => row3);
    s6v  <= (others => sel6);
    s8v  <= (others => sel8);
    s9v  <= (others => sel9);
    s10v <= (others => sel10);
    s11v <= (others => sel11);
    s13v <= (others => sel13);
    spv  <= (others => sel_sp);

    -- Numero de canal segun la fila: 0001, 0010, 0011
    ch_code(3) <= '0';
    ch_code(2) <= '0';
    ch_code(1) <= row2 or row3;
    ch_code(0) <= row1 or row3;

    -- Digito de cada posicion, elegido segun la fila (canal)
    dig_v <= (reg1(11 downto 8) and r1v) or (reg2(11 downto 8) and r2v) or (reg3(11 downto 8) and r3v);
    dig_d <= (reg1(7 downto 4)  and r1v) or (reg2(7 downto 4)  and r2v) or (reg3(7 downto 4)  and r3v);
    dig_c <= (reg1(3 downto 0)  and r1v) or (reg2(3 downto 0)  and r2v) or (reg3(3 downto 0)  and r3v);

    -- Codigo de caracter final
    char_out <= (s6v and ch_code) or (s8v and dig_v) or (s10v and dig_d) or (s11v and dig_c)
                or (s9v and K_DOT) or (s13v and K_V) or (spv and K_SP);

    font_col <= pixel_x(4 downto 2);
    font_row <= pixel_y(4 downto 2);
end structural;