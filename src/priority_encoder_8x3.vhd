-------------------------------------------------------------------------------
-- Title      : 8-to-3 Priority Encoder
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : priority_encoder_8x3.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  8-to-3 priority encoder that outputs the index of the highest
--               priority active input.
-------------------------------------------------------------------------------
-- Copyright (c) 2025 Benjamin VAUCHEL
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2025-07-25  1.0		vauchel	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity priority_encoder_8x3 is
    port (
        in_vector : in  std_logic_vector(7 downto 0);
        result    : out std_logic_vector(2 downto 0)
    );
end entity;

architecture behavioral of priority_encoder_8x3 is
begin
    process(in_vector)
    begin
        if    in_vector(7) = '1' then result <= "111"; -- R-type
        elsif in_vector(6) = '1' then result <= "110"; -- I-type
        elsif in_vector(5) = '1' then result <= "101"; -- U-type
        elsif in_vector(4) = '1' then result <= "100";
        elsif in_vector(3) = '1' then result <= "011";
        elsif in_vector(2) = '1' then result <= "010";
        elsif in_vector(1) = '1' then result <= "001";
        elsif in_vector(0) = '1' then result <= "000";
        else                          result <= "---";
        end if;
    end process;
end architecture;

architecture combinational of priority_encoder_8x3 is

begin

    result(2) <= in_vector(7) or in_vector(6) or in_vector(5) or in_vector(4);
    result(1) <= in_vector(7) or in_vector(6) or ((not in_vector(5)) and (not in_vector(4)) and (in_vector(3) or in_vector(2)));
    result(0) <= in_vector(7) or ((not in_vector(6)) and (in_vector(5) or ((not in_vector(4)) and in_vector(3)) or ((not in_vector(4)) and (not in_vector(3)) and not(in_vector(2)) and in_vector(1))));
    
end architecture combinational;