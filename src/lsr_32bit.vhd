-------------------------------------------------------------------------------
-- Title      : 32-bit Logical Shift Right
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : lsr_32bit.vhd
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

entity lsr_32bit is
    port (
        data_i   : in  std_logic_vector(31 downto 0);
        shamt_i  : in  std_logic_vector(4 downto 0); -- shift amount: 0 to 31
        result_o : out std_logic_vector(31 downto 0)
    );
end lsr_32bit;


architecture rtl of lsr_32bit is
begin
    result_o <= std_logic_vector(shift_right(unsigned(data_i), to_integer(unsigned(shamt_i))));
end rtl;


architecture structural of lsr_32bit is
    signal stage0, stage1, stage2, stage3, stage4 : std_logic_vector(31 downto 0);
begin
    -- Stage 0: shift right by 1 if shamt_i(0) = '1'
    stage0 <= '0' & data_i(31 downto 1) when shamt_i(0) = '1' else
              data_i;

    -- Stage 1: shift right by 2 if shamt_i(1) = '1'
    stage1 <= "00" & stage0(31 downto 2) when shamt_i(1) = '1' else
              stage0;

    -- Stage 2: shift right by 4 if shamt_i(2) = '1'
    stage2 <= "0000" & stage1(31 downto 4) when shamt_i(2) = '1' else
              stage1;

    -- Stage 3: shift right by 8 if shamt_i(3) = '1'
    stage3 <= X"00" & stage2(31 downto 8) when shamt_i(3) = '1' else
              stage2;

    -- Stage 4: shift right by 16 if shamt_i(4) = '1'
    stage4 <= X"0000" & stage3(31 downto 16) when shamt_i(4) = '1' else
              stage3;

    result_o <= stage4;

end structural;