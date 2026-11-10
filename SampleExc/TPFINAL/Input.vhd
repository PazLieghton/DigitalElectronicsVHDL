entity mainsig is
    port (
        clk    : in bit;
        rst    : in bit;
        clk_25 : out bit
    );
end mainsig;

architecture mainsig_arq of mainsig is
    -- 1. Declare the teacher's FFD component
    component ffd is
        port(
            clk : in bit;
            rst : in bit;
            d   : in bit;
            q   : out bit
        );
    end component;

    -- 2. Internal signals for the feedback loop
    signal q_int : bit := '0'; 
    signal d_int : bit;
    
begin
    -- . The core logic: D = NOT Q
    d_it <= not q_int;

    -- 4. Instantiate the FFD
    ffd_inst: ffd
        port map(
            clk => clk,
            rst => rst,
            d   => d_int,
            q   => q_int
        );

    -- 5. Output the 25MHz clock
    clk_25 <= q_int;
end mainsig_arq;