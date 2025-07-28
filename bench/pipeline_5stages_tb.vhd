-------------------------------------------------------------------------------
-- Title      : 5-Stage Pipeline Testbench
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : pipeline_5stages_tb.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-28
-- Last update: 2025-07-28
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2025 Benjamin VAUCHEL
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2025-07-28  1.0		vauchel	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
library work;
use work.rv32i_pack.all;

entity pipeline_5stages_tb is
end entity;

architecture sim of pipeline_5stages_tb is

    -- DUT ports
    signal clk    : std_logic := '0';
    signal rst    : std_logic := '1';
    signal debug_regs_s : slv32_array;

    -- Clock period
    constant clk_period : time := 10 ns;

    -- Instantiate the DUT
    component pipeline_5stages
        port (
            clk_i : in  std_logic;
            rst_i : in  std_logic;
            debug_regs_o : out slv32_array -- DEBUG: Outputs all registers for debugging
        );
    end component;

begin

    -- DUT instantiation
    DUT: pipeline_5stages
        port map (
            clk_i => clk,
            rst_i => rst,
            debug_regs_o => debug_regs_s
        );

    -- Clock generation
    clk_process: process
    begin
        loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Reset pulse
    stim_proc: process
    begin
        wait for 10 ns;
        rst <= '0';
        wait;
    end process;

    reg_assert_process: process
    begin
        wait for 180 ns;
        assert debug_regs_s(28) = std_logic_vector(to_unsigned(6, 32))
            report "Error: Register 28 value wrong. Expected: 6. Actual: " & to_string(debug_regs_s(28))
            severity error;
        assert debug_regs_s(29) = std_logic_vector(to_unsigned(4, 32))
            report "Error: Register 29 value wrong. Expected: 4. Actual: " & to_string(debug_regs_s(29))
            severity error;
        assert debug_regs_s(6) = std_logic_vector(to_unsigned(3, 32))
            report "Error: Register 6 value wrong. Expected: 3. Actual: " & to_string(debug_regs_s(6))
            severity error;
        assert debug_regs_s(7) = std_logic_vector(to_unsigned(2, 32))
            report "Error: Register 7 value wrong. Expected: 2. Actual: " & to_string(debug_regs_s(7))
            severity error;

        wait;
    end process;


end architecture;
