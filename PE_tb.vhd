library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MAC_tb is
end MAC_tb;

architecture Behavioral of MAC_tb is
    constant BIT_WIDTH : integer := 3;
    constant ACC_WIDTH : integer := 6;

    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0';
    signal control  : std_logic := '0';
    signal acc_in   : std_logic_vector(ACC_WIDTH - 1 downto 0) := (others => '0');
    signal data_in  : std_logic_vector(BIT_WIDTH - 1 downto 0) := (others => '0');
    signal wt_in    : std_logic_vector(BIT_WIDTH - 1 downto 0) := (others => '0');
    signal acc_out  : std_logic_vector(ACC_WIDTH - 1 downto 0);
    signal data_out : std_logic_vector(BIT_WIDTH - 1 downto 0);

    component MAC is
        generic (
            BIT_WIDTH : integer := 3;
            ACC_WIDTH : integer := 6
        );
        port (
            clk      : in  std_logic;
            control  : in  std_logic;
            reset    : in  std_logic;
            acc_in   : in  std_logic_vector(ACC_WIDTH - 1 downto 0);
            data_in  : in  std_logic_vector(BIT_WIDTH - 1 downto 0);
            wt_in    : in  std_logic_vector(BIT_WIDTH - 1 downto 0);
            acc_out  : out std_logic_vector(ACC_WIDTH - 1 downto 0);
            data_out : out std_logic_vector(BIT_WIDTH - 1 downto 0)
        );
    end component;

begin
    -- Instantiate MAC
    DUT: MAC
        generic map (
            BIT_WIDTH => BIT_WIDTH,
            ACC_WIDTH => ACC_WIDTH
        )
        port map (
            clk      => clk,
            control  => control,
            reset    => reset,
            acc_in   => acc_in,
            data_in  => data_in,
            wt_in    => wt_in,
            acc_out  => acc_out,
            data_out => data_out
        );

    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        -- Test MAC operation
        data_in <= "011";  -- 3 in binary
        wt_in <= "010";    -- 2 in binary
        acc_in <= "000001"; -- 1 in binary
        wait for 20 ns;

        -- Next cycle inputs
        data_in <= "100";  -- 4 in binary
        wt_in <= "011";    -- 3 in binary
        acc_in <= acc_out;
        wait for 20 ns;
        -- Expect acc_out = 7 + (4 * 3) = 19

        -- Another cycle inputs
        data_in <= "010";  -- 2 in binary
        wt_in <= "001";    -- 1 in binary
        acc_in <= acc_out;
        wait for 20 ns;
        -- Expect acc_out = 19 + (2 * 1) = 21

        wait for 20 ns;

        -- End simulation
        wait;
    end process;

end Behavioral;
