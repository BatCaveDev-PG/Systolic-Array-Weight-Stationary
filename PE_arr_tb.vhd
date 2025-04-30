library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SystolicArray_tb is
end SystolicArray_tb;

architecture Behavioral of SystolicArray_tb is
    -- Component declaration
    component SystolicArray
        generic (
            ROWS : integer := 4;
            COLS : integer := 4;
            BIT_WIDTH : integer := 3;
            ACC_WIDTH : integer := 6
        );
        port (
            clk      : in  std_logic;
            control  : in  std_logic;
            reset    : in  std_logic;
            data_arr : in  std_logic_vector((BIT_WIDTH * ROWS) - 1 downto 0);
            wt_arr   : in  std_logic_vector((BIT_WIDTH * ROWS * COLS) - 1 downto 0);
            acc_out  : out std_logic_vector((ACC_WIDTH * COLS) - 1 downto 0)
        );
    end component;

    -- Testbench signals
    signal clk      : std_logic := '0';
    signal control  : std_logic := '0';
    signal reset    : std_logic := '0';
    signal data_arr : std_logic_vector((3 * 4) - 1 downto 0) := (others => '0'); -- 4x3-bit inputs
    signal wt_arr   : std_logic_vector((3 * 4 * 4) - 1 downto 0) := (others => '0'); -- 48-bit inputs
    signal acc_out  : std_logic_vector((6 * 4) - 1 downto 0); -- 4x10-bit outputs

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Instantiate the SystolicArray
    DUT: SystolicArray
        generic map (
            ROWS => 4,
            COLS => 4,
            BIT_WIDTH => 3,
            ACC_WIDTH => 6
        )
        port map (
            clk      => clk,
            control  => control,
            reset    => reset,
            data_arr => data_arr,
            wt_arr   => wt_arr,
            acc_out  => acc_out
        );

    -- Clock generation process
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Test process
    test_process : process
    begin
        -- Step 1: Apply reset
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';

        -- Step 2: Load weight matrix
        control <= '1'; -- Set control high to load weights
        wt_arr <= "010" & "110" & "100" & "011" & -- Row 0 (W00, W01, W02, W03)
                "001" & "101" & "111" & "000" & -- Row 1 (W10, W11, W12, W13)
                "011" & "010" & "110" & "101" & -- Row 2 (W20, W21, W22, W23)
                "111" & "001" & "000" & "100";  -- Row 3 (W30, W31, W32, W33)
        wait for CLK_PERIOD;
        control <= '0'; -- Deactivate weight loading

        -- Step 3: Load data inputs sequentially
        data_arr <= "000000000011"; -- t1: 3 for a00
        wait for 4 * CLK_PERIOD;


       -- Step 4: Observe acc_out
        wait for 10 * CLK_PERIOD;

        -- End simulation
        wait;
    end process;

end Behavioral;
