entity counter_4bit is
    port (
        clk_i : in bit;
        rst_i : in bit;
        ena_i : in bit;
        q_o   : out bit_vector(3 downto 0)
    );
end counter_4bit;

architecture structural of counter_4bit is
    signal q_int : bit_vector(3 downto 0);
    signal d_int : bit_vector(3 downto 0);
    signal t_int : bit_vector(3 downto 0);
begin
    -- Toggle conditions (T-inputs) for each flip-flop
    t_int(0) <= ena_i;
    t_int(1) <= q_int(0) and ena_i;
    t_int(2) <= q_int(1) and q_int(0) and ena_i;
    t_int(3) <= q_int(2) and q_int(1) and q_int(0) and ena_i;

    -- D-inputs for T-flip-flop behavior: D = Q XOR T
    d_int(0) <= q_int(0) xor t_int(0);
    d_int(1) <= q_int(1) xor t_int(1);
    d_int(2) <= q_int(2) xor t_int(2);
    d_int(3) <= q_int(3) xor t_int(3);

    -- Instantiate the FFD component (as defined in your top-level)
    ffd0: entity work.ffd port map (clk_i => clk_i, rst_i => rst_i, ena_i => '1', d_i => d_int(0), q_o => q_int(0));
    ffd1: entity work.ffd port map (clk_i => clk_i, rst_i => rst_i, ena_i => '1', d_i => d_int(1), q_o => q_int(1));
    ffd2: entity work.ffd port map (clk_i => clk_i, rst_i => rst_i, ena_i => '1', d_i => d_int(2), q_o => q_int(2));
    ffd3: entity work.ffd port map (clk_i => clk_i, rst_i => rst_i, ena_i => '1', d_i => d_int(3), q_o => q_int(3));

    q_o <= q_int;
end structural;