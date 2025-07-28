-------------------------------------------------------------------------------
-- Title      : Immediate Value Generator
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : imm_gen.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-26
-- Last update: 2025-07-26
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  Extract immediate values from instruction fields. Supports
--               both I-type and U-type immediate values.
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

entity imm_gen is
    port (
        instruction_i : in  std_logic_vector(31 downto 0);
        imm_gen_sel_i : in  std_logic; -- 0 for I-type, 1 for U-type
        instruction_o : out std_logic_vector(31 downto 0)
    );
end entity imm_gen;

architecture rtl of imm_gen is

    component mux2x1 is
        generic ( nb_bits : integer := 32 );
        port ( enable   : in  std_logic;
               sel      : in  std_logic;
               mux_in_0 : in  std_logic_vector((nb_bits - 1) downto 0);
               mux_in_1 : in  std_logic_vector((nb_bits - 1) downto 0);
               mux_out  : out std_logic_vector((nb_bits - 1) downto 0) );
    end component;

    signal i_type_imm : std_logic_vector(11 downto 0);
    signal extended_i_type_imm : std_logic_vector(31 downto 0);
    signal u_type_imm : std_logic_vector(19 downto 0);
    signal padded_u_type_imm : std_logic_vector(31 downto 0);

begin

    i_type_imm <= instruction_i(31 downto 20);
    extended_i_type_imm <= (31 downto 12 => i_type_imm(11)) & i_type_imm;
    -- Could also use: imm32_slv <= std_logic_vector(resize(signed(imm12_slv), 32));
    u_type_imm <= instruction_i(31 downto 12);
    padded_u_type_imm <= u_type_imm & (11 downto 0 => '0');

    imm_gen_mux: mux2x1
        generic map (nb_bits => 32)
        port map (
            enable   => '1',
            sel      => imm_gen_sel_i,
            mux_in_0 => extended_i_type_imm,
            mux_in_1 => padded_u_type_imm,
            mux_out  => instruction_o
        );

end architecture rtl;