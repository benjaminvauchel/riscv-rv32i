-------------------------------------------------------------------------------
-- Title      : Immediate Value Generator Testbench
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : imm_gen_tb.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-26
-- Last update: 2025-07-26
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description:  Testbench for the Immediate Value Generator (imm_gen).
-------------------------------------------------------------------------------
-- Copyright (c) 2025 Benjamin VAUCHEL
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2025-07-26  1.0		vauchel	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity imm_gen_tb is
end entity imm_gen_tb;

architecture testbench of imm_gen_tb is
    
    component imm_gen is
        port (
            instruction_i : in  std_logic_vector(31 downto 0);
            imm_gen_sel_i : in  std_logic;
            instruction_o : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Test signals
    signal instruction_i : std_logic_vector(31 downto 0);
    signal imm_gen_sel_i : std_logic;
    signal instruction_o : std_logic_vector(31 downto 0);
    
    -- Clock signal
    signal clk : std_logic := '0';
    constant clk_period : time := 10 ns;
    
    signal test_complete : boolean := false;

begin

    DUT: imm_gen
        port map (
            instruction_i => instruction_i,
            imm_gen_sel_i => imm_gen_sel_i,
            instruction_o => instruction_o
        );

    clk_process: process
    begin
        while not test_complete loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    stim_proc: process
        variable line_out : line;
        
        -- Procedure to apply test case and check result
        procedure test_case(
            constant test_name : in string;
            constant instr : in std_logic_vector(31 downto 0);
            constant sel : in std_logic;
            constant expected : in std_logic_vector(31 downto 0)
        ) is
        begin
            -- Apply inputs
            instruction_i <= instr;
            imm_gen_sel_i <= sel;
            
            -- Wait for propagation
            wait for clk_period;
            
            -- Check result
            if instruction_o = expected then
                write(line_out, string'("PASS: ") & test_name);
                writeline(output, line_out);
            else
                write(line_out, string'("FAIL: ") & test_name);
                writeline(output, line_out);
                write(line_out, string'("  Expected: 0x") & to_hstring(expected));
                writeline(output, line_out);
                write(line_out, string'("  Got:      0x") & to_hstring(instruction_o));
                writeline(output, line_out);
            end if;
        end procedure;

    begin
        -- Print test header
        write(line_out, string'("=== IMM_GEN Testbench ==="));
        writeline(output, line_out);
        write(line_out, string'("Testing I-type and U-type immediate generation"));
        writeline(output, line_out);
        write(line_out, string'(""));
        writeline(output, line_out);

        -- Wait for initial settling
        wait for clk_period * 2;

        -- Test I-type immediates (imm_gen_sel_i = '0')
        write(line_out, string'("--- I-TYPE IMMEDIATE TESTS ---"));
        writeline(output, line_out);
        
        -- Test case 1: Positive I-type immediate
        -- Instruction: 0x00150513 (addi x10, x10, 1)
        -- I-type immediate: bits[31:20] = 0x001 = 1
        -- Expected: sign-extended to 0x00000001
        test_case("I-type positive small (1)", 
                  x"00150513", '0', x"00000001");
        
        -- Test case 2: Negative I-type immediate
        -- Instruction: 0xFFF50513 (addi x10, x10, -1)
        -- I-type immediate: bits[31:20] = 0xFFF = -1
        -- Expected: sign-extended to 0xFFFFFFFF
        test_case("I-type negative (-1)", 
                  x"FFF50513", '0', x"FFFFFFFF");
        
        -- Test case 3: Maximum positive I-type immediate
        -- I-type immediate: bits[31:20] = 0x7FF = 2047
        -- Expected: sign-extended to 0x000007FF
        test_case("I-type max positive (2047)", 
                  x"7FF50513", '0', x"000007FF");
        
        -- Test case 4: Maximum negative I-type immediate
        -- I-type immediate: bits[31:20] = 0x800 = -2048
        -- Expected: sign-extended to 0xFFFFF800
        test_case("I-type max negative (-2048)", 
                  x"80050513", '0', x"FFFFF800");
        
        -- Test case 5: Zero I-type immediate
        -- I-type immediate: bits[31:20] = 0x000 = 0
        -- Expected: 0x00000000
        test_case("I-type zero", 
                  x"00050513", '0', x"00000000");
        
        -- Test case 6: Random positive I-type
        -- I-type immediate: bits[31:20] = 0x2A5 = 677
        -- Expected: sign-extended to 0x000002A5
        test_case("I-type random positive (677)", 
                  x"2A550513", '0', x"000002A5");

        write(line_out, string'(""));
        writeline(output, line_out);

        -- Test U-type immediates (imm_gen_sel_i = '1')
        write(line_out, string'("--- U-TYPE IMMEDIATE TESTS ---"));
        writeline(output, line_out);
        
        -- Test case 7: U-type immediate test 1
        -- Instruction: 0x12345037 (lui x0, 0x12345)
        -- U-type immediate: bits[31:12] = 0x12345
        -- Expected: zero-extended to upper 20 bits: 0x12345000
        test_case("U-type test 1 (0x12345)", 
                  x"12345037", '1', x"12345000");
        
        -- Test case 8: U-type immediate test 2
        -- U-type immediate: bits[31:12] = 0xABCDE
        -- Expected: zero-extended to upper 20 bits: 0xABCDE000
        test_case("U-type test 2 (0xABCDE)", 
                  x"ABCDE037", '1', x"ABCDE000");
        
        -- Test case 9: U-type all zeros
        -- U-type immediate: bits[31:12] = 0x00000
        -- Expected: 0x00000000
        test_case("U-type all zeros", 
                  x"00000037", '1', x"00000000");
        
        -- Test case 10: U-type all ones
        -- U-type immediate: bits[31:12] = 0xFFFFF
        -- Expected: 0xFFFFF000
        test_case("U-type all ones", 
                  x"FFFFF037", '1', x"FFFFF000");
        
        -- Test case 11: U-type pattern test
        -- U-type immediate: bits[31:12] = 0x55555
        -- Expected: 0x55555000
        test_case("U-type pattern (0x55555)", 
                  x"55555037", '1', x"55555000");

        write(line_out, string'(""));
        writeline(output, line_out);

        -- Additional edge cases
        write(line_out, string'("--- EDGE CASE TESTS ---"));
        writeline(output, line_out);
        
        -- Test case 12: I-type with MSB=0, but high bits set
        -- I-type immediate: bits[31:20] = 0x7FE = 2046
        test_case("I-type near max positive (2046)", 
                  x"7FE50513", '0', x"000007FE");
        
        -- Test case 13: I-type with MSB=1, but not all high bits
        -- I-type immediate: bits[31:20] = 0x801 = -2047
        test_case("I-type near max negative (-2047)", 
                  x"80150513", '0', x"FFFFF801");

        -- Test the same instruction with different selectors
        write(line_out, string'(""));
        writeline(output, line_out);
        write(line_out, string'("--- SELECTOR COMPARISON TESTS ---"));
        writeline(output, line_out);
        
        -- Test case 14 & 15: Same instruction, different selectors
        -- Instruction: 0x12345678
        -- I-type (sel=0): bits[31:20] = 0x123, sign-extended = 0x00000123
        -- U-type (sel=1): bits[31:12] = 0x12345, zero-padded = 0x12345000
        test_case("Same instr as I-type", 
                  x"12345678", '0', x"00000123");
        test_case("Same instr as U-type", 
                  x"12345678", '1', x"12345000");

        write(line_out, string'(""));
        writeline(output, line_out);
        write(line_out, string'("=== Test Complete ==="));
        writeline(output, line_out);
        
        test_complete <= true;
        wait;
    end process;

end architecture testbench;