-------------------------------------------------------------------------------
-- Title      : Control Path
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : control_path.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-25
-- Last update: 2025-07-25
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  Control path for the RISC-V processor,
--               managing instruction decoding
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
library work;

entity control_path is
   port ( alu_lt_i      : in  std_logic;
          alu_zero_i    : in  std_logic;
          clk_i         : in  std_logic;
          instruction_i : in  std_logic_vector(31 downto 0);
          rst_i         : in  std_logic;
          alu_control_o : out std_logic_vector(3 downto 0);
          alu_src1_o    : out std_logic;
          alu_src2_o    : out std_logic;
          imm_gen_sel_o : out std_logic;
          mem_we_o      : out std_logic;
          rd_add_o      : out std_logic_vector(4 downto 0);
          reg_write_o   : out std_logic;
          stall_o       : out std_logic;
          wb_sel_o      : out std_logic );
end entity control_path;

architecture behavioral of control_path is

    component register_ff
        generic ( invert_clock : integer;
              nb_bits      : integer );
        port ( clock    : in  std_logic;
               write_en : in  std_logic;
               reset    : in  std_logic;
               d        : in  std_logic_vector( (nb_bits - 1) downto 0 );
               q        : out std_logic_vector( (nb_bits - 1) downto 0 ) );
    end component;

    component comparator
        generic (
            nb_bits        : integer := 32;
            twoscomplement : integer := 1  -- 1 for signed, 0 for unsigned
        );
        port (
            a_in                : in  std_logic_vector(nb_bits - 1 downto 0);
            b_in                : in  std_logic_vector(nb_bits - 1 downto 0);
            a_equals_b_out      : out std_logic;
            a_greaterthan_b_out : out std_logic;
            a_lessthan_b_out    : out std_logic );
    end component;

    component priority_encoder_8x3
        port (
            in_vector : in  std_logic_vector(7 downto 0);
            result    : out std_logic_vector(2 downto 0)
        );
    end component;

    component pla_r_type_func
        port (
            funct3  : in  std_logic_vector(2 downto 0);
            alu_op_code : out std_logic_vector(3 downto 0)
        );
    end component;

    component mux_2x1
        generic ( nb_bits : integer := 32 );
        port ( enable   : in  std_logic;
               sel      : in  std_logic;
               mux_in_0 : in  std_logic_vector(nb_bits - 1 downto 0);
               mux_in_1 : in  std_logic_vector(nb_bits - 1 downto 0);
               mux_out  : out std_logic_vector(nb_bits - 1 downto 0) );
    end component;

    -- TODO: Remove and replace instances with mux_8x1
    component mux_8x1_1bit
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
    end component;

    component mux_8x1
        generic ( nb_bits : integer := 32 );
        port ( enable   : in  std_logic;
               sel      : in  std_logic_vector( 2 downto 0 );
               mux_in_0 : in  std_logic_vector( (nb_bits - 1) downto 0 );
               mux_in_1 : in  std_logic_vector( (nb_bits - 1) downto 0 );
               mux_in_2 : in  std_logic_vector( (nb_bits - 1) downto 0 );
               mux_in_3 : in  std_logic_vector( (nb_bits - 1) downto 0 );
               mux_in_4 : in  std_logic_vector( (nb_bits - 1) downto 0 );
               mux_in_5 : in  std_logic_vector( (nb_bits - 1) downto 0 );
               mux_in_6 : in  std_logic_vector( (nb_bits - 1) downto 0 );
               mux_in_7 : in  std_logic_vector( (nb_bits - 1) downto 0 );
               mux_out  : out std_logic_vector( (nb_bits - 1) downto 0 )
    );
    end component;

    signal opcode : std_logic_vector(4 downto 0);
    signal func3 : std_logic_vector(2 downto 0);
    signal func7 : std_logic_vector(6 downto 0);
    signal rd_add_w     : std_logic_vector(4 downto 0);
    signal rs1_add_w    : std_logic_vector(4 downto 0);
    signal rs2_add_w    : std_logic_vector(4 downto 0);
    signal stall_w        : std_logic;
    signal dec_cp_write_en : std_logic;
    signal idec : std_logic_vector(31 downto 0);
    signal idec_or_stalled : std_logic_vector(31 downto 0);
    signal exe : std_logic_vector(31 downto 0);
    signal mem : std_logic_vector(31 downto 0);
    signal wb : std_logic_vector(31 downto 0);
    signal r_type_comp_out, i_type_comp_out, u_type_comp_out : std_logic;
    signal priority_encoder_in : std_logic_vector(7 downto 0);
    signal selected_type : std_logic_vector(2 downto 0);
    signal alu_op_code : std_logic_vector(3 downto 0);
    signal exe_op_in : std_logic_vector(2 downto 0);
    signal exe_op_out : std_logic_vector(2 downto 0);
    signal mem_op_out : std_logic_vector(2 downto 0);
    signal mem_we_s : std_logic_vector(0 downto 0);
    signal wb_op_out : std_logic_vector(2 downto 0);
    signal wb_sel_s, reg_write_s : std_logic_vector(0 downto 0);
    signal rs1_rd_comp_out, rs2_rd_comp_out, rd_0_comp_out : std_logic;

begin

    rd_0_comparator: comparator
        generic map (
            nb_bits        => 5,
            twoscomplement => 1
        )
        port map (
            a_in                => rd_add_w,
            b_in                => "00000",
            a_equals_b_out      => rd_0_comp_out,
            a_greaterthan_b_out => open,
            a_lessthan_b_out    => open
        );

    rs1_rd_comparator: comparator
        generic map (
            nb_bits        => 5,
            twoscomplement => 1
        )
        port map (
            a_in                => rs1_add_w,
            b_in                => rd_add_w,
            a_equals_b_out      => rs1_rd_comp_out,
            a_greaterthan_b_out => open,
            a_lessthan_b_out    => open
        );

    rs2_rd_comparator: comparator
        generic map (
            nb_bits        => 5,
            twoscomplement => 1
        )
        port map (
            a_in                => rs2_add_w,
            b_in                => rd_add_w,
            a_equals_b_out      => rs2_rd_comp_out,
            a_greaterthan_b_out => open,
            a_lessthan_b_out    => open
        );

    -- Interlock that blocks the pipeline when there is a data hazard.
    -- Not optimized at all. Blocks the pipeline when rd_add_w = rs1_add_w or rs2_add_w
    -- and rd_add_w != 0. But this does not make the difference whether rs1_add_w is a register or
    -- an immediate value (same for rs2_add_w).
    -- TODO: Optimize this interlock
    stall_w <= (rs1_rd_comp_out or rs2_rd_comp_out) and (not rd_0_comp_out);
    stall_o <= (rs1_rd_comp_out or rs2_rd_comp_out) and (not rd_0_comp_out); -- stall_o <= stall_w;

    dec_cp_write_en <= not stall_w;

    DEC_CP: register_ff
        generic map ( invert_clock => 0, nb_bits => 32 )
        port map (
            clock    => clk_i,
            write_en => dec_cp_write_en,
            reset    => rst_i,
            d        => instruction_i,
            q        => idec
        );
    
    opcode <= idec(6 downto 2);
    rs1_add_w <= idec(19 downto 15);
    rs2_add_w <= idec(24 downto 20);

    mux_idec_stall: mux_2x1
        generic map ( nb_bits => 32 )
        port map (
            enable   => '1',
            sel      => stall_w,
            mux_in_0 => idec,
            mux_in_1 => X"00000013",
            mux_out  => idec_or_stalled
        );

    EXE_CP: register_ff
        generic map ( invert_clock => 0, nb_bits => 32 )
        port map (
            clock    => clk_i,
            write_en => '1',
            reset    => rst_i,
            d        => idec_or_stalled,
            q        => exe
        );
    
    func3 <= exe(14 downto 12);
    func7 <= exe(31 downto 25); -- not implemented

    MEM_CP: register_ff
        generic map ( invert_clock => 0, nb_bits => 32 )
        port map (
            clock    => clk_i,
            write_en => '1',
            reset    => rst_i,
            d        => exe,
            q        => mem
        );

    rd_add_w <= mem(11 downto 7);
    rd_add_o <= mem(11 downto 7);

    -- unused
    WB_CP: register_ff
        generic map ( invert_clock => 0, nb_bits => 32 )
        port map (
            clock    => clk_i,
            write_en => '1',
            reset    => rst_i,
            d        => mem,
            q        => wb
        );
    
    -- rd_add_w <= wb(11 downto 7);
    -- rd_add_o <= wb(11 downto 7);

    R_TYPE_comparator: comparator
        generic map (
            nb_bits        => 5,
            twoscomplement => 1
        )
        port map (
            a_in                => "01100", -- 0x0c
            b_in                => opcode,
            a_equals_b_out      => r_type_comp_out,
            a_greaterthan_b_out => open,
            a_lessthan_b_out    => open
        );

    I_TYPE_comparator: comparator
        generic map (
            nb_bits        => 5,
            twoscomplement => 1
        )
        port map (
            a_in                => "00100", -- 0x04
            b_in                => opcode,
            a_equals_b_out      => i_type_comp_out,
            a_greaterthan_b_out => open,
            a_lessthan_b_out    => open
        );

    U_TYPE_comparator: comparator
        generic map (
            nb_bits        => 5,
            twoscomplement => 1
        )
        port map (
            a_in                => "01101", -- 0x0d
            b_in                => opcode,
            a_equals_b_out      => u_type_comp_out,
            a_greaterthan_b_out => open,
            a_lessthan_b_out    => open
        );
    
    priority_encoder_in <= "00000" & u_type_comp_out & i_type_comp_out & r_type_comp_out;

    type_encoder: priority_encoder_8x3
        port map (
            in_vector => priority_encoder_in,
            result    => selected_type
        );
    
    mux_imm_gen_sel: mux_8x1_1bit
        port map (
            enable   => '1',
            sel      => selected_type,
            mux_in_0 => '0',
            mux_in_1 => '0',
            mux_in_2 => '1',
            mux_in_3 => '0', -- unused
            mux_in_4 => '0', -- unused
            mux_in_5 => '0', -- unused
            mux_in_6 => '0', -- unused
            mux_in_7 => '0', -- unused
            mux_out  => imm_gen_sel_o
        );

    mux_alu_src1: mux_8x1_1bit
        port map (
            enable   => '1',
            sel      => selected_type,
            mux_in_0 => '0',
            mux_in_1 => '0',
            mux_in_2 => '1',
            mux_in_3 => '0', -- unused
            mux_in_4 => '0', -- unused
            mux_in_5 => '0', -- unused
            mux_in_6 => '0', -- unused
            mux_in_7 => '0', -- unused
            mux_out  => alu_src1_o
        );

    mux_alu_src2: mux_8x1_1bit
        port map (
            enable   => '1',
            sel      => selected_type,
            mux_in_0 => '0',
            mux_in_1 => '1',
            mux_in_2 => '0',
            mux_in_3 => '0', -- unused
            mux_in_4 => '0', -- unused
            mux_in_5 => '0', -- unused
            mux_in_6 => '0', -- unused
            mux_in_7 => '0', -- unused
            mux_out  => alu_src2_o
        );
    
    mux_exe_stall: mux_2x1
        generic map ( nb_bits => 3 )
        port map (
            enable   => '1',
            sel      => stall_w,
            mux_in_0 => selected_type,
            mux_in_1 => "001",
            mux_out  => exe_op_in
        );
    
    EXE_OP: register_ff
        generic map ( invert_clock => 0, nb_bits => 3 )
        port map (
            clock    => clk_i,
            write_en => '1',
            reset    => rst_i,
            d        => exe_op_in,
            q        => exe_op_out
        );
    
    R_TYPE_func: pla_r_type_func
        port map (
            funct3  => func3,
            alu_op_code => alu_op_code
        );
    
    mux_alu_control: mux_8x1
        generic map ( nb_bits => 4 )
        port map (
            enable     => '1',
            sel        => exe_op_out,
            mux_in_0   => alu_op_code,
            mux_in_1   => alu_op_code,
            mux_in_2   => X"b",
            mux_in_3   => X"0", -- unused
            mux_in_4   => X"0", -- unused
            mux_in_5   => X"0", -- unused
            mux_in_6   => X"0", -- unused
            mux_in_7   => X"0", -- unused
            mux_out    => alu_control_o
        );
    
    MEM_OP: register_ff
        generic map ( invert_clock => 0, nb_bits => 3 )
        port map (
            clock    => clk_i,
            write_en => '1',
            reset    => rst_i,
            d        => exe_op_out,
            q        => mem_op_out
        );
    
    mux_mem_we: mux_8x1
        generic map ( nb_bits => 1 )
        port map (
            enable   => '1',
            sel      => mem_op_out,
            mux_in_0 => "0",
            mux_in_1 => "0",
            mux_in_2 => "0",
            mux_in_3 => "0", -- unused
            mux_in_4 => "0", -- unused
            mux_in_5 => "0", -- unused
            mux_in_6 => "0", -- unused
            mux_in_7 => "0", -- unused
            mux_out  => mem_we_s
        );

    mem_we_o <= mem_we_s(0);

    WB_OP: register_ff
        generic map ( invert_clock => 0, nb_bits => 3 )
        port map (
            clock    => clk_i,
            write_en => '1',
            reset    => rst_i,
            d        => mem_op_out,
            q        => wb_op_out
        );
    
    mux_wb_sel: mux_8x1
        generic map ( nb_bits => 1 )
        port map (
            enable   => '1',
            sel      => wb_op_out,
            mux_in_0 => "1",
            mux_in_1 => "1",
            mux_in_2 => "1",
            mux_in_3 => "0", -- unused
            mux_in_4 => "0", -- unused
            mux_in_5 => "0", -- unused
            mux_in_6 => "0", -- unused
            mux_in_7 => "0", -- unused
            mux_out  => wb_sel_s
        );

    wb_sel_o <= wb_sel_s(0);

    mux_reg_write: mux_8x1
        generic map ( nb_bits => 1 )
        port map (
            enable   => '1',
            sel      => wb_op_out,
            mux_in_0 => "1",
            mux_in_1 => "1",
            mux_in_2 => "1",
            mux_in_3 => "0", -- unused
            mux_in_4 => "0", -- unused
            mux_in_5 => "0", -- unused
            mux_in_6 => "0", -- unused
            mux_in_7 => "0", -- unused
            mux_out  => reg_write_s
        );
    
    reg_write_o <= reg_write_s(0);

end behavioral;


configuration control_path_cfg of control_path is
    for behavioral
        for all : priority_encoder_8x3
            use entity work.priority_encoder_8x3(behavioral);
        end for;
    end for;
end control_path_cfg;