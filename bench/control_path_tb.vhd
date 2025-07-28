-------------------------------------------------------------------------------
-- Title      : Control Path Testbench
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : control_path_tb.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description:  Only tests the stall signal in one scenario.
--               TODO: Add more tests for the stall signal.
--               TODO: Add tests for the other control signals.
-------------------------------------------------------------------------------
-- Copyright (c) 2025 Benjamin VAUCHEL
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2025-07-28  1.0		vauchel	Created
-------------------------------------------------------------------------------



-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity control_path_tb is
end entity control_path_tb;

architecture behavioral of control_path_tb is

    -- Component declaration
    component control_path is
    port (
        clk_i         : in  std_logic;
        rst_i         : in  std_logic;
        alu_lt_i      : in  std_logic;
        alu_zero_i    : in  std_logic;
        instruction_i : in  std_logic_vector(31 downto 0);
        alu_control_o : out std_logic_vector(3 downto 0);
        alu_src1_o    : out std_logic;
        alu_src2_o    : out std_logic;
        imm_gen_sel_o : out std_logic;
        mem_we_o      : out std_logic;
        rd_add_o      : out std_logic_vector(4 downto 0);
        reg_write_o   : out std_logic;
        stall_o       : out std_logic;
        wb_sel_o      : out std_logic
    );
    end component;

    -- Clock and reset signals
    signal clk_s : std_logic := '0';
    signal rst_s : std_logic := '0';

    -- Control signals
    signal alu_lt_s      : std_logic; -- unused
    signal alu_zero_s    : std_logic; -- unused
    signal instruction_s : std_logic_vector(31 downto 0);
    
    -- Output signals
    signal alu_control_s : std_logic_vector(3 downto 0);
    signal alu_src1_s    : std_logic;
    signal alu_src2_s    : std_logic;
    signal imm_gen_sel_s : std_logic;
    signal mem_we_s      : std_logic;
    signal rd_add_s      : std_logic_vector(4 downto 0);
    signal reg_write_s   : std_logic;
    signal stall_s       : std_logic;
    signal wb_sel_s      : std_logic;
    
    -- Clock period
    constant CLK_PERIOD : time := 10 ns;
    
    -- Test control
    signal test_done : boolean := false;
    
    -- Helper procedures
    procedure wait_cycles(cycles : in integer) is
    begin
        for i in 1 to cycles loop
            wait until rising_edge(clk_s);
        end loop;
    end procedure;

begin

    -- Clock generation
    clk_process: process
    begin
        while not test_done loop
            clk_s <= '0';
            wait for CLK_PERIOD/2;
            clk_s <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Device Under Test instantiation
    DUT: control_path
        port map (
            clk_i         => clk_s,
            rst_i         => rst_s,
            alu_lt_i      => alu_lt_s,
            alu_zero_i    => alu_zero_s,
            instruction_i => instruction_s,
            alu_control_o => alu_control_s,
            alu_src1_o    => alu_src1_s,
            alu_src2_o    => alu_src2_s,
            imm_gen_sel_o => imm_gen_sel_s,
            mem_we_o      => mem_we_s,
            rd_add_o      => rd_add_s,
            reg_write_o   => reg_write_s,
            stall_o       => stall_s,
            wb_sel_o      => wb_sel_s
        );

    stall_test: process
    begin
        wait_cycles(2);

        instruction_s <= X"00000313"; -- ADDI r6, r0, #0
        wait_cycles(1); -- DEC 1st instruction

        instruction_s <= X"00000393"; -- ADDI r7, r0, #0
        wait for CLK_PERIOD / 5;
        assert stall_s = '0' report "Stall signal should be low" severity error;
        wait_cycles(1); -- EXE 1st instruction - DEC 2nd

        instruction_s <= X"00336313"; -- ORI r6, r6, 3
        wait for CLK_PERIOD / 5;
        assert stall_s = '1' report "Stall signal should be high" severity error;
        wait_cycles(1); -- MEM 1st instruction - EXE 2nd - DEC 3rd

        instruction_s <= X"0023E393"; -- ORI r7, r7, 2
        wait for CLK_PERIOD / 5;
        assert stall_s = '0' report "Stall signal should be low" severity error;
        wait_cycles(1); -- WB 1st instruction - MEM 2nd - EXE 3rd - DEC 4th

        instruction_s <= X"00630E33"; -- add r28, r6, r6
        wait for CLK_PERIOD / 5;
        assert stall_s = '1' report "Stall signal should be high" severity error;
        wait_cycles(1); -- WB 2nd instruction - MEM 3rd - EXE 4th - DEC 5th

        instruction_s <= X"00738eb3"; -- add r29, r7, r7
        wait for CLK_PERIOD / 5;
        assert stall_s = '0' report "Stall signal should be low" severity error;
        wait_cycles(1); -- WB 3rd instruction - MEM 4th - EXE 5th - DEC 6th

        instruction_s <= X"00000013"; -- NOP (add r0, r0, #0)
        wait for CLK_PERIOD / 5;
        assert stall_s = '0' report "Stall signal should be low" severity error;

        wait;
    end process stall_test;

end architecture behavioral;