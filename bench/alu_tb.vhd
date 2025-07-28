-------------------------------------------------------------------------------
-- Title      : ALU Testbench
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : alu_tb.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Comprehensive testbench for the RV32I ALU
--              Tests supported operations and edge cases
-------------------------------------------------------------------------------
-- Copyright (c) 2025 Benjamin VAUCHEL
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2025-07-25  1.0		vauchel	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
library work;

entity alu_tb is
end entity alu_tb;

architecture testbench of alu_tb is
    
    component alu is
        port (
            func_i : in  std_logic_vector( 3 downto 0 );
            op1_i  : in  std_logic_vector( 31 downto 0 );
            op2_i  : in  std_logic_vector( 31 downto 0 );
            d_o    : out std_logic_vector( 31 downto 0 );
            lt_o   : out std_logic;
            zero_o : out std_logic
        );
    end component;
    
    -- Test signals
    signal func_i  : std_logic_vector(3 downto 0);
    signal op1_i   : std_logic_vector(31 downto 0);
    signal op2_i   : std_logic_vector(31 downto 0);
    signal d_o     : std_logic_vector(31 downto 0);
    signal lt_o    : std_logic;
    signal zero_o  : std_logic;
    
    -- Clock for timing
    signal clk     : std_logic := '0';
    constant clk_period : time := 10 ns;
    
    signal test_complete : boolean := false;
    
    -- Function codes based on RV32I ALU operations
    constant FUNC_ZERO : std_logic_vector(3 downto 0) := "0000";  -- Always zero
    constant FUNC_ADD  : std_logic_vector(3 downto 0) := "0001";  -- Addition
    constant FUNC_SUB  : std_logic_vector(3 downto 0) := "0010";  -- Subtraction
    constant FUNC_SLL  : std_logic_vector(3 downto 0) := "0011";  -- Logical Left Shift
    constant FUNC_SLR  : std_logic_vector(3 downto 0) := "0100";  -- Logical Right Shift
    constant FUNC_SRA  : std_logic_vector(3 downto 0) := "0101";  -- Arithmetic Right Shift
    constant FUNC_AND  : std_logic_vector(3 downto 0) := "0110";  -- Bitwise AND
    constant FUNC_OR   : std_logic_vector(3 downto 0) := "0111";  -- Bitwise OR
    constant FUNC_XOR  : std_logic_vector(3 downto 0) := "1000";  -- Bitwise XOR
    constant FUNC_SLT  : std_logic_vector(3 downto 0) := "1001";  -- Set Less Than (signed)
    constant FUNC_SLTU : std_logic_vector(3 downto 0) := "1010";  -- Set Less Than Unsigned
    constant FUNC_PASS : std_logic_vector(3 downto 0) := "1011";  -- Pass op1_i through
    
begin

    -- Clock generation
    clk_process: process
    begin
        if not test_complete then
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        else
            wait;
        end if;
    end process;

    -- DUT instantiation
    dut: alu
        port map (
            func_i => func_i,
            op1_i  => op1_i,
            op2_i  => op2_i,
            d_o    => d_o,
            lt_o   => lt_o,
            zero_o => zero_o
        );

    -- Test stimulus process
    test_process: process
        variable test_count : integer := 0;
        variable expected_result : std_logic_vector(31 downto 0);
        variable expected_zero : std_logic;
        variable expected_lt : std_logic;
        
        -- Procedure to run a test case
        procedure run_test(
            constant test_name : in string;
            constant func : in std_logic_vector(3 downto 0);
            constant op1 : in std_logic_vector(31 downto 0);
            constant op2 : in std_logic_vector(31 downto 0);
            constant expected_d : in std_logic_vector(31 downto 0);
            constant expected_z : in std_logic;
            constant expected_l : in std_logic
        ) is
        begin
            test_count := test_count + 1;
            
            -- Apply inputs
            func_i <= func;
            op1_i <= op1;
            op2_i <= op2;
            
            -- Wait for combinational delay
            wait for 2 ns;
            wait until rising_edge(clk);
            wait for 1 ns;
            
            -- Check results
            assert d_o = expected_d
                report "Test " & integer'image(test_count) & " (" & test_name & ") FAILED: " &
                       "Expected d_o = " & to_hstring(expected_d) & 
                       ", Got d_o = " & to_hstring(d_o)
                severity error;
                
            assert zero_o = expected_z
                report "Test " & integer'image(test_count) & " (" & test_name & ") FAILED: " &
                       "Expected zero_o = " & std_logic'image(expected_z) & 
                       ", Got zero_o = " & std_logic'image(zero_o)
                severity error;
                
            assert lt_o = expected_l
                report "Test " & integer'image(test_count) & " (" & test_name & ") FAILED: " &
                       "Expected lt_o = " & std_logic'image(expected_l) & 
                       ", Got lt_o = " & std_logic'image(lt_o)
                severity error;
                
            report "Test " & integer'image(test_count) & " (" & test_name & ") completed";
        end procedure;
        
    begin
        -- Initialize
        func_i <= (others => '0');
        op1_i <= (others => '0');
        op2_i <= (others => '0');
        
        wait for clk_period * 2;
        
        report "Starting ALU testbench...";
        
        -- Test 1: ZERO function
        run_test("ZERO", FUNC_ZERO, x"12345678", x"87654321", x"00000000", '1', '0');
        
        -- Test 2-5: Addition tests
        run_test("ADD_BASIC", FUNC_ADD, x"00000005", x"00000003", x"00000008", '0', '0');
        run_test("ADD_ZERO", FUNC_ADD, x"00000000", x"00000000", x"00000000", '1', '0');
        run_test("ADD_NEGATIVE", FUNC_ADD, x"FFFFFFFF", x"00000001", x"00000000", '1', '0');
        run_test("ADD_OVERFLOW", FUNC_ADD, x"7FFFFFFF", x"00000001", x"80000000", '0', '1');
        
        -- Test 6-9: Subtraction tests
        run_test("SUB_BASIC", FUNC_SUB, x"00000008", x"00000003", x"00000005", '0', '0');
        run_test("SUB_ZERO", FUNC_SUB, x"00000005", x"00000005", x"00000000", '1', '0');
        run_test("SUB_NEGATIVE", FUNC_SUB, x"00000003", x"00000005", x"FFFFFFFE", '0', '1');
        run_test("SUB_UNDERFLOW", FUNC_SUB, x"80000000", x"00000001", x"7FFFFFFF", '0', '0');
        
        -- Test 10-12: Logical Left Shift tests
        run_test("SLL_BASIC", FUNC_SLL, x"00000001", x"00000004", x"00000010", '0', '0');
        run_test("SLL_ZERO", FUNC_SLL, x"00000000", x"00000004", x"00000000", '1', '0');
        run_test("SLL_MAX", FUNC_SLL, x"00000001", x"0000001F", x"80000000", '0', '1');
        
        -- Test 13-15: Logical Right Shift tests
        run_test("SRL_BASIC", FUNC_SLR, x"00000010", x"00000004", x"00000001", '0', '0');
        run_test("SRL_ZERO", FUNC_SLR, x"00000000", x"00000004", x"00000000", '1', '0');
        run_test("SRL_SIGN", FUNC_SLR, x"80000000", x"00000001", x"40000000", '0', '0');
        
        -- Test 16-18: Arithmetic Right Shift tests
        run_test("SRA_BASIC", FUNC_SRA, x"00000010", x"00000004", x"00000001", '0', '0');
        run_test("SRA_NEGATIVE", FUNC_SRA, x"80000000", x"00000001", x"C0000000", '0', '1');
        run_test("SRA_ZERO", FUNC_SRA, x"00000000", x"00000004", x"00000000", '1', '0');
        
        -- Test 19-21: Bitwise AND tests
        run_test("AND_BASIC", FUNC_AND, x"F0F0F0F0", x"0F0F0F0F", x"00000000", '1', '0');
        run_test("AND_ALL_ONES", FUNC_AND, x"FFFFFFFF", x"12345678", x"12345678", '0', '0');
        run_test("AND_PATTERN", FUNC_AND, x"AAAAAAAA", x"55555555", x"00000000", '1', '0');
        
        -- Test 22-24: Bitwise OR tests
        run_test("OR_BASIC", FUNC_OR, x"F0F0F0F0", x"0F0F0F0F", x"FFFFFFFF", '0', '1');
        run_test("OR_ZERO", FUNC_OR, x"00000000", x"00000000", x"00000000", '1', '0');
        run_test("OR_PATTERN", FUNC_OR, x"AAAAAAAA", x"55555555", x"FFFFFFFF", '0', '1');
        
        -- Test 25-27: Bitwise XOR tests
        run_test("XOR_BASIC", FUNC_XOR, x"F0F0F0F0", x"0F0F0F0F", x"FFFFFFFF", '0', '1');
        run_test("XOR_SAME", FUNC_XOR, x"12345678", x"12345678", x"00000000", '1', '0');
        run_test("XOR_ZERO", FUNC_XOR, x"12345678", x"00000000", x"12345678", '0', '0');
        
        -- Test 28-31: Set Less Than (signed) tests
        run_test("SLT_TRUE", FUNC_SLT, x"00000003", x"00000005", x"00000001", '0', '0');
        run_test("SLT_FALSE", FUNC_SLT, x"00000005", x"00000003", x"00000000", '1', '0');
        run_test("SLT_EQUAL", FUNC_SLT, x"00000005", x"00000005", x"00000000", '1', '0');
        run_test("SLT_NEGATIVE", FUNC_SLT, x"FFFFFFFF", x"00000001", x"00000001", '0', '0');
        
        -- Test 32-35: Set Less Than Unsigned tests
        run_test("SLTU_TRUE", FUNC_SLTU, x"00000003", x"00000005", x"00000001", '0', '0');
        run_test("SLTU_FALSE", FUNC_SLTU, x"00000005", x"00000003", x"00000000", '1', '0');
        run_test("SLTU_EQUAL", FUNC_SLTU, x"00000005", x"00000005", x"00000000", '1', '0');
        run_test("SLTU_UNSIGNED", FUNC_SLTU, x"00000001", x"FFFFFFFF", x"00000001", '0', '0');
        
        -- Test 36-37: Pass through tests
        run_test("PASS_POSITIVE", FUNC_PASS, x"12345678", x"87654321", x"12345678", '0', '0');
        run_test("PASS_ZERO", FUNC_PASS, x"00000000", x"FFFFFFFF", x"00000000", '1', '0');
        
        -- Test edge cases with maximum and minimum values
        run_test("MAX_UINT", FUNC_ADD, x"FFFFFFFF", x"00000000", x"FFFFFFFF", '0', '1');
        run_test("MIN_INT", FUNC_PASS, x"80000000", x"00000000", x"80000000", '0', '1');
        run_test("MAX_INT", FUNC_PASS, x"7FFFFFFF", x"00000000", x"7FFFFFFF", '0', '0');
        
        wait for clk_period * 5;
        
        report "ALU testbench completed successfully! Total tests: " & integer'image(test_count);
        test_complete <= true;
        wait;
        
    end process;

end architecture testbench;

-- Configuration for the testbench
configuration alu_tb_config of alu_tb is
    for testbench
        for dut : alu
            use configuration work.alu_config;
        end for;
    end for;
end alu_tb_config;