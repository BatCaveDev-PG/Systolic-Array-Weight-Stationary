library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SystolicArray_tb is
end SystolicArray_tb;

architecture Behavioral of SystolicArray_tb is
    -- Constants for testbench
    constant ROWS : integer := 4;
    constant COLS : integer := 4;
    constant BIT_WIDTH : integer := 3;
    constant ACC_WIDTH : integer := 6;

    -- Signals to drive the DUT
    signal clk      : std_logic := '0';
    signal control  : std_logic := '0';
    signal reset    : std_logic := '0';
    signal data_arr : std_logic_vector((BIT_WIDTH * ROWS) - 1 downto 0) := (others => '0');
    signal wt_arr   : std_logic_vector((BIT_WIDTH * ROWS * COLS) - 1 downto 0) := (others => '0');
    signal acc_out  : std_logic_vector((ACC_WIDTH * COLS) - 1 downto 0);

    -- Component under test
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

    -- Internal signal for monitoring
    signal wt_stationary : std_logic_vector((BIT_WIDTH * ROWS * COLS) - 1 downto 0);
    
begin
    -- Instantiate DUT
    DUT: SystolicArray
        generic map (
            ROWS => ROWS,
            COLS => COLS,
            BIT_WIDTH => BIT_WIDTH,
            ACC_WIDTH => ACC_WIDTH
        )
        port map (
            clk      => clk,
            control  => control,
            reset    => reset,
            data_arr => data_arr,
            wt_arr   => wt_arr,
            acc_out  => acc_out
        );

    -- Clock generation
    clk_process: process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- Test Process
    stim_proc: process
    begin
        -- Step 1: Assert reset
        reset <= '1';  -- Assert reset
        wait for 20 ns;  -- Hold reset for a clock cycle
        reset <= '0';  -- Deassert reset
    
        -- Step 2: Load weights (wt_arr)
        control <= '1';  -- Enable control signal for weight loading
        -- wt_arr <= "000000001010011000111001010101110101011111111111";  -- 48 bits for 4x4 array
        wt_arr <= "100000001111101110010011000111101001011100110010";
        wait for 20 ns;  -- Hold control signal for enough time
        control <= '0';  -- Disable control signal
    
        -- Step 3: Send input data (data_arr)
        -- For example, sending 12 bits for ROWS = 4, BIT_WIDTH = 3
        -- data_arr <= "001011001010"; -- All rows: 2, 1, 3, 1
        data_arr <= "111010001011"; -- Data_arr Row_0: 3, 1, 2, 7
        wait for 160 ns; -- Allow full propagation through the systolic array       
    
        -- Step 4: Observe results and hold for a while
        wait for 100 ns;
    
        -- End simulation
        wait;
    end process;
    
    
end Behavioral;
