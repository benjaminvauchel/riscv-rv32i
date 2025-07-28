-------------------------------------------------------------------------------
-- Title      : 32-bit Inverter
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : inverter_32bit.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  32-bit inverter. (Pretty useless...)
-------------------------------------------------------------------------------
-- Copyright (c) 2025 Benjamin VAUCHEL
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2025-07-25  1.0		vauchel	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity inverter_32bit is
    port (
        in_vec  : in  std_logic_vector(31 downto 0);
        out_vec : out std_logic_vector(31 downto 0)
    );
end inverter_32bit;

architecture rtl of inverter_32bit is
begin
    out_vec <= not in_vec;
end rtl;
