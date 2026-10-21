library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sync_counter_tb is
end sync_counter_tb;

architecture Behavioral of sync_counter_tb is

    -- Component declaration for the Design Under Test (DUT)
    component sync_counter
        Port ( clk   : in  STD_LOGIC;
               rst   : in  STD_LOGIC;
               count : out STD_LOGIC_VECTOR (3 downto 0));
    end component;

    -- Signals to connect to the DUT
    signal clk   : STD_LOGIC := '0';
    signal rst   : STD_LOGIC := '0';
    signal count : STD_LOGIC_VECTOR (3 downto 0);

    -- Clock period definition (10 ns = 100 MHz)
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Design Under Test (DUT)
    dut: sync_counter
        port map (
            clk   => clk,
            rst   => rst,
            count => count
        );

    -- Clock generation process
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stim_process : process
    begin
        -- Hold reset high initially for 20 ns
        rst <= '1';
        wait for 20 ns;
        
        -- Release reset and let the counter run
        rst <= '0';
        wait for 200 ns;

        -- Apply a reset pulse mid-simulation to test reset functionality
        rst <= '1';
        wait for 15 ns;
        rst <= '0';
        
        -- Continue counting
        wait for 100 ns;
        
        -- End simulation
        wait;
    end process;

end Behavioral;
