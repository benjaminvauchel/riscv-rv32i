-------------------------------------------------------------------------------
-- Title      : n-bit Comparator
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : comparator.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-28
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  Compares two n-bit vectors for equality, less than, and
--               greater than.
-------------------------------------------------------------------------------
-- Copyright (c) 2025 Benjamin VAUCHEL
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2025-07-25  1.0		vauchel	Created
-- 2025-07-28  1.1		vauchel	Added check for metavalue inputs
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparator is
   generic (
      nb_bits        : integer := 32;
      twoscomplement : integer := 1  -- 1 for signed, 0 for unsigned
   );
   port (
      a_in                : in  std_logic_vector(nb_bits - 1 downto 0);
      b_in                : in  std_logic_vector(nb_bits - 1 downto 0);
      a_equals_b_out      : out std_logic;
      a_greaterthan_b_out : out std_logic;
      a_lessthan_b_out    : out std_logic
   );
end entity comparator;

-- architecture combinational of comparator is

--    signal s_signed_greater   : std_logic;
--    signal s_signed_less      : std_logic;
--    signal s_unsigned_greater : std_logic;
--    signal s_unsigned_less    : std_logic;
--    signal s_has_x_or_u       : std_logic;

--    -- Function to check if a vector contains 'X' or 'U'
--    function has_x_or_u(vec : std_logic_vector) return std_logic is
--    begin
--       for i in vec'range loop
--          if vec(i) = 'X' or vec(i) = 'U' then
--             return '1';
--          end if;
--       end loop;
--       return '0';
--    end function;

-- begin

--    -- Check if either input contains 'X' or 'U'
--    s_has_x_or_u <= has_x_or_u(a_in) or has_x_or_u(b_in);

--    s_signed_less       <= '0' when s_has_x_or_u = '1' else 
--                           '1' when signed(a_in) < signed(b_in) else '0';
--    s_unsigned_less     <= '0' when s_has_x_or_u = '1' else 
--                           '1' when unsigned(a_in) < unsigned(b_in) else '0';
--    s_signed_greater    <= '0' when s_has_x_or_u = '1' else 
--                           '1' when signed(a_in) > signed(b_in) else '0';
--    s_unsigned_greater  <= '0' when s_has_x_or_u = '1' else 
--                           '1' when unsigned(a_in) > unsigned(b_in) else '0';

--    -- Force outputs to '0' if any input contains 'X' or 'U'
--    a_equals_b_out      <= '0' when s_has_x_or_u = '1' else 
--                           '1' when a_in = b_in else '0';
   
--    a_greaterthan_b_out <= s_signed_greater when twoscomplement = 1 else s_unsigned_greater;
   
--    a_lessthan_b_out    <= s_signed_less when twoscomplement = 1 else s_unsigned_less;

-- end architecture combinational;


architecture combinational of comparator is

   -- Function to check if a vector contains 'X' or 'U'
   function has_x_or_u(vec : std_logic_vector) return std_logic is
   begin
      for i in vec'range loop
         if vec(i) = 'X' or vec(i) = 'U' then
            return '1';
         end if;
      end loop;
      return '0';
   end function;

begin

   -- Process to handle all comparisons and avoid metavalue warnings
   process(a_in, b_in)
      variable v_has_metavalue : std_logic;
      variable v_signed_less : std_logic;
      variable v_signed_greater : std_logic;
      variable v_unsigned_less : std_logic;
      variable v_unsigned_greater : std_logic;
   begin
      -- Check if either input contains 'X' or 'U'
      v_has_metavalue := has_x_or_u(a_in) or has_x_or_u(b_in);
      
      if v_has_metavalue = '1' then
         a_equals_b_out <= '0';
         a_greaterthan_b_out <= '0';
         a_lessthan_b_out <= '0';
      else
         if signed(a_in) < signed(b_in) then
            v_signed_less := '1';
         else
            v_signed_less := '0';
         end if;
         
         if unsigned(a_in) < unsigned(b_in) then
            v_unsigned_less := '1';
         else
            v_unsigned_less := '0';
         end if;
         
         if signed(a_in) > signed(b_in) then
            v_signed_greater := '1';
         else
            v_signed_greater := '0';
         end if;
         
         if unsigned(a_in) > unsigned(b_in) then
            v_unsigned_greater := '1';
         else
            v_unsigned_greater := '0';
         end if;
         
         if a_in = b_in then
            a_equals_b_out <= '1';
         else
            a_equals_b_out <= '0';
         end if;
         
         if twoscomplement = 1 then
            a_greaterthan_b_out <= v_signed_greater;
            a_lessthan_b_out <= v_signed_less;
         else
            a_greaterthan_b_out <= v_unsigned_greater;
            a_lessthan_b_out <= v_unsigned_less;
         end if;
      end if;
   end process;

end architecture combinational;