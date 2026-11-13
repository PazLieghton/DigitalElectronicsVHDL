library ieee;
use ieee.std_logic_1164.all;

-- Conexiones entre la placa EP2C5 y los tres canales del voltímetro.
architecture voltimetro_3canales of acyiib is
    signal clk_bit : bit;
    signal entradas, salidas : bit_vector(2 downto 0);
    signal hs, vs, rojo, verde, azul : bit;
begin
    clk_bit <= to_bit(osc_50mhz);
    -- Entrada de muestreo y salida de realimentación de cada red RC.
    entradas(0) <= to_bit(pin89);
    pin87 <= to_stdulogic(salidas(0));
    entradas(1) <= to_bit(pin88);
    pin74 <= to_stdulogic(salidas(1));
    entradas(2) <= to_bit(pin100);
    pin75 <= to_stdulogic(salidas(2));

    nucleo : entity work.Voltimetro_toplevel(Voltimetro_toplevel_arq)
        port map (clk_i => clk_bit, rst_i => '0',
                  data_volt_in_i => entradas, data_volt_out_o => salidas,
                  hs_o => hs, vs_o => vs, red_o => rojo, grn_o => verde, blu_o => azul);

    pin79 <= to_stdulogic(hs);
    pin99 <= to_stdulogic(vs);
    pin96 <= to_stdulogic(rojo);
    pin92 <= to_stdulogic(verde);
    pin86 <= to_stdulogic(azul);

    -- P100 es bidireccional y se usa como entrada. Su salida queda en alta impedancia.
    pin100 <= 'Z';

    -- Pines bidireccionales sin uso.
    p1 <= (others => 'Z');
    pin73 <= 'Z';
    pin76 <= 'Z';
    p2_io1(8 to 9) <= (others => 'Z');
    p2_io2(17 to 18) <= (others => 'Z');
    p2_io2(20) <= 'Z';
    p2_io2(23 to 25) <= (others => 'Z');
end voltimetro_3canales;
