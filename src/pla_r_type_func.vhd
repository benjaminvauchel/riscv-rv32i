-------------------------------------------------------------------------------
-- Title      : PLA for R-Type Function Codes
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : pla_r_type_func.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  Programmable Logic Array (PLA) for decoding R-Type function
--               codes into ALU operation codes.
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

entity pla_r_type_func is
    port (
        funct3  : in  std_logic_vector(2 downto 0);
        alu_op_code : out std_logic_vector(3 downto 0)
    );
end entity pla_r_type_func;

architecture combinational of pla_r_type_func is
begin
    process(funct3)
    begin
        case funct3 is
            when "000" => alu_op_code <= "0001";  -- add or sub
            when "100" => alu_op_code <= "1000";  -- xor
            when "110" => alu_op_code <= "0111";  -- or
            when "111" => alu_op_code <= "0110";  -- and
            when "001" => alu_op_code <= "0011";  -- sll
            when "101" => alu_op_code <= "0000";  -- srl or sra
            when others => alu_op_code <= "0000"; -- default/fallback
        end case;
    end process;
end architecture combinational;
