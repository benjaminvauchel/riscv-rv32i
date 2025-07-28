-------------------------------------------------------------------------------
-- Title      : 32-bit Logical Shift Left
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : lsl_32bit.vhd
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lsl_32bit is
    port (
        data_i   : in  std_logic_vector(31 downto 0);
        shamt_i  : in  std_logic_vector(4 downto 0); -- shift amount: 0 to 31
        result_o : out std_logic_vector(31 downto 0)
    );
end lsl_32bit;


architecture rtl of lsl_32bit is
begin
    result_o <= std_logic_vector(shift_left(unsigned(data_i), to_integer(unsigned(shamt_i))));
end rtl;


architecture structural of lsl_32bit is
    signal stage0, stage1, stage2, stage3, stage4 : std_logic_vector(31 downto 0);
begin
    -- Stage 0: shift by 1 bit if shamt_i(0) = '1'
    stage0 <= data_i(30 downto 0) & '0' when shamt_i(0) = '1' else
              data_i;

    -- Stage 1: shift by 2 bits if shamt_i(1) = '1'
    stage1 <= stage0(29 downto 0) & "00" when shamt_i(1) = '1' else
              stage0;

    -- Stage 2: shift by 4 bits if shamt_i(2) = '1'
    stage2 <= stage1(27 downto 0) & "0000" when shamt_i(2) = '1' else
              stage1;

    -- Stage 3: shift by 8 bits if shamt_i(3) = '1'
    stage3 <= stage2(23 downto 0) & X"00" when shamt_i(3) = '1' else
              stage2;

    -- Stage 4: shift by 16 bits if shamt_i(4) = '1'
    stage4 <= stage3(15 downto 0) & X"0000" when shamt_i(4) = '1' else
              stage3;

    result_o <= stage4;

end structural;