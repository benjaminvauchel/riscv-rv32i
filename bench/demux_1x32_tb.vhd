-------------------------------------------------------------------------------
-- Title      : 1-to-32 Demultipler Testbench
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : demux_1x32_tb.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Testbench for the 1-to-32 demultiplexer.
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

entity demux_1x32_tb is
end entity;

architecture test of demux_1x32_tb is

    component demux_1x32
        port (
            sel   : in  std_logic_vector(4 downto 0);
            w_en  : in  std_logic;
            d_out : out std_logic_vector(31 downto 0)
        );
    end component;

    signal sel   : std_logic_vector(4 downto 0);
    signal w_en  : std_logic;
    signal d_out  : std_logic_vector(31 downto 0);

begin

    DUT: demux_1x32
        port map (
            sel   => sel,
            w_en  => w_en,
            d_out  => d_out
        );

    -- Stimulus process
    stimulus: process
    begin
        -- Initial values
        sel  <= (others => '0');
        w_en <= '0';
        wait for 10 ns;

        -- Write enable inactive: no output should be high
        sel  <= "00000";
        w_en <= '0';
        wait for 10 ns;

        -- Write enable active: set different values of sel
        for i in 0 to 31 loop
            sel  <= std_logic_vector(to_unsigned(i, 5));
            w_en <= '1';
            wait for 10 ns;
            assert d_out = std_logic_vector(to_unsigned(2**i - 1, 32)) or d_out(i) = '1'
                report "Test failed at sel = " & integer'image(i)
                severity error;
            w_en <= '0';
            wait for 10 ns;
        end loop;

        wait;
    end process;

end architecture test;

configuration cfg_demux_1x32_tb of demux_1x32_tb is
    for test
        for all : demux_1x32
            use entity work.demux_1x32(sequential2);
        end for;
    end for;
end configuration cfg_demux_1x32_tb;