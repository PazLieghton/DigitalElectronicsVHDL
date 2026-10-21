
--vsim work.mainsig_tb
--add wave *
--run 1us
--wave zoom ful ACORDATE PARA SIMULAR

entity bcd_counter is
    port (
        clk    : in bit;
        rst    : in bit;
        ena    : in bit;
        q_out  : out bit_vector(3 downto 0)
    );
end bcd_counter;

architecture structural of bcd_counter is
    -- Declare the teacher's FFD
    component ffd is
        port(
            clk : in bit;
            rst : in bit;
            d   : in bit;
            q   : out bit
        );
    end component;

    signal q_int : bit_vector(3 downto 0);
    signal d_int : bit_vector(3 downto 0);
    signal t_int : bit_vector(3 downto 0);
    signal rst_int : bit; -- Internal reset for the Mod-10 wrap-around

begin
    -- 1. The Wrap-Around Logic (Mod-10)
    -- When the counter reaches 9 (Q3='1' and Q0='1'), we trigger the reset.
    rst_int <= rst or (q_int(3) and q_int(0));

    -- 2. Toggle conditions (T-inputs for T-Flip-Flops)
    t_int(0) <= ena;
    t_int(1) <= q_int(0) and ena;
    t_int(2) <= q_int(1) and q_int(0) and ena;
    t_int(3) <= q_int(2) and q_int(1) and q_int(0) and ena;

    -- 3. D-inputs: D = Q XOR T
    d_int(0) <= q_int(0) xor t_int(0);
    d_int(1) <= q_int(1) xor t_int(1);
    d_int(2) <= q_int(2) xor t_int(2);
    d_int(3) <= q_int(3) xor t_int(3);

    -- 4. Instantiate the 4 Flip-Flops
    ffd0: ffd port map(clk => clk, rst => rst_int, d => d_int(0), q => q_int(0));
    ffd1: ffd port map(clk => clk, rst => rst_int, d => d_int(1), q => q_int(1));
    ffd2: ffd port map(clk => clk, rst => rst_int, d => d_int(2), q => q_int(2));
    ffd3: ffd port map(clk => clk, rst => rst_int, d => d_int(3), q => q_int(3));

    -- 5. Output assignment
    q_out <= q_int;

end structural;