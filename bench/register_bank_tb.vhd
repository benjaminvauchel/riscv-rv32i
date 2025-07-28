-------------------------------------------------------------------------------
-- Title      : Register Bank Testbench with Automatic Verification
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : register_bank_tb.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description:  Testbench for the register bank component of the RISC-V
--               processor with automatic verification and reporting.
-------------------------------------------------------------------------------
-- Copyright (c) 2025 Benjamin VAUCHEL
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2025-07-25  1.0		vauchel	Created
-- 2025-07-26  1.1		vauchel	Added automatic verification
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.rv32i_pack.all;

entity register_bank_tb is
end entity;

architecture behavior of register_bank_tb is

    -- Component under test
    component register_bank is
        port (
            clk_i       : in  std_logic;
            we_i        : in  std_logic;
            rst_i       : in  std_logic;
            rd_data_i   : in  std_logic_vector(31 downto 0);
            rd_add_i    : in  std_logic_vector(4 downto 0);
            rs1_data_o  : out std_logic_vector(31 downto 0);
            rs1_add_i   : in  std_logic_vector(4 downto 0);
            rs2_data_o  : out std_logic_vector(31 downto 0);
            rs2_add_i   : in  std_logic_vector(4 downto 0)
        );
    end component;

    -- Signals
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';
    signal we        : std_logic := '0';
    signal rd_data   : std_logic_vector(31 downto 0) := (others => '0');
    signal rd_add    : std_logic_vector(4 downto 0) := (others => '0');
    signal rs1_add   : std_logic_vector(4 downto 0) := (others => '0');
    signal rs2_add   : std_logic_vector(4 downto 0) := (others => '0');
    signal rs1_data  : std_logic_vector(31 downto 0);
    signal rs2_data  : std_logic_vector(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;
    
    -- Test tracking variables
    signal test_counter : integer := 0;
    signal errors_count : integer := 0;

    -- Verification procedure
    procedure check_value(
        signal actual   : in std_logic_vector(31 downto 0);
        expected        : in std_logic_vector(31 downto 0);
        test_name       : in string;
        signal counter  : inout integer;
        signal errors   : inout integer
    ) is
    begin
        counter <= counter + 1;
        if actual = expected then
            report "TEST " & integer'image(counter + 1) & " PASSED: " & test_name & " - Expected: 0x" & 
                   to_hstring(expected) & ", Got: 0x" & to_hstring(actual) severity note;
        else
            report "TEST " & integer'image(counter + 1) & " FAILED: " & test_name & " - Expected: 0x" & 
                   to_hstring(expected) & ", Got: 0x" & to_hstring(actual) severity error;
            errors <= errors + 1;
        end if;
    end procedure;

begin

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- DUT instantiation
    DUT: register_bank
        port map (
            clk_i      => clk,
            we_i       => we,
            rst_i      => rst,
            rd_data_i  => rd_data,
            rd_add_i   => rd_add,
            rs1_add_i  => rs1_add,
            rs2_add_i  => rs2_add,
            rs1_data_o => rs1_data,
            rs2_data_o => rs2_data
        );

    -- Stimuli and verification
    stim_proc: process
    begin
        report "=== REGISTER BANK TESTBENCH STARTED ===" severity note;
        
        -- Reset test
        report "--- Test Phase: Reset ---" severity note;
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;
        
        -- Initially, all registers should read as 0 (including register 0)
        rs1_add <= std_logic_vector(to_unsigned(0, 5));
        rs2_add <= std_logic_vector(to_unsigned(1, 5));
        wait for CLK_PERIOD;
        check_value(rs1_data, x"00000000", "Register 0 after reset", test_counter, errors_count);
        check_value(rs2_data, x"00000000", "Register 1 after reset", test_counter, errors_count);

        -- Test 1: Write and read from register 5
        report "--- Test Phase: Write/Read Register 5 ---" severity note;
        we      <= '1';
        rd_add  <= std_logic_vector(to_unsigned(5, 5));
        rd_data <= x"AAAABBBB";
        wait for CLK_PERIOD;
        we <= '0';
        wait for CLK_PERIOD;

        -- Read from register 5 into rs1
        rs1_add <= std_logic_vector(to_unsigned(5, 5));
        wait for CLK_PERIOD;
        check_value(rs1_data, x"AAAABBBB", "Read from register 5", test_counter, errors_count);

        -- Test 2: Write and read from register 10
        report "--- Test Phase: Write/Read Register 10 ---" severity note;
        we      <= '1';
        rd_add  <= std_logic_vector(to_unsigned(10, 5));
        rd_data <= x"12345678";
        wait for CLK_PERIOD;
        we <= '0';
        wait for CLK_PERIOD;

        -- Read from reg 10 into rs2
        rs2_add <= std_logic_vector(to_unsigned(10, 5));
        wait for CLK_PERIOD;
        check_value(rs2_data, x"12345678", "Read from register 10", test_counter, errors_count);

        -- Test 3: Verify register 5 still contains original data (persistence test)
        report "--- Test Phase: Data Persistence ---" severity note;
        rs1_add <= std_logic_vector(to_unsigned(5, 5));
        wait for CLK_PERIOD;
        check_value(rs1_data, x"AAAABBBB", "Register 5 data persistence", test_counter, errors_count);

        -- Test 4: Try writing to register 0 (should stay 0 - RISC-V requirement)
        report "--- Test Phase: Register 0 Write Protection ---" severity note;
        we      <= '1';
        rd_add  <= std_logic_vector(to_unsigned(0, 5));
        rd_data <= x"DEADBEEF";
        wait for CLK_PERIOD;
        we <= '0';
        wait for CLK_PERIOD;

        rs1_add <= std_logic_vector(to_unsigned(0, 5));
        wait for CLK_PERIOD;
        check_value(rs1_data, x"00000000", "Register 0 write protection", test_counter, errors_count);

        -- Test 5: Simultaneous read from two different registers
        report "--- Test Phase: Simultaneous Dual Read ---" severity note;
        rs1_add <= std_logic_vector(to_unsigned(5, 5));
        rs2_add <= std_logic_vector(to_unsigned(10, 5));
        wait for CLK_PERIOD;
        check_value(rs1_data, x"AAAABBBB", "Simultaneous read rs1 (reg 5)", test_counter, errors_count);
        check_value(rs2_data, x"12345678", "Simultaneous read rs2 (reg 10)", test_counter, errors_count);

        -- Test 6: Write to register while reading from others
        report "--- Test Phase: Write During Read ---" severity note;
        we      <= '1';
        rd_add  <= std_logic_vector(to_unsigned(15, 5));
        rd_data <= x"CAFEBABE";
        rs1_add <= std_logic_vector(to_unsigned(5, 5));
        rs2_add <= std_logic_vector(to_unsigned(10, 5));
        wait for CLK_PERIOD;
        we <= '0';
        
        -- Verify reads are not affected by concurrent write
        check_value(rs1_data, x"AAAABBBB", "Read reg 5 during write to reg 15", test_counter, errors_count);
        check_value(rs2_data, x"12345678", "Read reg 10 during write to reg 15", test_counter, errors_count);
        
        -- Verify the write took effect
        rs1_add <= std_logic_vector(to_unsigned(15, 5));
        wait for CLK_PERIOD;
        check_value(rs1_data, x"CAFEBABE", "Verify write to register 15", test_counter, errors_count);

        -- Test 7: Edge case - read from unwritten register
        report "--- Test Phase: Unwritten Register Read ---" severity note;
        rs2_add <= std_logic_vector(to_unsigned(31, 5)); -- Last register
        wait for CLK_PERIOD;
        check_value(rs2_data, x"00000000", "Read from unwritten register 31", test_counter, errors_count);

        -- Final results
        wait for 20 ns;
        report "=== TESTBENCH SUMMARY ===" severity note;
        report "Total tests run: " & integer'image(test_counter) severity note;
        if errors_count = 0 then
            report "ALL TESTS PASSED! Register bank is working correctly." severity note;
        else
            report "TESTS FAILED: " & integer'image(errors_count) & " out of " & 
                   integer'image(test_counter) & " tests failed." severity error;
        end if;
        report "=== REGISTER BANK TESTBENCH COMPLETED ===" severity note;
        
        wait;
    end process;

end architecture;