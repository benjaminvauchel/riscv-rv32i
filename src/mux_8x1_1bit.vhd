-------------------------------------------------------------------------------
-- Title      : 1-bit 8-to-1 Multiplexer
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : mux_8x1_1bit.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  1-bit 8-to-1 multiplexer with bit enable.
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

entity mux_8x1_1bit is
   port ( enable   : in  std_logic;
          sel      : in  std_logic_vector(2 downto 0);
          mux_in_0 : in  std_logic;
          mux_in_1 : in  std_logic;
          mux_in_2 : in  std_logic;
          mux_in_3 : in  std_logic;
          mux_in_4 : in  std_logic;
          mux_in_5 : in  std_logic;
          mux_in_6 : in  std_logic;
          mux_in_7 : in  std_logic;
          mux_out  : out std_logic );
end entity mux_8x1_1bit;

architecture behavioral of mux_8x1_1bit is 

    signal selected_mux_s : std_logic;

begin

    -- Could have put this in the process with the case statement too
    -- but this is more readable and less bulky
    with sel select
        selected_mux_s <= mux_in_0 when "000",
                          mux_in_1 when "001",
                          mux_in_2 when "010",
                          mux_in_3 when "011",
                          mux_in_4 when "100",
                          mux_in_5 when "101",
                          mux_in_6 when "110",
                          mux_in_7 when others;

    -- Could also have not used a process (maybe better)
    process(enable, selected_mux_s)
    begin
        if enable = '0' then
            mux_out <= '0';
        else
            mux_out <= selected_mux_s;
        end if;
    end process;

end behavioral;


