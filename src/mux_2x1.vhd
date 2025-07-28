-------------------------------------------------------------------------------
-- Title      : n-bit 2-to-1 Multiplexer
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : mux_2x1.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  n-bit 2-to-1 multiplexer with bit enable.
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

entity mux_2x1 is
    generic ( nb_bits : integer := 32 );
    port ( enable   : in  std_logic;
           sel      : in  std_logic;
           mux_in_0 : in  std_logic_vector((nb_bits - 1) downto 0);
           mux_in_1 : in  std_logic_vector((nb_bits - 1) downto 0);
           mux_out  : out std_logic_vector((nb_bits - 1) downto 0) );
end entity mux_2x1;

architecture behavioral of mux_2x1 is

    signal selected_mux_s : std_logic_vector((nb_bits - 1) downto 0);

begin

    with sel select
        selected_mux_s <= mux_in_0 when '0',
                          mux_in_1 when others;

    mux_out <= (others => '0') when enable = '0' else
               selected_mux_s;

end behavioral;



