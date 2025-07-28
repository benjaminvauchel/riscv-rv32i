-------------------------------------------------------------------------------
-- Title      : n-bit 8-to-1 Multiplexer
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : mux_8x1.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  n-bit 8-to-1 multiplexer with bit enable.
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


entity mux_8x1 is
    generic ( nb_bits : integer := 32 );
    port (
        enable     : in  std_logic;
        sel        : in  std_logic_vector( 2 downto 0 );
        mux_in_0   : in  std_logic_vector( (nb_bits - 1) downto 0 );
        mux_in_1   : in  std_logic_vector( (nb_bits - 1) downto 0 );
        mux_in_2   : in  std_logic_vector( (nb_bits - 1) downto 0 );
        mux_in_3   : in  std_logic_vector( (nb_bits - 1) downto 0 );
        mux_in_4   : in  std_logic_vector( (nb_bits - 1) downto 0 );
        mux_in_5   : in  std_logic_vector( (nb_bits - 1) downto 0 );
        mux_in_6   : in  std_logic_vector( (nb_bits - 1) downto 0 );
        mux_in_7   : in  std_logic_vector( (nb_bits - 1) downto 0 );
        mux_out    : out std_logic_vector( (nb_bits - 1) downto 0 )
    );
end entity mux_8x1;


architecture behavioral of mux_8x1 is
begin
    -- Could have done without a process
    process(enable, sel, mux_in_0, mux_in_1, mux_in_2, mux_in_3,
            mux_in_4, mux_in_5, mux_in_6, mux_in_7)
    begin
        if enable = '0' then
            mux_out <= (others => '0');
        else
            case sel is
                when "000" => mux_out <= mux_in_0;
                when "001" => mux_out <= mux_in_1;
                when "010" => mux_out <= mux_in_2;
                when "011" => mux_out <= mux_in_3;
                when "100" => mux_out <= mux_in_4;
                when "101" => mux_out <= mux_in_5;
                when "110" => mux_out <= mux_in_6;
                when "111" => mux_out <= mux_in_7;
                when others => mux_out <= (others => '0'); -- should not happen
            end case;
        end if;
    end process;
end behavioral;
