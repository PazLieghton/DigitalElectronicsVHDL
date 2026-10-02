-- ============================================================
--  RELOJ DIGITAL 12 HORAS  hh:mm:ss  (01:00:00 .. 12:59:59)
--  - EN   : habilita / deshabilita el conteo (0 = congela)
--  - SET  : modo ajuste. Mientras SET=1 el reloj no cuenta y
--           los botones modifican la hora:
--             BTN_H -> +1 hora    (12 -> 01)
--             BTN_M -> +1 minuto  (59 -> 00, sin acarreo a hora)
--             BTN_S -> segundos a 00
--  - PM_LED : '0' = AM, '1' = PM (conmuta al pasar 11:59:59 -> 12:00:00)
--  - COLON  : parpadeo de los dos puntos (1 s encendido / 1 s apagado
--             cuando se usa el divisor real)
--  - 6 displays de 7 segmentos, orden de bits (6 downto 0) = a b c d e f g
--    Logica ACTIVA EN ALTO (catodo comun). Para anodo comun, negar salidas.
--  - Cero a la izquierda de la decena de hora apagado (" 1:30:00")
--  - CLK es el reloj de placa; el divisor genera una HABILITACION
--    de 1 Hz (no un reloj derivado). Para simular, usar DIVISOR chico.
--  Reglas del TP: solo STD_LOGIC_1164, clk'event, sin funciones,
--  sin conversiones, enteros acotados para los digitos.
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reloj12h is
    generic (
        DIVISOR : integer := 50000000   -- ciclos de CLK por segundo (50 MHz)
    );
    Port (
        CLK    : in  STD_LOGIC;
        RESET  : in  STD_LOGIC;          -- asincronico, fija 12:00:00 AM
        EN     : in  STD_LOGIC;
        SET    : in  STD_LOGIC;
        BTN_H  : in  STD_LOGIC;
        BTN_M  : in  STD_LOGIC;
        BTN_S  : in  STD_LOGIC;
        SEG_HD : out STD_LOGIC_VECTOR(6 downto 0);  -- decenas de hora
        SEG_HU : out STD_LOGIC_VECTOR(6 downto 0);  -- unidades de hora
        SEG_MD : out STD_LOGIC_VECTOR(6 downto 0);  -- decenas de minuto
        SEG_MU : out STD_LOGIC_VECTOR(6 downto 0);  -- unidades de minuto
        SEG_SD : out STD_LOGIC_VECTOR(6 downto 0);  -- decenas de segundo
        SEG_SU : out STD_LOGIC_VECTOR(6 downto 0);  -- unidades de segundo
        PM_LED : out STD_LOGIC;
        COLON  : out STD_LOGIC
    );
end reloj12h;

architecture Behavioral of reloj12h is
    -- Digitos con rango limitado
    signal hd : integer range 0 to 1 := 1;
    signal hu : integer range 0 to 9 := 2;
    signal md : integer range 0 to 5 := 0;
    signal mu : integer range 0 to 9 := 0;
    signal sd : integer range 0 to 5 := 0;
    signal su : integer range 0 to 9 := 0;

    signal pm     : STD_LOGIC := '0';
    signal div    : integer range 0 to DIVISOR-1 := 0;
    signal prev_h : STD_LOGIC := '0';
    signal prev_m : STD_LOGIC := '0';
    signal prev_s : STD_LOGIC := '0';
begin

    -- --------------------------------------------------------
    --  Proceso secuencial: reloj + ajuste + acarreos anidados
    -- --------------------------------------------------------
    process(CLK, RESET)
        variable s_inc : STD_LOGIC;
        variable m_inc : STD_LOGIC;
        variable h_inc : STD_LOGIC;
    begin
        if RESET = '1' then
            hd <= 1;  hu <= 2;          -- 12
            md <= 0;  mu <= 0;
            sd <= 0;  su <= 0;
            pm <= '0';
            div <= 0;
            prev_h <= '0';  prev_m <= '0';  prev_s <= '0';
            COLON <= '1';
        elsif CLK'event and CLK = '1' then
            -- memoria de botones para detectar el flanco de pulsacion
            prev_h <= BTN_H;
            prev_m <= BTN_M;
            prev_s <= BTN_S;

            s_inc := '0';
            m_inc := '0';
            h_inc := '0';

            if SET = '1' then
                -- MODO AJUSTE: no cuenta, un pulso = un incremento
                div <= 0;
                COLON <= '1';
                if BTN_H = '1' and prev_h = '0' then
                    h_inc := '1';
                end if;
                if BTN_M = '1' and prev_m = '0' then
                    m_inc := '1';
                end if;
                if BTN_S = '1' and prev_s = '0' then
                    sd <= 0;
                    su <= 0;
                end if;
            elsif EN = '1' then
                -- MODO RELOJ: habilitacion periodica de 1 segundo
                if div < DIVISOR/2 then
                    COLON <= '1';
                else
                    COLON <= '0';
                end if;
                if div = DIVISOR-1 then
                    div <= 0;
                    s_inc := '1';
                else
                    div <= div + 1;
                end if;
            end if;

            -- SEGUNDOS
            if s_inc = '1' then
                if su = 9 then
                    su <= 0;
                    if sd = 5 then
                        sd <= 0;
                        m_inc := '1';           -- 59 s -> acarreo a minutos
                    else
                        sd <= sd + 1;
                    end if;
                else
                    su <= su + 1;
                end if;
            end if;

            -- MINUTOS
            if m_inc = '1' then
                if mu = 9 then
                    mu <= 0;
                    if md = 5 then
                        md <= 0;
                        if SET = '0' then
                            h_inc := '1';       -- 59 min -> acarreo a horas
                        end if;                 -- (en ajuste no acarrea)
                    else
                        md <= md + 1;
                    end if;
                else
                    mu <= mu + 1;
                end if;
            end if;

            -- HORAS (1..12)
            if h_inc = '1' then
                if hd = 1 and hu = 2 then       -- 12 -> 01
                    hd <= 0;
                    hu <= 1;
                elsif hd = 1 and hu = 1 then    -- 11 -> 12, cambia AM/PM
                    hu <= 2;
                    pm <= not pm;
                elsif hu = 9 then               -- 09 -> 10
                    hu <= 0;
                    hd <= 1;
                else
                    hu <= hu + 1;
                end if;
            end if;
        end if;
    end process;

    PM_LED <= pm;

    -- --------------------------------------------------------
    --  Decodificadores BCD -> 7 segmentos (a b c d e f g)
    -- --------------------------------------------------------
    process(hd, hu, md, mu, sd, su)
    begin
        -- Decena de hora: solo '1' o apagado
        case hd is
            when 1      => SEG_HD <= "0110000";
            when others => SEG_HD <= "0000000";
        end case;

        case hu is
            when 0 => SEG_HU <= "1111110";
            when 1 => SEG_HU <= "0110000";
            when 2 => SEG_HU <= "1101101";
            when 3 => SEG_HU <= "1111001";
            when 4 => SEG_HU <= "0110011";
            when 5 => SEG_HU <= "1011011";
            when 6 => SEG_HU <= "1011111";
            when 7 => SEG_HU <= "1110000";
            when 8 => SEG_HU <= "1111111";
            when 9 => SEG_HU <= "1111011";
            when others => SEG_HU <= "0000000";
        end case;

        case md is
            when 0 => SEG_MD <= "1111110";
            when 1 => SEG_MD <= "0110000";
            when 2 => SEG_MD <= "1101101";
            when 3 => SEG_MD <= "1111001";
            when 4 => SEG_MD <= "0110011";
            when 5 => SEG_MD <= "1011011";
            when others => SEG_MD <= "0000000";
        end case;

        case mu is
            when 0 => SEG_MU <= "1111110";
            when 1 => SEG_MU <= "0110000";
            when 2 => SEG_MU <= "1101101";
            when 3 => SEG_MU <= "1111001";
            when 4 => SEG_MU <= "0110011";
            when 5 => SEG_MU <= "1011011";
            when 6 => SEG_MU <= "1011111";
            when 7 => SEG_MU <= "1110000";
            when 8 => SEG_MU <= "1111111";
            when 9 => SEG_MU <= "1111011";
            when others => SEG_MU <= "0000000";
        end case;

        case sd is
            when 0 => SEG_SD <= "1111110";
            when 1 => SEG_SD <= "0110000";
            when 2 => SEG_SD <= "1101101";
            when 3 => SEG_SD <= "1111001";
            when 4 => SEG_SD <= "0110011";
            when 5 => SEG_SD <= "1011011";
            when others => SEG_SD <= "0000000";
        end case;

        case su is
            when 0 => SEG_SU <= "1111110";
            when 1 => SEG_SU <= "0110000";
            when 2 => SEG_SU <= "1101101";
            when 3 => SEG_SU <= "1111001";
            when 4 => SEG_SU <= "0110011";
            when 5 => SEG_SU <= "1011011";
            when 6 => SEG_SU <= "1011111";
            when 7 => SEG_SU <= "1110000";
            when 8 => SEG_SU <= "1111111";
            when 9 => SEG_SU <= "1111011";
            when others => SEG_SU <= "0000000";
        end case;
    end process;

end Behavioral;
