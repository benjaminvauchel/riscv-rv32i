-------------------------------------------------------------------------------
-- Title      : ROM 64x32
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : rom_64x32.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  A simple ROM with 64 32-bit words.
--               This ROM is used as an instruction memory.
--               Addresses are 1-byte wide (simplified version).
-------------------------------------------------------------------------------
-- Copyright (c) 2025 Benjamin VAUCHEL
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2025-07-26  1.0		vauchel	Created
-- 2025-07-28  1.1		vauchel	Added report messages and fixed bugs
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
library work;
use work.rv32i_pack.all;

entity rom_64x32 is
    generic (
        HEX_FILE : string := "C:/Users/benja/Documents/Divers/github/riscv-rv32i/bench/rom.hex"
    );
    port (
        add_i   : in  std_logic_vector(7 downto 0);
        data_o  : out std_logic_vector(31 downto 0)
    );
end entity;

architecture behavioral of rom_64x32 is

    -- Function to convert a single hex character to 4-bit std_logic_vector
    function hex_char_to_slv(c : character) return std_logic_vector is
    begin
        case c is
            when '0' => return "0000";
            when '1' => return "0001";
            when '2' => return "0010";
            when '3' => return "0011";
            when '4' => return "0100";
            when '5' => return "0101";
            when '6' => return "0110";
            when '7' => return "0111";
            when '8' => return "1000";
            when '9' => return "1001";
            when 'A' | 'a' => return "1010";
            when 'B' | 'b' => return "1011";
            when 'C' | 'c' => return "1100";
            when 'D' | 'd' => return "1101";
            when 'E' | 'e' => return "1110";
            when 'F' | 'f' => return "1111";
            when others => return "0000"; -- Default for invalid characters
        end case;
    end function;

    -- Function to convert 8-character hex string to 32-bit std_logic_vector
    function hex_string_to_slv(hex_str : string(1 to 8)) return std_logic_vector is
        variable result : std_logic_vector(31 downto 0);
    begin
        for i in 0 to 7 loop
            result(31-i*4 downto 28-i*4) := hex_char_to_slv(hex_str(i+1));
        end loop;
        return result;
    end function;

    -- Function to convert std_logic_vector to hex string for reporting
    function slv_to_hex_string(slv : std_logic_vector(31 downto 0)) return string is
        variable result : string(1 to 8);
        variable nibble : std_logic_vector(3 downto 0);
    begin
        for i in 0 to 7 loop
            nibble := slv(31-i*4 downto 28-i*4);
            case nibble is
                when "0000" => result(i+1) := '0';
                when "0001" => result(i+1) := '1';
                when "0010" => result(i+1) := '2';
                when "0011" => result(i+1) := '3';
                when "0100" => result(i+1) := '4';
                when "0101" => result(i+1) := '5';
                when "0110" => result(i+1) := '6';
                when "0111" => result(i+1) := '7';
                when "1000" => result(i+1) := '8';
                when "1001" => result(i+1) := '9';
                when "1010" => result(i+1) := 'A';
                when "1011" => result(i+1) := 'B';
                when "1100" => result(i+1) := 'C';
                when "1101" => result(i+1) := 'D';
                when "1110" => result(i+1) := 'E';
                when "1111" => result(i+1) := 'F';
                when others => result(i+1) := 'X';
            end case;
        end loop;
        return result;
    end function;

    -- Function to initialize ROM from hex file
    impure function init_rom_from_file(file_name : string) return rom_t is
        file hex_file : text;
        variable file_status : file_open_status;
        variable linebuf : line;
        variable rom_data : rom_t := (others => (others => '0'));
        variable i : integer := 0;
        variable hex_str : string(1 to 8);
        variable read_ok : boolean;
        variable char : character;
        variable word_count : integer;
        variable colon_found : boolean;
    begin
        file_open(file_status, hex_file, file_name, read_mode);
        if file_status = open_ok then
            while not endfile(hex_file) and i < 64 loop
                readline(hex_file, linebuf);
                
                -- Skip empty lines and header line
                if linebuf'length > 0 and linebuf.all(1) /= 'v' then
                    -- Skip address part (find colon and skip it)
                    colon_found := false;
                    for pos in 1 to linebuf'length loop
                        if linebuf.all(pos) = ':' then
                            -- Found colon, now read hex words after it
                            colon_found := true;
                            word_count := pos + 1;
                            
                            -- Read multiple 8-character hex words from this line
                            while word_count <= linebuf'length - 7 and i < 64 loop
                                -- Skip spaces
                                while word_count <= linebuf'length and linebuf.all(word_count) = ' ' loop
                                    word_count := word_count + 1;
                                end loop;
                                
                                -- Read 8-character hex word if enough characters remain
                                if word_count <= linebuf'length - 7 then
                                    for j in 1 to 8 loop
                                        hex_str(j) := linebuf.all(word_count + j - 1);
                                    end loop;
                                    
                                    rom_data(i) := hex_string_to_slv(hex_str);
                                    i := i + 1;
                                    word_count := word_count + 8;
                                    
                                    -- Skip space after hex word
                                    if word_count <= linebuf'length and linebuf.all(word_count) = ' ' then
                                        word_count := word_count + 1;
                                    end if;
                                else
                                    exit; -- Not enough characters for another word
                                end if;
                            end loop;
                            exit; -- Found colon and processed line
                        end if;
                    end loop;
                    
                    if not colon_found then
                        report "Warning: No colon found in line, skipping" severity warning;
                    end if;
                end if;
            end loop;
            
            file_close(hex_file);
            
            -- Report initialization with values
            report "ROM initialized with " & integer'image(i) & " words from " & file_name;
            report "ROM contents (not with addresses but indices here):";
            for j in 0 to i-1 loop
                report "  ROM[" & integer'image(j) & "] = 0x" & slv_to_hex_string(rom_data(j));
            end loop;
            
        else
            -- File couldn't be opened, use default values
            report "Could not open file " & file_name & ", using default ROM contents (all zeros)"
                severity warning;
        end if;
        
        return rom_data;
    end function;

    -- Initialize ROM with data from hex file
    signal rom : rom_t := init_rom_from_file(HEX_FILE);

begin
    -- ROM read process
    data_o <= rom(to_integer(unsigned(add_i(7 downto 2))));
    
end architecture;