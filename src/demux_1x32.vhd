-------------------------------------------------------------------------------
-- Title      : 1-to-32 Demultiplexer
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : demux_1x32.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  1-to-32 demultiplexer with write enable.
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

entity demux_1x32 is
    port (
        sel   : in  std_logic_vector(4 downto 0);
        w_en  : in  std_logic;
        d_out  : out std_logic_vector(31 downto 0)
    );
end entity demux_1x32;

architecture sequential of demux_1x32 is
begin
    process(sel, w_en)
        variable temp : std_logic_vector(31 downto 0) := (others => '0');
    begin
        temp := (others => '0');
        if w_en = '1' then
            temp(to_integer(unsigned(sel))) := '1';
        end if;
        d_out <= temp;
    end process;
end architecture sequential;

architecture sequential2 of demux_1x32 is
begin
    process(sel, w_en)
    begin
        d_out <= (others => '0');
        if w_en = '1' then
            d_out(to_integer(unsigned(sel))) <= '1';
        end if;
    end process;
end architecture sequential2;