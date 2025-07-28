-------------------------------------------------------------------------------
-- Title      : ALU
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : alu.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  Arithmetic Logic Unit (ALU) for a RISC-V processor.
--               This ALU supports the instruction set RV32I.
--               It supports 1-clock cycle operations such as addition,
--               subtraction, logical operations, shifts, and comparisons.
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
library work;

entity alu is
    port (
        func_i : in  std_logic_vector( 3 downto 0 );
        op1_i  : in  std_logic_vector( 31 downto 0 );
        op2_i  : in  std_logic_vector( 31 downto 0 );
        d_o    : out std_logic_vector( 31 downto 0 );
        lt_o   : out std_logic;
        zero_o : out std_logic
    );
end entity alu;

architecture alu_arch of alu is

    component adder
        generic ( nb_bits : integer := 32 );
        port (
            a_i     : in  std_logic_vector(nb_bits - 1 downto 0);
            b_i     : in  std_logic_vector(nb_bits - 1 downto 0);
            sum_o   : out std_logic_vector(nb_bits - 1 downto 0);
            cout_o  : out std_logic
        );
    end component;

    component subtractor_32bit
        port (
            a_i     : in  std_logic_vector(31 downto 0);
            b_i     : in  std_logic_vector(31 downto 0);
            diff_o  : out std_logic_vector(31 downto 0);
            cout_o  : out std_logic
        );
    end component;

    component lsl_32bit
        port (
            data_i   : in  std_logic_vector(31 downto 0);
            shamt_i  : in  std_logic_vector(4 downto 0);
            result_o : out std_logic_vector(31 downto 0)
        );
    end component;

    component lsr_32bit
        port (
            data_i   : in  std_logic_vector(31 downto 0);
            shamt_i  : in  std_logic_vector(4 downto 0);
            result_o : out std_logic_vector(31 downto 0)
        );
    end component;

    component sra_32bit
        port (
            data_i   : in  std_logic_vector(31 downto 0);
            shamt_i  : in  std_logic_vector(4 downto 0);
            result_o : out std_logic_vector(31 downto 0)
        );
    end component;

    component xor_32bit
        port (
            a_i     : in  std_logic_vector(31 downto 0);
            b_i     : in  std_logic_vector(31 downto 0);
            result_o: out std_logic_vector(31 downto 0)
        );
    end component;

    component comparator
        generic (
            nb_bits        : integer := 32;
            twoscomplement : integer := 1  -- 1 for signed, 0 for unsigned
        );
        port (
            a_in                : in  std_logic_vector(nb_bits - 1 downto 0);
            b_in                : in  std_logic_vector(nb_bits - 1 downto 0);
            a_equals_b_out      : out std_logic;
            a_greaterthan_b_out : out std_logic;
            a_lessthan_b_out    : out std_logic );
    end component;

    component mux_16x1_32bit
        port (
            enable     : in  std_logic;
            sel        : in  std_logic_vector( 3 downto 0 );
            mux_in_0   : in  std_logic_vector( 31 downto 0 );
            mux_in_1   : in  std_logic_vector( 31 downto 0 );
            mux_in_2   : in  std_logic_vector( 31 downto 0 );
            mux_in_3   : in  std_logic_vector( 31 downto 0 );
            mux_in_4   : in  std_logic_vector( 31 downto 0 );
            mux_in_5   : in  std_logic_vector( 31 downto 0 );
            mux_in_6   : in  std_logic_vector( 31 downto 0 );
            mux_in_7   : in  std_logic_vector( 31 downto 0 );
            mux_in_8   : in  std_logic_vector( 31 downto 0 );
            mux_in_9   : in  std_logic_vector( 31 downto 0 );
            mux_in_10  : in  std_logic_vector( 31 downto 0 );
            mux_in_11  : in  std_logic_vector( 31 downto 0 );
            mux_in_12  : in  std_logic_vector( 31 downto 0 );
            mux_in_13  : in  std_logic_vector( 31 downto 0 );
            mux_in_14  : in  std_logic_vector( 31 downto 0 );
            mux_in_15  : in  std_logic_vector( 31 downto 0 );
            mux_out    : out std_logic_vector( 31 downto 0 )
        );
    end component;

    signal add_out  : std_logic_vector(31 downto 0);
    signal sub_out  : std_logic_vector(31 downto 0);
    signal lsl_out  : std_logic_vector(31 downto 0);
    signal lsr_out  : std_logic_vector(31 downto 0);
    signal sra_out  : std_logic_vector(31 downto 0);
    signal and_out  : std_logic_vector(31 downto 0);
    signal or_out   : std_logic_vector(31 downto 0);
    signal xor_out  : std_logic_vector(31 downto 0);
    signal slt_out  : std_logic_vector(31 downto 0);
    signal sltu_out : std_logic_vector(31 downto 0);
    signal zero     : std_logic_vector(31 downto 0);
    signal mux_out  : std_logic_vector(31 downto 0);

begin

    adder_inst: adder
        generic map (nb_bits => 32)
        port map (
            a_i     => op1_i,
            b_i     => op2_i,
            sum_o   => add_out,
            cout_o  => open
        );
    
    subtractor: subtractor_32bit
        port map (
            a_i     => op1_i,
            b_i     => op2_i,
            diff_o  => sub_out,
            cout_o  => open
        );
    
    lsl: lsl_32bit
        port map (
            data_i   => op1_i,
            shamt_i  => op2_i(4 downto 0),
            result_o => lsl_out
        );
    
    lsr: lsr_32bit
        port map (
            data_i   => op1_i,
            shamt_i  => op2_i(4 downto 0),
            result_o => lsr_out
        );

    sra1: sra_32bit
        port map (
            data_i   => op1_i,
            shamt_i  => op2_i(4 downto 0),
            result_o => sra_out
        );
    
    and_out <= op1_i and op2_i;
    or_out <= op1_i or op2_i;

    xor1: xor_32bit
        port map (
            a_i      => op1_i,
            b_i      => op2_i,
            result_o => xor_out
        );
    
    slt: comparator
        generic map (
            nb_bits        => 32,
            twoscomplement => 1
        )
        port map (
            a_in                => op1_i,
            b_in                => op2_i,
            a_equals_b_out      => open,
            a_greaterthan_b_out => open,
            a_lessthan_b_out    => slt_out(0)
        );
    
    slt_out(31 downto 1) <= (others => '0');

    sltu: comparator
        generic map (
            nb_bits        => 32,
            twoscomplement => 0
        )
        port map (
            a_in                => op1_i,
            b_in                => op2_i,
            a_equals_b_out      => open,
            a_greaterthan_b_out => open,
            a_lessthan_b_out    => sltu_out(0)
        );
    
    sltu_out(31 downto 1) <= (others => '0');

    zero <= (others => '0');

    mux: mux_16x1_32bit
        port map (
            enable    => '1',
            sel       => func_i,
            mux_in_0  => zero,
            mux_in_1  => add_out,
            mux_in_2  => sub_out,
            mux_in_3  => lsl_out,
            mux_in_4  => lsr_out,
            mux_in_5  => sra_out,
            mux_in_6  => and_out,
            mux_in_7  => or_out,
            mux_in_8  => xor_out,
            mux_in_9  => slt_out,
            mux_in_10 => sltu_out,
            mux_in_11 => op1_i,
            mux_in_12 => zero,
            mux_in_13 => zero,
            mux_in_14 => zero,
            mux_in_15 => zero,
            mux_out   => mux_out
        );
    
    d_o <= mux_out;

    slt_end: comparator
        generic map (
            nb_bits        => 32,
            twoscomplement => 1
        )
        port map (
            a_in                => mux_out,
            b_in                => zero,
            a_equals_b_out      => zero_o,
            a_greaterthan_b_out => open,
            a_lessthan_b_out    => lt_o
        );

end architecture alu_arch;

configuration alu_config of alu is
    for alu_arch
        for all : adder
            use entity work.adder(struct_arch);
        end for;
        for all : subtractor_32bit
            use entity work.subtractor_32bit(struct_arch);
        end for;
        for all : lsl_32bit
            use entity work.lsl_32bit(structural); --rtl
        end for;
        for all : lsr_32bit
            use entity work.lsr_32bit(structural); --rtl
        end for;
        for all : sra_32bit
            use entity work.sra_32bit(structural); --rtl
        end for;
        for all : xor_32bit
            use entity work.xor_32bit(structural); --rtl
        end for;
        for all : comparator
            use entity work.comparator(combinational);
        end for;
        for all : mux_16x1_32bit
            use entity work.mux_16x1_32bit(behavioral);
        end for;
    end for;
end alu_config;