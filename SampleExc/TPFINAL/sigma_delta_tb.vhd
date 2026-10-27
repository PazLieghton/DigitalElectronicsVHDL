entity sigma_delta_tb is
end sigma_delta_tb;

architecture tb_arq of sigma_delta_tb is
    component sigma_delta is
        port (
            clk           : in bit;
            rst           : in bit;
            data_volt_in  : in bit;
            data_volt_out : out bit
        );
    end component;

    signal clk_tb           : bit := '0';
    signal rst_tb           : bit := '1';
    signal data_volt_in_tb  : bit := '0';
    signal data_volt_out_tb : bit;

begin
    -- 25 MHz clock (Period = 40 ns)
    clk_tb <= not clk_tb after 20 ns;
    rst_tb <= '0' after 35 ns;

    -- Simulating an analog voltage (50% duty cycle)
    -- We toggle the input every 100 ns to simulate a mid-range voltage
    data_volt_in_tb <= not data_volt_in_tb after 100 ns;

    DUT: sigma_delta
        port map(
            clk           => clk_tb,
            rst           => rst_tb,
            data_volt_in  => data_volt_in_tb,
            data_volt_out => data_volt_out_tb
        );
end tb_arq;