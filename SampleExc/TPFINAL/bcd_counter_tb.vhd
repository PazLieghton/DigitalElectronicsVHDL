
--vsim work.mainsig_tb
--add wave *
--run 1us
--wave zoom ful
entity bcd_counter_tb is
end bcd_counter_tb;

architecture tb_arq of bcd_counter_tb is
    component bcd_counter is
        port (
            clk    : in bit;
            rst    : in bit;
            ena    : in bit;
            q_out  : out bit_vector(3 downto 0)
        );
    end component;

    signal clk_tb   : bit := '0';
    signal rst_tb   : bit := '1';
    signal ena_tb   : bit := '1';
    signal q_out_tb : bit_vector(3 downto 0);

begin
    -- 20 ns clock (50 MHz)
    clk_tb <= not clk_tb after 10 ns;
    rst_tb <= '0' after 25 ns; -- Release reset

    DUT: bcd_counter
        port map(
            clk   => clk_tb,
            rst   => rst_tb,
            ena   => ena_tb,
            q_out => q_out_tb
        );
end tb_arq;