-------------------------------------------------------------------------------
-- Title      : Register Bank
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : register_bank.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  A register bank containing 32 registers of 32 bits each.
--               Supports asynchronous reading from two registers and
--               synchronous writing to one register.
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
use work.rv32i_pack.all;

entity register_bank is
    port (
        clk_i        : in  std_logic;
        we_i         : in  std_logic;
        rst_i        : in  std_logic;
        rd_data_i    : in  std_logic_vector(31 downto 0); -- Data to write into the register
        rd_add_i     : in  std_logic_vector(4 downto 0); -- Select one of the 32 registers
        rs1_add_i    : in  std_logic_vector(4 downto 0); -- Read register 1
        rs2_add_i    : in  std_logic_vector(4 downto 0);  -- Read register 2
        rs1_data_o   : out std_logic_vector(31 downto 0);
        rs2_data_o   : out std_logic_vector(31 downto 0);
        debug_regs_o : out slv32_array -- For debugging purposes, outputs all registers
    );
end entity register_bank;

architecture structural of register_bank is

    component register_ff
        generic ( invert_clock : integer := 0;
                  nb_bits      : integer := 32 );
        port ( clock    : in  std_logic;
               write_en : in  std_logic;
               reset    : in  std_logic;
               d        : in  std_logic_vector( (nb_bits - 1) downto 0 );
               q        : out std_logic_vector( (nb_bits - 1) downto 0 ) );
    end component;

    component demux_1x32
        port (
            sel   : in  std_logic_vector(4 downto 0);
            w_en  : in  std_logic;
            d_out : out std_logic_vector(31 downto 0)
        );
    end component;

    component mux_32x1_32bit
        port (
            enable     : in  std_logic;
            sel        : in  std_logic_vector(4 downto 0);
            mux_inputs : in  slv32_array;
            mux_out    : out std_logic_vector(31 downto 0)
        );
    end component;

    signal rs_data_s : slv32_array;
    signal we_s : std_logic_vector(31 downto 0);
    
begin

    DMX: demux_1x32
        port map (
            sel   => rd_add_i,
            w_en  => we_i,
            d_out => we_s
        );
    
    MUX_rs1: mux_32x1_32bit
        port map (
            enable     => '1',
            sel        => rs1_add_i,
            mux_inputs => rs_data_s,
            mux_out    => rs1_data_o
        );
    
    MUX_rs2: mux_32x1_32bit
        port map (
            enable     => '1',
            sel        => rs2_add_i,
            mux_inputs => rs_data_s,
            mux_out    => rs2_data_o
        );

    -- Generate "register 0" separately
    rs_data_s(0) <= (others => '0'); -- Always reads as 0

    -- Generate registers 1 to 31
    REG_gen: for i in 1 to 31 generate
    begin
        reg_ff: register_ff
            generic map ( invert_clock => 0, nb_bits => 32 )
            port map (
                clock    => clk_i,
                write_en => we_s(i),
                reset    => rst_i,
                d        => rd_data_i,
                q        => rs_data_s(i)
            );
    end generate;

    debug_regs_o <= rs_data_s; -- DEBUG: Output all registers for debugging


end architecture structural;