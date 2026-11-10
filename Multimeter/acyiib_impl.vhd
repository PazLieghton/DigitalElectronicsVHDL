library ieee;
use ieee.std_logic_1164.all;

-- Arquitectura de la capsula suministrada; la entidad acyiib no se modifica.
architecture voltimetro_3canales of acyiib is
    signal clk_bit : bit;
    signal entradas, salidas : bit_vector(2 downto 0);
    signal hs, vs, rojo, verde, azul : bit;
begin
    clk_bit <= to_bit(osc_50mhz);
    entradas(0) <= to_bit(pin89); -- Canal 1: entrada P89, feedback P87.
    entradas(1) <= to_bit(pin88); -- Canal 2: entrada P88, feedback P80.
    entradas(2) <= to_bit(pin90); -- Canal 3: entrada P90, feedback P81.

    nucleo : entity work.Voltimetro_toplevel(Voltimetro_toplevel_arq)
        port map (clk_i => clk_bit, rst_i => '0',
                  data_volt_in_i => entradas, data_volt_out_o => salidas,
                  hs_o => hs, vs_o => vs, red_o => rojo, grn_o => verde, blu_o => azul);

    pin79 <= to_stdulogic(hs);
    pin99 <= to_stdulogic(vs);
    pin96 <= to_stdulogic(rojo);
    pin92 <= to_stdulogic(verde);
    pin86 <= to_stdulogic(azul);
    pin87 <= to_stdulogic(salidas(0));
    pin80 <= to_stdulogic(salidas(1));
    pin81 <= to_stdulogic(salidas(2));

    p1 <= (others => 'Z');
    p2_io1(3 to 6) <= (others => 'Z');
    p2_io2(17 to 18) <= (others => 'Z');
    p2_io2(20) <= 'Z';
    p2_io2(22 to 25) <= (others => 'Z');
    -- p2_in es exclusivamente entrada. P91 queda disponible.
    -- El reset esta fijado a cero; la capsula no exporta el pulsador P144.
end voltimetro_3canales;
