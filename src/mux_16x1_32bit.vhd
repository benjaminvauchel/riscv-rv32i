-------------------------------------------------------------------------------
-- Title      : 32-bit 16-to-1 Multiplexer
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : mux_16x1_32bit.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  32-bit 16-to-1 multiplexer with bit enable.
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


entity mux_16x1_32bit is
    port (
        enable     : in  std_logic;
        sel        : in  std_logic_vector( 3 downto 0 );
        mux_in_0   : in  std_logic_vector( 31 downto 0 ); -- Could have used an array for the inputs
        mux_in_1   : in  std_logic_vector( 31 downto 0 );
        mux_in_2   : in  std_logic_vector( 31 downto 0 );
        mux_in_3   : in  std_logic_vector( 31 downto 0 );
        mux_in_4   : in  std_logic_vector( 31 downto 0 );
        mux_in_5   : in  std_logic_vector( 31 downto 0 );
        mux_in_6   : in  std_logic_vector( 31 downto 0 );
        mux_in_7   : in  std_logic_vector( 31 downto 0 );
        mux_in_8   : in  std_logic_vector( 31 downto 0 );
        mux_in_9   : in  std_logic_vector( 31 downto 0 );
        mux_in_10  : in  std_logic_vector( 31 downto 0 );
        mux_in_11  : in  std_logic_vector( 31 downto 0 );
        mux_in_12  : in  std_logic_vector( 31 downto 0 );
        mux_in_13  : in  std_logic_vector( 31 downto 0 );
        mux_in_14  : in  std_logic_vector( 31 downto 0 );
        mux_in_15  : in  std_logic_vector( 31 downto 0 );
        mux_out    : out std_logic_vector( 31 downto 0 )
    );
end entity mux_16x1_32bit;


architecture behavioral of mux_16x1_32bit is
begin
    process(enable, sel, mux_in_0, mux_in_1, mux_in_2, mux_in_3, mux_in_4,
            mux_in_5, mux_in_6, mux_in_7, mux_in_8, mux_in_9, mux_in_10,
            mux_in_11, mux_in_12, mux_in_13, mux_in_14, mux_in_15)
    begin
        if enable = '0' then
            mux_out <= (others => '0');
        else
            case sel is
                when "0000" => mux_out <= mux_in_0;
                when "0001" => mux_out <= mux_in_1;
                when "0010" => mux_out <= mux_in_2;
                when "0011" => mux_out <= mux_in_3;
                when "0100" => mux_out <= mux_in_4;
                when "0101" => mux_out <= mux_in_5;
                when "0110" => mux_out <= mux_in_6;
                when "0111" => mux_out <= mux_in_7;
                when "1000" => mux_out <= mux_in_8;
                when "1001" => mux_out <= mux_in_9;
                when "1010" => mux_out <= mux_in_10;
                when "1011" => mux_out <= mux_in_11;
                when "1100" => mux_out <= mux_in_12;
                when "1101" => mux_out <= mux_in_13;
                when "1110" => mux_out <= mux_in_14;
                when "1111" => mux_out <= mux_in_15;
                when others => mux_out <= (others => '0'); -- should not happen
            end case;
        end if;
    end process;
end behavioral;
