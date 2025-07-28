-------------------------------------------------------------------------------
-- Title      : Data Memory
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : data_memory.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-26
-- Last update: 2025-07-26
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  Data memory that supports read and write operations.
--               The memory is organized as 256 bytes. The memory can be
--               accessed using a 1-byte address (simplified version).
--               The data output is 32 bits wide.
-------------------------------------------------------------------------------
-- Copyright (c) 2025 Benjamin VAUCHEL
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2025-07-26  1.0		vauchel	Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.rv32i_pack.all;

entity data_memory is
    port (
        clk_i  : in  std_logic;
        we_i   : in  std_logic;
        re_i   : in  std_logic;
        add_i  : in  std_logic_vector(7 downto 0);
        d_i    : in  std_logic_vector(31 downto 0);
        d_o    : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of data_memory is

    signal BL0 : ram_block := (others => (others => '0')); -- LSB
    signal BL1 : ram_block := (others => (others => '0'));
    signal BL2 : ram_block := (others => (others => '0'));
    signal BL3 : ram_block := (others => (others => '0')); -- MSB

    signal data_out : std_logic_vector(31 downto 0);

begin

    process(clk_i)
        variable addr : integer range 0 to 255;
    begin
        if rising_edge(clk_i) then
            addr := to_integer(unsigned(add_i));

            if we_i = '1' then
                BL0(addr) <= d_i(7 downto 0);
                BL1(addr) <= d_i(15 downto 8);
                BL2(addr) <= d_i(23 downto 16);
                BL3(addr) <= d_i(31 downto 24);
            end if;

            if re_i = '1' then
                data_out(7 downto 0)   <= BL0(addr);
                data_out(15 downto 8)  <= BL1(addr);
                data_out(23 downto 16) <= BL2(addr);
                data_out(31 downto 24) <= BL3(addr);
            else
                data_out <= (others => 'Z');
            end if;
        end if;
    end process;

    d_o <= data_out;

end architecture;
