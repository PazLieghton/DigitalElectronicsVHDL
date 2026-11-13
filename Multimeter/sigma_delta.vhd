-- El biestable muestrea el nivel lógico del pin conectado a la red RC.
entity sigma_delta is
    port (
        clk           : in bit;
        rst           : in bit;
        data_volt_in  : in bit;
        data_volt_out : out bit
    );
end sigma_delta;

architecture structural of sigma_delta is
    component ffd is
        port(
            clk : in bit;
            rst : in bit;
            d   : in bit;
            q   : out bit
        );
    end component;
begin
    ffd_inst: ffd
        port map(
            clk => clk,
            rst => rst,
            d   => data_volt_in,
            q   => data_volt_out
        );
end structural;
