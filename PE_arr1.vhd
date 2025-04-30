library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SystolicArray is
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
end SystolicArray;

architecture Behavioral of SystolicArray is
    -- Signal declarations
    type data_array is array (0 to ROWS - 1, 0 to COLS - 1) of std_logic_vector(BIT_WIDTH - 1 downto 0);
    type accumulator_array is array (0 to ROWS - 1, 0 to COLS - 1) of std_logic_vector(ACC_WIDTH - 1 downto 0);

    signal data_out : data_array := (others => (others => (others => '0')));
    signal acc_temp : accumulator_array := (others => (others => (others => '0')));
    signal wt_stationary : data_array := (others => (others => (others => '0')));
    signal acc_in_signal : accumulator_array := (others => (others => (others => '0')));
    signal data_in_signal : data_array := (others => (others => (others => '0')));   


begin
    -- Load weights dynamically
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                wt_stationary <= (others => (others => (others => '0')));
            elsif control = '1' then
                -- Load weights into wt_stationary array
                for i in 0 to ROWS - 1 loop
                    for j in 0 to COLS - 1 loop
                        wt_stationary(i, j) <= wt_arr(((i * COLS + j + 1) * BIT_WIDTH) - 1 downto (i * COLS + j) * BIT_WIDTH);
                    end loop;
                end loop;
            end if;
        end if;
    end process;

    -- Dynamically instantiate MACs
    gen_rows: for i in 0 to ROWS - 1 generate
        gen_cols: for j in 0 to COLS - 1 generate
            -- 1. Special case: MAC_00 (top-left block, i = 0 and j = 0)
            mac_00: if (i = 0 and j = 0) generate
                acc_in_signal(i, j) <= (others => '0'); -- No accumulation for MAC_00
                data_in_signal(i, j) <= data_arr((i + 1) * BIT_WIDTH - 1 downto i * BIT_WIDTH); -- From data_arr

                -- Instantiate MAC_00
                mac_00: entity work.MAC
                    generic map (
                        BIT_WIDTH => BIT_WIDTH,
                        ACC_WIDTH => ACC_WIDTH
                    )
                    port map (
                        clk      => clk,
                        control  => control,
                        reset    => reset,
                        acc_in   => acc_in_signal(i, j),
                        data_in  => data_in_signal(i, j),
                        wt_in    => wt_stationary(i, j),
                        acc_out  => acc_temp(i, j),
                        data_out => data_out(i, j)
                    );
            end generate mac_00;

            -- 2. Column 0 (excluding MAC_00): i > 0, j = 0
            mac_i0: if (i > 0 and j = 0) generate
                acc_in_signal(i, j) <= acc_temp(i - 1, j); -- Accumulation from above
                data_in_signal(i, j) <= data_arr((i + 1) * BIT_WIDTH - 1 downto i * BIT_WIDTH); -- From data_arr

                -- Instantiate MAC for column 0
                mac_col0: entity work.MAC
                    generic map (
                        BIT_WIDTH => BIT_WIDTH,
                        ACC_WIDTH => ACC_WIDTH
                    )
                    port map (
                        clk      => clk,
                        control  => control,
                        reset    => reset,
                        acc_in   => acc_in_signal(i, j),
                        data_in  => data_in_signal(i, j),
                        wt_in    => wt_stationary(i, j),
                        acc_out  => acc_temp(i, j),
                        data_out => data_out(i, j)
                    );
            end generate mac_i0;

            -- 3. Row 0 (excluding MAC_00): i = 0, j > 0
            mac_0j: if (i = 0 and j > 0) generate
                acc_in_signal(i, j) <= (others => '0'); -- No accumulation for first row
                data_in_signal(i, j) <= data_out(i, j - 1); -- Data flows from the left

                -- Instantiate MAC for row 0
                mac_row0: entity work.MAC
                    generic map (
                        BIT_WIDTH => BIT_WIDTH,
                        ACC_WIDTH => ACC_WIDTH
                    )
                    port map (
                        clk      => clk,
                        control  => control,
                        reset    => reset,
                        acc_in   => acc_in_signal(i, j),
                        data_in  => data_in_signal(i, j),
                        wt_in    => wt_stationary(i, j),
                        acc_out  => acc_temp(temp_acc_outi, j),
                        data_out => data_out(i, j)
                    );
            end generate mac_0j;

            -- 4. All other blocks: i > 0, j > 0
            mac_ij: if (i > 0 and j > 0) generate
                acc_in_signal(i, j) <= acc_temp(i - 1, j); -- Accumulation from above
                data_in_signal(i, j) <= data_out(i, j - 1); -- Data flows from the left

                -- Instantiate MAC for all other blocks
                mac_other: entity work.MAC
                    generic map (
                        BIT_WIDTH => BIT_WIDTH,
                        ACC_WIDTH => ACC_WIDTH
                    )
                    port map (
                        clk      => clk,
                        control  => control,
                        reset    => reset,
                        acc_in   => acc_in_signal(i, j),
                        data_in  => data_in_signal(i, j),
                        wt_in    => wt_stationary(i, j),
                        acc_out  => acc_temp(i, j),
                        data_out => data_out(i, j)
                    );
            end generate mac_ij;
        end generate gen_cols;
    end generate gen_rows;


    -- Dynamically collect final outputs from the last row
    process(clk)
        variable temp_acc_out : std_logic_vector((ACC_WIDTH * COLS) - 1 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                acc_out <= (others => '0');
            else
                -- Dynamically concatenate outputs from the last row
                temp_acc_out := (others => '0'); -- Initialize variable
                for j in 0 to COLS - 1 loop
                    temp_acc_out(((j + 1) * ACC_WIDTH) - 1 downto j * ACC_WIDTH) := acc_temp(ROWS - 1, j);
                end loop;
                acc_out <= temp_acc_out;
            end if;
        end if;
    end process;

end Behavioral;
