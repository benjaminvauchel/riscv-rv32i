-------------------------------------------------------------------------------
-- Title      : 32-bit Subtractor
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : subtractor_32bit.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  32-bit subtractor using two's complement and the ripple-carry
--               adder.
-------------------------------------------------------------------------------
-- Copyright (c) 2025 Benjamin VAUCHEL
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2025-07-25  1.0		vauchel	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity subtractor_32bit is
    port (
        a_i     : in  std_logic_vector(31 downto 0);
        b_i     : in  std_logic_vector(31 downto 0);
        diff_o  : out std_logic_vector(31 downto 0);
        cout_o  : out std_logic
    );
end subtractor_32bit;

architecture struct_arch of subtractor_32bit is

    component full_adder
        port (
            a_i, b_i, cin_i  : in std_logic;
            s_o, cout_o      : out std_logic
        );
    end component;

    component inverter_32bit
        port (
            in_vec  : in  std_logic_vector(31 downto 0);
            out_vec : out std_logic_vector(31 downto 0)
        );
    end component;

    signal b_inverted : std_logic_vector(31 downto 0);
    signal carry      : std_logic_vector(32 downto 0); -- carry(0) is '1' for +1

begin

    -- Invert b_i
    inv_inst : inverter_32bit
        port map (
            in_vec  => b_i,
            out_vec => b_inverted
        );

    carry(0) <= '1'; -- +1 for two's complement

    gen_adders : for i in 0 to 31 generate
        adder_inst : full_adder
            port map (
                a_i    => a_i(i),
                b_i    => b_inverted(i),
                cin_i  => carry(i),
                s_o    => diff_o(i),
                cout_o => carry(i+1)
            );
    end generate;

    cout_o <= carry(32);

end struct_arch;
