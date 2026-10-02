-- Testbench auto-verificable del reloj de 12 horas
-- CLK = 10 ns, DIVISOR = 2  ->  1 "segundo" = 20 ns
-- Los estimulos cambian en flancos descendentes (multiplos de 10 ns).
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_reloj12h is
end tb_reloj12h;

architecture Behavioral of tb_reloj12h is
    signal CLK   : STD_LOGIC := '0';
    signal RESET : STD_LOGIC := '0';
    signal EN    : STD_LOGIC := '0';
    signal SET   : STD_LOGIC := '0';
    signal BTN_H : STD_LOGIC := '0';
    signal BTN_M : STD_LOGIC := '0';
    signal BTN_S : STD_LOGIC := '0';
    signal SEG_HD, SEG_HU, SEG_MD, SEG_MU, SEG_SD, SEG_SU
                 : STD_LOGIC_VECTOR(6 downto 0);
    signal PM_LED, COLON : STD_LOGIC;
    signal done  : STD_LOGIC := '0';
begin
    -- Generador de reloj (se detiene al terminar el test)
    CLK <= not CLK after 5 ns when done = '0' else CLK;

    DUT: entity work.reloj12h
        generic map (DIVISOR => 2)
        port map (
            CLK => CLK, RESET => RESET, EN => EN, SET => SET,
            BTN_H => BTN_H, BTN_M => BTN_M, BTN_S => BTN_S,
            SEG_HD => SEG_HD, SEG_HU => SEG_HU,
            SEG_MD => SEG_MD, SEG_MU => SEG_MU,
            SEG_SD => SEG_SD, SEG_SU => SEG_SU,
            PM_LED => PM_LED, COLON => COLON
        );

    process
    begin
        ------------------------------------------------------
        -- CASO 1: Reset asincronico -> 12:00:00 AM
        ------------------------------------------------------
        RESET <= '1';  wait for 20 ns;
        RESET <= '0';  wait for 20 ns;
        assert SEG_HD = "0110000" and SEG_HU = "1101101"
            report "ERROR reset: hora distinta de 12" severity error;
        assert SEG_MD = "1111110" and SEG_MU = "1111110" and
               SEG_SD = "1111110" and SEG_SU = "1111110"
            report "ERROR reset: mm:ss distinto de 00:00" severity error;
        assert PM_LED = '0' report "ERROR reset: deberia ser AM" severity error;

        ------------------------------------------------------
        -- CASO 2: Ajuste a 11:59:00 (SET=1: 10 pulsos H, 59 pulsos M)
        ------------------------------------------------------
        SET <= '1';  wait for 20 ns;
        for i in 1 to 10 loop            -- 12 -> 01 -> ... -> 11
            BTN_H <= '1';  wait for 20 ns;
            BTN_H <= '0';  wait for 20 ns;
        end loop;
        for i in 1 to 59 loop
            BTN_M <= '1';  wait for 20 ns;
            BTN_M <= '0';  wait for 20 ns;
        end loop;
        BTN_S <= '1';  wait for 20 ns;
        BTN_S <= '0';  wait for 20 ns;
        assert SEG_HD = "0110000" and SEG_HU = "0110000"
            report "ERROR ajuste: hora distinta de 11" severity error;
        assert SEG_MD = "1011011" and SEG_MU = "1111011"
            report "ERROR ajuste: minutos distintos de 59" severity error;
        assert PM_LED = '0' report "ERROR ajuste: deberia seguir AM" severity error;

        ------------------------------------------------------
        -- CASO 3: Habilitar -> 11:59:59 -> 12:00:00 (cambio de hora, AM->PM)
        ------------------------------------------------------
        SET <= '0';  EN <= '1';
        wait for 1180 ns;                -- 59 "segundos"
        assert SEG_SD = "1011011" and SEG_SU = "1111011" and
               SEG_MU = "1111011" and SEG_HU = "0110000"
            report "ERROR: no llego a 11:59:59" severity error;
        wait for 20 ns;                  -- un segundo mas
        assert SEG_HD = "0110000" and SEG_HU = "1101101"
            report "ERROR: 11:59:59 no paso a 12" severity error;
        assert SEG_MD = "1111110" and SEG_MU = "1111110" and
               SEG_SD = "1111110" and SEG_SU = "1111110"
            report "ERROR: 11:59:59 no paso a 12:00:00" severity error;
        assert PM_LED = '1' report "ERROR: deberia ser PM" severity error;

        ------------------------------------------------------
        -- CASO 4: EN=0 congela el reloj
        ------------------------------------------------------
        EN <= '0';  wait for 100 ns;
        assert SEG_SU = "1111110" and SEG_SD = "1111110" and SEG_MU = "1111110"
            report "ERROR: EN=0 no congelo" severity error;

        ------------------------------------------------------
        -- CASO 5: 12:59:59 -> 01:00:00 (el salto 12 -> 1)
        ------------------------------------------------------
        SET <= '1';  wait for 20 ns;
        for i in 1 to 59 loop
            BTN_M <= '1';  wait for 20 ns;
            BTN_M <= '0';  wait for 20 ns;
        end loop;
        SET <= '0';  EN <= '1';
        wait for 1180 ns;
        assert SEG_HD = "0110000" and SEG_HU = "1101101" and
               SEG_MD = "1011011" and SEG_MU = "1111011" and
               SEG_SD = "1011011" and SEG_SU = "1111011"
            report "ERROR: no llego a 12:59:59" severity error;
        wait for 20 ns;
        assert SEG_HD = "0000000" and SEG_HU = "0110000"
            report "ERROR: 12 no paso a 01" severity error;
        assert SEG_MD = "1111110" and SEG_MU = "1111110" and
               SEG_SD = "1111110" and SEG_SU = "1111110"
            report "ERROR: 12:59:59 no paso a 01:00:00" severity error;
        assert PM_LED = '1' report "ERROR: 12->01 no debe cambiar AM/PM"
            severity error;

        ------------------------------------------------------
        -- CASO 6: Reset asincronico en cualquier estado
        ------------------------------------------------------
        wait for 33 ns;
        RESET <= '1';  wait for 1 ns;
        assert SEG_HD = "0110000" and SEG_HU = "1101101" and PM_LED = '0'
            report "ERROR: reset asincronico" severity error;
        RESET <= '0';

        report "FIN DE SIMULACION" severity note;
        done <= '1';
        wait;
    end process;
end Behavioral;
