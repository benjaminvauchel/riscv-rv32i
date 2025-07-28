-------------------------------------------------------------------------------
-- Title      : 32-bit XOR Gate
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : xor_32bit.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  
-------------------------------------------------------------------------------
-- Copyright (c) 2025 Benjamin VAUCHEL
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2025-07-25  1.0		vauchel	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity xor_32bit is
    port (
        a_i     : in  std_logic_vector(31 downto 0);
        b_i     : in  std_logic_vector(31 downto 0);
        result_o: out std_logic_vector(31 downto 0)
    );
end xor_32bit;


architecture rtl of xor_32bit is
begin
    result_o <= a_i xor b_i;
end rtl;


architecture structural of xor_32bit is
begin
    gen_xor: for i in 0 to 31 generate
        result_o(i) <= a_i(i) xor b_i(i);
    end generate;
end structural;
