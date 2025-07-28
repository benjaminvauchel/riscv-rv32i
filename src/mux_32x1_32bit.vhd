-------------------------------------------------------------------------------
-- Title      : 32-bit 32-to-1 Multiplexer
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : mux_32x1_32bit.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  32-bit 32-to-1 multiplexer with bit enable.
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
use work.rv32i_pack.all;

entity mux_32x1_32bit is
    port (
        enable     : in  std_logic;
        sel        : in  std_logic_vector(4 downto 0);
        mux_inputs : in  slv32_array;
        mux_out    : out std_logic_vector(31 downto 0)
    );
end entity mux_32x1_32bit;

architecture behavioral of mux_32x1_32bit is
begin
    process(enable, sel, mux_inputs)
    begin
        if enable = '0' then
            mux_out <= (others => '0');
        else
            mux_out <= mux_inputs(to_integer(unsigned(sel)));
        end if;
    end process;
end architecture behavioral;
