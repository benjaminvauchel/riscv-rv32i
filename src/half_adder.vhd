-------------------------------------------------------------------------------
-- Title      : Half Adder
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : half_adder.vhd
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

library IEEE;
use IEEE.std_logic_1164.all;

entity half_adder is

	port (
		a_i, b_i : in std_logic;
		s_o, c_o : out std_logic);

end half_adder;

architecture half_adder_arch of half_adder is

begin

	s_o <= a_i xor b_i;
	c_o <= a_i and b_i;

end half_adder_arch;
