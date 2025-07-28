-------------------------------------------------------------------------------
-- Title      : n-bit Adder
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : adder.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  n-bit ripple-carry adder.
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

entity adder is
    generic (
        nb_bits : integer := 32
    );
    port (
        a_i    : in  std_logic_vector(nb_bits - 1 downto 0);
        b_i    : in  std_logic_vector(nb_bits - 1 downto 0);
        sum_o  : out std_logic_vector(nb_bits - 1 downto 0);
        cout_o : out std_logic
    );
end adder;

architecture struct_arch of adder is

    component full_adder
        port (
            a_i, b_i, cin_i : in  std_logic;
            s_o, cout_o     : out std_logic
        );
    end component;

    signal carry : std_logic_vector(nb_bits downto 0); -- carry(0) = initial carry-in
begin

    carry(0) <= '0'; -- initial carry-in

    gen_adders : for i in 0 to nb_bits - 1 generate
        adder_inst : full_adder
            port map (
                a_i    => a_i(i),
                b_i    => b_i(i),
                cin_i  => carry(i),
                s_o    => sum_o(i),
                cout_o => carry(i+1)
            );
    end generate;

    cout_o <= carry(nb_bits);

end struct_arch;

configuration adder_conf of adder is
	for struct_arch
		for all : full_adder
			use entity work.full_adder(struct_arch);
		end for;
	end for;
end adder_conf;
