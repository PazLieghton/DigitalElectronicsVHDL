-- Testbench de Input
--BEGIN TESTBENCH CLOCK / Corrobore que funciona :D--

entity mainsig_tb is
end mainsig_tb;

architecture mainsig_tb_arq of mainsig_tb is
    --Testbench declaracion para probar mainsig de input
    component mainsig is
        port (
            clk    : in bit;
            rst    : in bit;
            clk_25 : out bit
        );
    end component;

    -- Signlas
    signal clk_tb    : bit := '0';
    signal rst_tb    : bit := '1';
    signal clk_25_tb : bit; -- Fixed: Este es fijo

begin
	--Genero una senial de 50 MHz y tiene un retardo de 10ns
    clk_tb <= not clk_tb after 10 ns;
    
    -- Genero la senial reset
    rst_tb <= '0' after 35 ns;

    -- Inicializo el TB
    DUT: mainsig
        port map(
            clk    => clk_tb,
            rst    => rst_tb,
            clk_25 => clk_25_tb
        );
        
end mainsig_tb_arq;