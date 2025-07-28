-------------------------------------------------------------------------------
-- Title      : ROM 64x32 Testbench
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : rom_64x32_tb.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description:  Testbench for the ROM 64x32 component of the RISC-V processor.
--               It reads a hex file to initialize the ROM and verifies the
--               output.
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

entity rom_64x32_tb is
end entity;

architecture sim of rom_64x32_tb is
    component rom_64x32
        generic (
            HEX_FILE : string := "C:/Users/benja/Documents/Divers/github/riscv-rv32i/bench/rom.hex"
        );
        port (
            add_i   : in  std_logic_vector(7 downto 0);
            data_o  : out std_logic_vector(31 downto 0)
        );
    end component;

    signal addr   : std_logic_vector(7 downto 0) := (others => '0');
    signal data_o : std_logic_vector(31 downto 0);

begin

    DUT: rom_64x32
        generic map (
            HEX_FILE => "C:/Users/benja/Documents/Divers/github/riscv-rv32i/bench/rom.hex"
        )
        port map (
            add_i  => addr,
            data_o => data_o
        );

    stimulus: process
    begin
        wait for 10 ns;
        
        -- Display the 64 addresses
        for i in 0 to 63 loop
            addr <= std_logic_vector(to_unsigned(4*i, 8));
            wait for 10 ns;
            report "ROM[" & integer'image(4*i) & "] = 0x" & to_hstring(data_o);
        end loop;
        
        report "ROM testbench completed successfully";
        wait;
    end process;

end architecture;