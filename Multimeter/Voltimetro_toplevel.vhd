----------------------------------------------------------------------------------
-- Modulo 		Voltimetro_toplevel
-- Descripcion  Voltimetro implementado con un modulador sigma-delta
-- Placa        Altera EP2C5
-- Autor 		Electronica Digital I
--        		Escuela de Ciencia y Tecnologia - Universidad de San Martin
--
-- Fecha 		01/09/2020
-- NOTA: copia del top-level de la catedra con SOLO los puertos data_volt_* ampliados
--       a 3 canales (bit_vector(2 downto 0)). El resto es identico.
-- Actualizado  30/06/2026
----------------------------------------------------------------------------------

entity Voltimetro_toplevel is
	port(
		clk_i			: in bit;
		rst_i			: in bit;
		data_volt_in_i	: in bit_vector(2 downto 0);
		data_volt_out_o	: out bit_vector(2 downto 0);
		hs_o 			: out bit;
		vs_o 			: out bit;
		red_o 			: out bit;
		grn_o 			: out bit;
        blu_o 			: out bit
	);
	
end Voltimetro_toplevel;

architecture Voltimetro_toplevel_arq of Voltimetro_toplevel is

	-------------------------------------------------------------------------------------
	-- Declaracion del componente voltimetro
	--   Este componente incluye el bloque de procesamiento de datos y control y el
	--   flip-flop de entrada
	-------------------------------------------------------------------------------------
	component Voltimetro is
		port(
			clk_i      		: in bit;
			rst_i      		: in bit;
			data_volt_in_i  : in bit_vector(2 downto 0);
			data_volt_out_o : out bit_vector(2 downto 0);
			hs_o    		: out bit;
			vs_o    		: out bit;
			red_o  			: out bit;
			grn_o  			: out bit;
			blu_o  			: out bit
		);
	end component Voltimetro;
	
	-------------------------------------------------------------------------------------
	-- Declaracion del componente generador de reloj
	--   Se implementa con un ffd, alimentandolo con su propia salida negada
	-------------------------------------------------------------------------------------
	component ffd_en is
		port(
			clk_i : in bit;
			rst_i : in bit;
			ena_i : in bit;
			d_i   : in bit;
	  		q_o   : out bit
		);
    end component;
    
	signal clk25MHz, clk25MHz_n	: bit;
	
begin

	-- Generador del reloj lento
    ffd_i: ffd_en
        port map(
            clk_i => clk_i,     -- reloj del sistema (50 MHz)
            rst_i => '0',
            ena_i => '1',
            d_i   => clk25MHz_n,
            q_o   => clk25MHz   -- reloj generado (25 MHz)
        );

    clk25MHz_n <= not clk25MHz;

	-- Instancia del bloque voltimetro
	voltimetro_i: Voltimetro
		port map(
            clk_i			=> clk25MHz,
            rst_i			=> rst_i,
            data_volt_in_i	=> data_volt_in_i,
            data_volt_out_o	=> data_volt_out_o,
            hs_o			=> hs_o,
            vs_o			=> vs_o,
            red_o			=> red_o,
            grn_o			=> grn_o,
            blu_o			=> blu_o
        );

end Voltimetro_toplevel_arq;
