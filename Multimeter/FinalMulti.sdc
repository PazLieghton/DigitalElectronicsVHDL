# Oscilador de 50 MHz de la placa EP2C5.
create_clock -name clk_50 -period 20.000 [get_ports {osc_50mhz}]

# El biestable del módulo superior divide por dos el reloj de medición y de vídeo.
create_generated_clock -name clk_25 -source [get_ports {osc_50mhz}] -divide_by 2 \
    [get_registers {Voltimetro_toplevel:nucleo|ffd_en:ffd_i|ffd:base_ff|q}]
