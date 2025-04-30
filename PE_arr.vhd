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


    -- Include the utility function
    function std_logic_vector_to_string(input: std_logic_vector) return string is
        variable result : string(1 to input'length);
        variable idx    : integer; -- Temporary variable for correct indexing
    begin
        idx := input'length; -- Start from the highest index of the input
        for i in input'range loop
            if input(i) = '1' then
                result(idx) := '1';
            elsif input(i) = '0' then
                result(idx) := '0';
            else
                result(idx) := 'U'; -- Undefined value
            end if;
            idx := idx - 1; -- Move to the next position in the string
        end loop;
        return result;
    end function;

    -- Declare signals for interconnections between MACs
    type data_array is array (0 to ROWS - 1, 0 to COLS - 1) of std_logic_vector(BIT_WIDTH - 1 downto 0);
    type accumulator_array is array (0 to ROWS - 1, 0 to COLS - 1) of std_logic_vector(ACC_WIDTH - 1 downto 0);

    signal data_out : data_array := (others => (others => (others => '0')));
    signal acc_temp : accumulator_array := (others => (others => (others => '0')));

    -- Stationary weights: Each MAC will hold its weight internally
    signal wt_stationary : data_array := (others => (others => (others => '0')));

begin

    -- **Weight Loading Phase**: Load weights when `control = 1`
    process(clk)
        variable wt_row_0 : std_logic_vector((4 * BIT_WIDTH) - 1 downto 0); -- Variable to hold Row 0 weights
        variable wt_row_1 : std_logic_vector((4 * BIT_WIDTH) - 1 downto 0); -- Variable to hold Row 0 weights
        variable wt_row_2 : std_logic_vector((4 * BIT_WIDTH) - 1 downto 0); -- Variable to hold Row 0 weights
        variable wt_row_3 : std_logic_vector((4 * BIT_WIDTH) - 1 downto 0); -- Variable to hold Row 0 weights


    begin
        if rising_edge(clk) then
            if reset = '1' then
                wt_stationary <= (others => (others => (others => '0')));
            elsif control = '1' then
                -- Load weights from wt_arr into stationary signals
                wt_stationary(0, 0) <= wt_arr(2 downto 0);
                wt_stationary(0, 1) <= wt_arr(5 downto 3);
                wt_stationary(0, 2) <= wt_arr(8 downto 6);
                wt_stationary(0, 3) <= wt_arr(11 downto 9);
                wt_stationary(1, 0) <= wt_arr(14 downto 12);
                wt_stationary(1, 1) <= wt_arr(17 downto 15);
                wt_stationary(1, 2) <= wt_arr(20 downto 18);
                wt_stationary(1, 3) <= wt_arr(23 downto 21);
                wt_stationary(2, 0) <= wt_arr(26 downto 24);
                wt_stationary(2, 1) <= wt_arr(29 downto 27);
                wt_stationary(2, 2) <= wt_arr(32 downto 30);
                wt_stationary(2, 3) <= wt_arr(35 downto 33);
                wt_stationary(3, 0) <= wt_arr(38 downto 36);
                wt_stationary(3, 1) <= wt_arr(41 downto 39);
                wt_stationary(3, 2) <= wt_arr(44 downto 42);
                wt_stationary(3, 3) <= wt_arr(47 downto 45);


                -- Assign to variable for immediate reporting
                wt_row_0 := wt_arr(11 downto 0); -- Extract weights for Row 0 (entire slice)
                wt_row_1 := wt_arr(23 downto 12); -- Extract weights for Row 1 (entire slice)
                wt_row_2 := wt_arr(35 downto 24); -- Extract weights for Row 2 (entire slice)
                wt_row_3 := wt_arr(47 downto 36); -- Extract weights for Row 3 (entire slice)


                --- report "row0 weights"
                report "Row 0 weights: " &
                std_logic_vector_to_string(wt_row_0(2 downto 0)) & ", " &
                std_logic_vector_to_string(wt_row_0(5 downto 3)) & ", " &
                std_logic_vector_to_string(wt_row_0(8 downto 6)) & ", " &
                std_logic_vector_to_string(wt_row_0(11 downto 9));
                --- report "row1 weights"
                report "Row 1 weights: " &
                std_logic_vector_to_string(wt_row_1(2 downto 0)) & ", " &
                std_logic_vector_to_string(wt_row_1(5 downto 3)) & ", " &
                std_logic_vector_to_string(wt_row_1(8 downto 6)) & ", " &
                std_logic_vector_to_string(wt_row_1(11 downto 9));
                --- report "row2 weights"
                report "Row 2 weights: " &
                std_logic_vector_to_string(wt_row_2(2 downto 0)) & ", " &
                std_logic_vector_to_string(wt_row_2(5 downto 3)) & ", " &
                std_logic_vector_to_string(wt_row_2(8 downto 6)) & ", " &
                std_logic_vector_to_string(wt_row_2(11 downto 9));
                --- report "row3 weights"
                report "Row 3 weights: " &
                std_logic_vector_to_string(wt_row_3(2 downto 0)) & ", " &
                std_logic_vector_to_string(wt_row_3(5 downto 3)) & ", " &
                std_logic_vector_to_string(wt_row_3(8 downto 6)) & ", " &
                std_logic_vector_to_string(wt_row_3(11 downto 9));
                
            end if;
        end if;
    end process;

    -- Hardcoded instantiation of 16 MAC units (weight-stationary)
-- Column 0: 1st Column of the MAC Array
-- Each MAC receives values from a specific row of the `data_in` array.

-- MAC_00: Top-left MAC in the array
MAC_00: entity work.MAC
    generic map (
        BIT_WIDTH => BIT_WIDTH,
        ACC_WIDTH => ACC_WIDTH
    )
    port map (
        clk      => clk,
        control  => control,
        reset    => reset,
        acc_in   => (others => '0'), -- Topmost MAC has no accumulator input
        data_in  => data_arr(BIT_WIDTH - 1 downto 0), -- Row 0 value a00
        wt_in    => wt_stationary(0, 0), -- Stationary weight w00
        acc_out  => acc_temp(0, 0), -- Accumulated output
        data_out => data_out(0, 0)  -- Horizontal data propagation
    );

-- MAC_10: 2nd row of the 1st column
MAC_10: entity work.MAC
    generic map (
        BIT_WIDTH => BIT_WIDTH,
        ACC_WIDTH => ACC_WIDTH
    )
    port map (
        clk      => clk,
        control  => control,
        reset    => reset,
        acc_in   => acc_temp(0, 0), -- Accumulated value from MAC_00
        data_in  => data_arr(2 * BIT_WIDTH - 1 downto BIT_WIDTH), -- Row 1 value a01
        wt_in    => wt_stationary(1, 0), -- Stationary weight w10
        acc_out  => acc_temp(1, 0), -- Accumulated output
        data_out => data_out(1, 0)  -- Horizontal data propagation
    );

-- MAC_20: 3rd row of the 1st column
MAC_20: entity work.MAC
    generic map (
        BIT_WIDTH => BIT_WIDTH,
        ACC_WIDTH => ACC_WIDTH
    )
    port map (
        clk      => clk,
        control  => control,
        reset    => reset,
        acc_in   => acc_temp(1, 0), -- Accumulated value from MAC_10
        data_in  => data_arr(3 * BIT_WIDTH - 1 downto 2 * BIT_WIDTH), -- Row 2 value a02
        wt_in    => wt_stationary(2, 0), -- Stationary weight w20
        acc_out  => acc_temp(2, 0), -- Accumulated output
        data_out => data_out(2, 0)  -- Horizontal data propagation
    );

-- MAC_30: 4th row of the 1st column
MAC_30: entity work.MAC
    generic map (
        BIT_WIDTH => BIT_WIDTH,
        ACC_WIDTH => ACC_WIDTH
    )
    port map (
        clk      => clk,
        control  => control,
        reset    => reset,
        acc_in   => acc_temp(2, 0), -- Accumulated value from MAC_20
        data_in  => data_arr(4 * BIT_WIDTH - 1 downto 3 * BIT_WIDTH), -- Row 3 value a03
        wt_in    => wt_stationary(3, 0), -- Stationary weight w30
        acc_out  => acc_temp(3, 0), -- Accumulated output
        data_out => data_out(3, 0)  -- Horizontal data propagation
    );
    
----- Column 1: 2nd Column of the MAC Array

MAC_01: entity work.MAC
    generic map (
        BIT_WIDTH => BIT_WIDTH,
        ACC_WIDTH => ACC_WIDTH
    )
    port map (
        clk      => clk,
        control  => control,
        reset    => reset,
        acc_in   => (others => '0'), -- Topmost MAC has no accumulator input
        data_in  => data_out(0, 0),        -- Data from MAC_00 (horizontal flow)
        wt_in    => wt_stationary(0, 1),   -- Stationary weight for column 1
        acc_out  => acc_temp(0, 1),
        data_out => data_out(0, 1)
    );

MAC_11: entity work.MAC
    generic map (
        BIT_WIDTH => BIT_WIDTH,
        ACC_WIDTH => ACC_WIDTH
    )
    port map (
        clk      => clk,
        control  => control,
        reset    => reset,
        acc_in   => acc_temp(0, 1),         -- Accumulation from MAC_01 (vertical flow)
        data_in  => data_out(1, 0),        -- Data from MAC_10 (horizontal flow)
        wt_in    => wt_stationary(1, 1),   -- Stationary weight for column 1
        acc_out  => acc_temp(1, 1),
        data_out => data_out(1, 1)
    );

MAC_21: entity work.MAC
    generic map (
        BIT_WIDTH => BIT_WIDTH,
        ACC_WIDTH => ACC_WIDTH
    )
    port map (
        clk      => clk,
        control  => control,
        reset    => reset,
        acc_in   => acc_temp(1, 1),         -- Accumulation from MAC_11 (vertical flow)
        data_in  => data_out(2, 0),        -- Data from MAC_20 (horizontal flow)
        wt_in    => wt_stationary(2, 1),   -- Stationary weight for column 1
        acc_out  => acc_temp(2, 1),
        data_out => data_out(2, 1)
    );

MAC_31: entity work.MAC
    generic map (
        BIT_WIDTH => BIT_WIDTH,
        ACC_WIDTH => ACC_WIDTH
    )
    port map (
        clk      => clk,
        control  => control,
        reset    => reset,
        acc_in   => acc_temp(2, 1),         -- Accumulation from MAC_21 (vertical flow)
        data_in  => data_out(3, 0),        -- Data from MAC_30 (horizontal flow)
        wt_in    => wt_stationary(3, 1),   -- Stationary weight for column 1
        acc_out  => acc_temp(3, 1),
        data_out => data_out(3, 1)
    );

------- Column 02
MAC_02: entity work.MAC
    generic map (
        BIT_WIDTH => BIT_WIDTH,
        ACC_WIDTH => ACC_WIDTH
    )
    port map (
        clk      => clk,
        control  => control,
        reset    => reset,
        acc_in   => (others => '0'), -- First MAC in this column, acc_in = 0
        data_in  => data_out(0, 1), -- Horizontal flow from MAC_01
        wt_in    => wt_stationary(0, 2), -- Stationary weight
        acc_out  => acc_temp(0, 2),
        data_out => data_out(0, 2)
    );

MAC_12: entity work.MAC
    generic map (
        BIT_WIDTH => BIT_WIDTH,
        ACC_WIDTH => ACC_WIDTH
    )
    port map (
        clk      => clk,
        control  => control,
        reset    => reset,
        acc_in   => acc_temp(0, 2), -- Vertical flow from MAC_02
        data_in  => data_out(1, 1), -- Horizontal flow from MAC_11
        wt_in    => wt_stationary(1, 2), -- Stationary weight
        acc_out  => acc_temp(1, 2),
        data_out => data_out(1, 2)
    );

MAC_22: entity work.MAC
    generic map (
        BIT_WIDTH => BIT_WIDTH,
        ACC_WIDTH => ACC_WIDTH
    )
    port map (
        clk      => clk,
        control  => control,
        reset    => reset,
        acc_in   => acc_temp(1, 2), -- Vertical flow from MAC_12
        data_in  => data_out(2, 1), -- Horizontal flow from MAC_21
        wt_in    => wt_stationary(2, 2), -- Stationary weight
        acc_out  => acc_temp(2, 2),
        data_out => data_out(2, 2)
    );

MAC_32: entity work.MAC
    generic map (
        BIT_WIDTH => BIT_WIDTH,
        ACC_WIDTH => ACC_WIDTH
    )
    port map (
        clk      => clk,
        control  => control,
        reset    => reset,
        acc_in   => acc_temp(2, 2), -- Vertical flow from MAC_22
        data_in  => data_out(3, 1), -- Horizontal flow from MAC_31
        wt_in    => wt_stationary(3, 2), -- Stationary weight
        acc_out  => acc_temp(3, 2),
        data_out => data_out(3, 2)
    );

------- Column 3
MAC_03: entity work.MAC
    generic map (
        BIT_WIDTH => BIT_WIDTH,
        ACC_WIDTH => ACC_WIDTH
    )
    port map (
        clk      => clk,
        control  => control,
        reset    => reset,
        acc_in   => (others => '0'), -- First MAC in this column, acc_in = 0
        data_in  => data_out(0, 2), -- Horizontal flow from MAC_02
        wt_in    => wt_stationary(0, 3), -- Stationary weight
        acc_out  => acc_temp(0, 3),
        data_out => data_out(0, 3)
    );

MAC_13: entity work.MAC
    generic map (
        BIT_WIDTH => BIT_WIDTH,
        ACC_WIDTH => ACC_WIDTH
    )
    port map (
        clk      => clk,
        control  => control,
        reset    => reset,
        acc_in   => acc_temp(0, 3), -- Vertical flow from MAC_03
        data_in  => data_out(1, 2), -- Horizontal flow from MAC_12
        wt_in    => wt_stationary(1, 3), -- Stationary weight
        acc_out  => acc_temp(1, 3),
        data_out => data_out(1, 3)
    );

MAC_23: entity work.MAC
    generic map (
        BIT_WIDTH => BIT_WIDTH,
        ACC_WIDTH => ACC_WIDTH
    )
    port map (
        clk      => clk,
        control  => control,
        reset    => reset,
        acc_in   => acc_temp(1, 3), -- Vertical flow from MAC_13
        data_in  => data_out(2, 2), -- Horizontal flow from MAC_22
        wt_in    => wt_stationary(2, 3), -- Stationary weight
        acc_out  => acc_temp(2, 3),
        data_out => data_out(2, 3)
    );

MAC_33: entity work.MAC
    generic map (
        BIT_WIDTH => BIT_WIDTH,
        ACC_WIDTH => ACC_WIDTH
    )
    port map (
        clk      => clk,
        control  => control,
        reset    => reset,
        acc_in   => acc_temp(2, 3), -- Vertical flow from MAC_23
        data_in  => data_out(3, 2), -- Horizontal flow from MAC_32
        wt_in    => wt_stationary(3, 3), -- Stationary weight
        acc_out  => acc_temp(3, 3),
        data_out => data_out(3, 3)
    );

    -- Output accumulation (collect the results from the last row)
    process(clk)
    begin
        if rising_edge(clk) then
            if (reset = '1') then
                acc_out <= (others => '0'); -- Reset the accumulator outputs
                acc_temp <= (others => (others => (others => '0'))); -- Reset acc_temp
            elsif (control = '1') then
                -- When control is 1, weights are loaded, and accumulation is disabled
                acc_out <= (others => '0'); -- Keep outputs zero
                acc_temp <= (others => (others => (others => '0'))); -- Reset acc_temp
            else
                acc_out <= acc_temp(3, 0) & acc_temp(3, 1) & acc_temp(3, 2) & acc_temp(3, 3);

                -- Debug reporting for each MAC's acc_out
                report "At time " & time'image(now) & ":";
                report "  acc_temp(0, 0) = " & std_logic_vector_to_string(acc_temp(0, 0));
                report "  acc_temp(0, 1) = " & std_logic_vector_to_string(acc_temp(0, 1));
                report "  acc_temp(0, 2) = " & std_logic_vector_to_string(acc_temp(0, 2));
                report "  acc_temp(0, 3) = " & std_logic_vector_to_string(acc_temp(0, 3));
                report "  acc_temp(1, 0) = " & std_logic_vector_to_string(acc_temp(1, 0));
                report "  acc_temp(1, 1) = " & std_logic_vector_to_string(acc_temp(1, 1));
                report "  acc_temp(1, 2) = " & std_logic_vector_to_string(acc_temp(1, 2));
                report "  acc_temp(1, 3) = " & std_logic_vector_to_string(acc_temp(1, 3));
                report "  acc_temp(2, 0) = " & std_logic_vector_to_string(acc_temp(2, 0));
                report "  acc_temp(2, 1) = " & std_logic_vector_to_string(acc_temp(2, 1));
                report "  acc_temp(2, 2) = " & std_logic_vector_to_string(acc_temp(2, 2));
                report "  acc_temp(2, 3) = " & std_logic_vector_to_string(acc_temp(2, 3));
                report "  acc_temp(3, 0) = " & std_logic_vector_to_string(acc_temp(3, 0));
                report "  acc_temp(3, 1) = " & std_logic_vector_to_string(acc_temp(3, 1));
                report "  acc_temp(3, 2) = " & std_logic_vector_to_string(acc_temp(3, 2));
                report "  acc_temp(3, 3) = " & std_logic_vector_to_string(acc_temp(3, 3));

            end if;
        end if;
    end process;

end Behavioral;
