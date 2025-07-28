-------------------------------------------------------------------------------
-- Title      : Register Flip-Flop
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : register_ff.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  A n-bit register flip-flop with asynchronous reset
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

entity register_ff is
    generic ( invert_clock : integer;
              nb_bits      : integer );
    port ( clock    : in  std_logic;
           write_en : in  std_logic;
           reset    : in  std_logic;
           d        : in  std_logic_vector( (nb_bits - 1) downto 0 );
           q        : out std_logic_vector( (nb_bits - 1) downto 0 ) );
end entity register_ff;

architecture sequential of register_ff is 

    signal clock_s  : std_logic;
    signal q_next_s : std_logic_vector( (nb_bits - 1) downto 0 );

begin

    q       <= q_next_s;
    clock_s <= clock when invert_clock = 0 else not(clock);

    process( clock_s, reset, write_en, d ) is
    begin
        if (reset = '1') then q_next_s <= (others => '0');
        elsif (rising_edge(clock_s)) then -- clock_s'event and clock_s = '1'
            if (write_en = '1') then
                q_next_s <= d;
            end if;
        end if;
    end process;

end sequential;



