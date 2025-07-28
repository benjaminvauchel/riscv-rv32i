-------------------------------------------------------------------------------
-- Title      : 5-stage Pipeline of RISC-V Processor
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : pipeline_5stages.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-26
-- Last update: 2025-07-26
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Top Level 5-stage pipeline architecture for a RISC-V processor.
--              Von Neuman architecture with 5 stages: IF, ID, EX, MEM, WB.
--              The processor supports a part of the RV32I instruction set.
-------------------------------------------------------------------------------
-- Copyright (c) 2025 Benjamin VAUCHEL
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2025-07-26  1.0		vauchel	Created
-- 2025-07-28  1.1		vauchel	Added debug output for all registers
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.rv32i_pack.all;

entity pipeline_5stages is
    port (
        clk_i        : in  std_logic;
        rst_i        : in  std_logic;
        debug_regs_o : out slv32_array -- DEBUG: Outputs all registers for debugging
    );
end entity pipeline_5stages;

architecture struct_arch of pipeline_5stages is

    component data_path
        port (
            clk_i         : in  std_logic;
            rst_i         : in  std_logic;
            alu_control_i : in  std_logic_vector(3 downto 0);
            alu_src1_i    : in  std_logic;
            alu_src2_i    : in  std_logic;
            stall_i       : in  std_logic;
            rd_add_i      : in  std_logic_vector(4 downto 0);
            reg_write_i   : in  std_logic;
            imm_gen_sel_i : in  std_logic;
            mem_we_i      : in  std_logic;
            wb_sel_i      : in  std_logic;
            instruction_o : out std_logic_vector(31 downto 0);
            zero_o        : out std_logic;
            lt_o          : out std_logic;
            debug_regs_o  : out slv32_array
        );
    end component;

    component control_path
        port ( alu_lt_i      : in  std_logic;
               alu_zero_i    : in  std_logic;
               clk_i         : in  std_logic;
               instruction_i : in  std_logic_vector(31 downto 0);
               rst_i         : in  std_logic;
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

    signal alu_control_s : std_logic_vector(3 downto 0);
    signal alu_src1_s    : std_logic;
    signal alu_src2_s    : std_logic;
    signal stall_s       : std_logic;
    signal rd_add_s      : std_logic_vector(4 downto 0);
    signal reg_write_s   : std_logic;
    signal imm_gen_sel_s : std_logic;
    signal mem_we_s      : std_logic;
    signal wb_sel_s      : std_logic;

    signal instruction_s : std_logic_vector(31 downto 0);
    signal alu_zero_s : std_logic;
    signal alu_lt_s : std_logic;

begin

    data_path_inst : data_path
        port map (
            clk_i         => clk_i,
            rst_i         => rst_i,
            alu_control_i => alu_control_s,
            alu_src1_i    => alu_src1_s,
            alu_src2_i    => alu_src2_s,
            stall_i       => stall_s,
            rd_add_i      => rd_add_s,
            reg_write_i   => reg_write_s,
            imm_gen_sel_i => imm_gen_sel_s,
            mem_we_i      => mem_we_s,
            wb_sel_i      => wb_sel_s,
            instruction_o => instruction_s,
            zero_o        => alu_zero_s,
            lt_o          => alu_lt_s,
            debug_regs_o  => debug_regs_o -- DEBUG: Output all registers for debugging
        );
    
    control_path_inst : control_path
        port map (
            clk_i         => clk_i,
            rst_i         => rst_i,
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

end architecture struct_arch;