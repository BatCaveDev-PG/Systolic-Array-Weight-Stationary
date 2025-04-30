library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MAC is
    generic (
        BIT_WIDTH : integer := 3;  -- Width of input data and weight
        ACC_WIDTH : integer := 6   -- Width of accumulator
    );
    port (
        clk      : in  std_logic;                             -- Clock signal
        control  : in  std_logic;                             -- Control signal (e.g., for weight loading)
        reset    : in  std_logic;                             -- Reset signal
        acc_in   : in  std_logic_vector(ACC_WIDTH - 1 downto 0); -- Input from previous accumulator
        data_in  : in  std_logic_vector(BIT_WIDTH - 1 downto 0); -- Input data
        wt_in    : in  std_logic_vector(BIT_WIDTH - 1 downto 0); -- Input weight
        acc_out  : out std_logic_vector(ACC_WIDTH - 1 downto 0); -- Accumulated output
        data_out : out std_logic_vector(BIT_WIDTH - 1 downto 0)  -- Propagated data output
    );
end MAC;

architecture Behavioral of MAC is
    -- Internal signals for calculations
    signal acc_reg : std_logic_vector(ACC_WIDTH - 1 downto 0) := (others => '0');
    signal mult_result : std_logic_vector(ACC_WIDTH - 1 downto 0);
    signal data_reg : std_logic_vector(BIT_WIDTH - 1 downto 0) := (others => '0');
begin
    -- Multiplication logic
    mult_result <= std_logic_vector(resize(unsigned(data_in) * unsigned(wt_in), ACC_WIDTH));

    -- Sequential process for accumulation and propagation
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Reset all outputs and internal registers
                acc_reg <= (others => '0');
                data_reg <= (others => '0');
            elsif control = '0' then
                -- Perform MAC operation
                acc_reg <= std_logic_vector(unsigned(acc_in) + unsigned(mult_result));
                data_reg <= data_in; -- Propagate data to the next MAC
            end if;
        end if;
    end process;

    -- Assign outputs
    acc_out <= acc_reg; -- Accumulated result
    data_out <= data_reg; -- Propagated data
end Behavioral;
