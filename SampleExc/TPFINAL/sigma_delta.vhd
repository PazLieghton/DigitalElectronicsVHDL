--vsim sigma_delta_tb
--add wave *
--run 1us
--wave zoom ful ACORDATE PARA SIMULAR


entity sigma_delta is
    port (
        clk           : in bit;
        rst           : in bit;
        data_volt_in  : in bit; -- Analog input from comparator
        data_volt_out : out bit -- PWM feedback to RC filter
    );
end sigma_delta;

architecture structural of sigma_delta is
    -- Declare the teacher's FFD
    component ffd is
        port(
            clk : in bit;
            rst : in bit;
            d   : in bit;
            q   : out bit
        );
    end component;
begin
    -- The modulator is literally just the FFD
    ffd_inst: ffd 
        port map(
            clk => clk,
            rst => rst,
            d   => data_volt_in,
            q   => data_volt_out
        );
end structural;