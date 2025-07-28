-------------------------------------------------------------------------------
-- Title      : Full Adder
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : full_adder.vhd
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
library work;

entity full_adder is

	port(
		a_i, b_i, cin_i  : in std_logic;
		s_o, cout_o      : out std_logic
	);

end full_adder;

architecture struct_arch of full_adder is

	component half_adder
		port (
			a_i, b_i	: in std_logic;
			s_o, c_o	: out std_logic);
	end component;

	
	signal n1_s, n2_s, n3_s : std_logic;
	
	begin
		
		half1 : half_adder port map (
			a_i => cin_i,
			b_i => a_i,
			s_o => n2_s,
			c_o => n1_s);
		
		half2 : half_adder port map (
			a_i => n2_s,
			b_i => b_i,
			s_o => s_o,
			c_o => n3_s);
			
		cout_o <= n1_s or n3_s;
	
end struct_arch;
	
configuration full_adder_conf of full_adder is
	for struct_arch
		for all : half_adder
			use entity work.half_adder(half_adder_arch);
		end for;
	end for;
end full_adder_conf;
