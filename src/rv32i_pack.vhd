-------------------------------------------------------------------------------
-- Title      : Project Package
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : rv32i_pack.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  Package containing common types and definitions for
--               the RISC-V RV32I project.
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

-- Define the array type
package rv32i_pack is
    type slv32_array is array (0 to 31) of std_logic_vector(31 downto 0);
    type rom_t is array (0 to 63) of std_logic_vector(31 downto 0); -- used in rom_64x32.vhd
    type ram_block is array (0 to 255) of std_logic_vector(7 downto 0); -- used in data_memory.vhd
end package;