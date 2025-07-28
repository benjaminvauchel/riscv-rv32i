-------------------------------------------------------------------------------
-- Title      : Data Path
-- Project    : RISC-V Processor
-------------------------------------------------------------------------------
-- File	      : data_path.vhd
-- Author     : Benjamin VAUCHEL <benjamin.vauchel@etu.emse.fr>
-- Created    : 2025-07-26
-- Last update: 2025-07-26
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  
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

entity data_path is
    port (
        clk_i         : in  std_logic;
        rst_i         : in  std_logic;
        alu_control_i : in  std_logic_vector(3 downto 0);
        alu_src1_i    : in  std_logic;
        alu_src2_i    : in  std_logic;
        stall_i       : in  std_logic;
        rd_add_i      : in  std_logic_vector(4 downto 0);
        reg_write_i   : in  std_logic;
        imm_gen_sel_i : in  std_logic;
        mem_we_i      : in  std_logic;
        wb_sel_i      : in  std_logic;
        instruction_o : out std_logic_vector(31 downto 0);
        zero_o        : out std_logic;
        lt_o          : out std_logic;
        debug_regs_o  : out slv32_array -- DEBUG
    );
end entity data_path;

architecture structural of data_path is

    component rom_64x32 is
        generic (
            HEX_FILE : string := "C:/Users/benja/Documents/Divers/github/riscv-rv32i/bench/rom.hex"
        );
        port (
            add_i    : in  std_logic_vector(7 downto 0);
            data_o  : out std_logic_vector(31 downto 0)
        );
    end component;

    component register_bank is
        port (
            clk_i    : in  std_logic;
            we_i     : in  std_logic;
            rst_i    : in  std_logic;
            rd_data_i    : in  std_logic_vector(31 downto 0); -- Data to write into the register
            rd_add_i  : in  std_logic_vector(4 downto 0); -- Select one of the 32 registers
            rs1_data_o : out std_logic_vector(31 downto 0);
            rs1_add_i : in  std_logic_vector(4 downto 0); -- Read register 1
            rs2_data_o : out std_logic_vector(31 downto 0);
            rs2_add_i : in  std_logic_vector(4 downto 0);  -- Read register 2
            debug_regs_o : out slv32_array
        );
    end component;

    component imm_gen is
        port (
            instruction_i : in  std_logic_vector(31 downto 0);
            imm_gen_sel_i : in  std_logic; -- 0 for I-type, 1 for U-type
            instruction_o : out std_logic_vector(31 downto 0)
        );
    end component;

    component alu is
        port (
            func_i : in  std_logic_vector( 3 downto 0 );
            op1_i  : in  std_logic_vector( 31 downto 0 );
            op2_i  : in  std_logic_vector( 31 downto 0 );
            d_o    : out std_logic_vector( 31 downto 0 );
            lt_o   : out std_logic;
            zero_o : out std_logic
        );
    end component;

    component data_memory is
        port (
            clk_i  : in  std_logic;
            we_i   : in  std_logic;
            re_i   : in  std_logic;
            add_i  : in  std_logic_vector(7 downto 0);
            d_i    : in  std_logic_vector(31 downto 0);
            d_o    : out std_logic_vector(31 downto 0)
        );
    end component;

    component register_ff is
        generic ( invert_clock : integer;
                nb_bits      : integer );
        port ( clock    : in  std_logic;
               write_en : in  std_logic;
               reset    : in  std_logic;
               d        : in  std_logic_vector( (nb_bits - 1) downto 0 );
               q        : out std_logic_vector( (nb_bits - 1) downto 0 ) );
    end component;

    component mux2x1 is
        generic ( nb_bits : integer := 32 );
        port ( enable   : in  std_logic;
               sel      : in  std_logic;
               mux_in_0 : in  std_logic_vector((nb_bits - 1) downto 0);
               mux_in_1 : in  std_logic_vector((nb_bits - 1) downto 0);
               mux_out  : out std_logic_vector((nb_bits - 1) downto 0) );
    end component;

    component adder is
        generic ( nb_bits : integer := 32 );
        port (
            a_i     : in  std_logic_vector(nb_bits - 1 downto 0);
            b_i     : in  std_logic_vector(nb_bits - 1 downto 0);
            sum_o   : out std_logic_vector(nb_bits - 1 downto 0);
            cout_o  : out std_logic
        );
    end component;

    signal not_stall_s : std_logic;
    signal pc_w : std_logic_vector(7 downto 0);
    signal pc_next_s : std_logic_vector(7 downto 0);
    signal instruction_s : std_logic_vector(31 downto 0);
    signal dec_instruction_s : std_logic_vector(31 downto 0);
    signal rd_data_w : std_logic_vector(31 downto 0);
    signal rs1_data_s, rs2_data_s : std_logic_vector(31 downto 0);
    signal imm_generated_s : std_logic_vector(31 downto 0);
    signal exe_op1_s, exe_op2_s : std_logic_vector(31 downto 0);
    signal alu_op1_s, alu_op2_s : std_logic_vector(31 downto 0);
    signal mem_op2_s : std_logic_vector(31 downto 0);
    signal alu_result_s : std_logic_vector(31 downto 0);
    signal mem_alu_result_s : std_logic_vector(31 downto 0);
    signal data_memory_i_s, data_memory_o_s : std_logic_vector(31 downto 0);
    signal wb_mem_s, wb_alu_s : std_logic_vector(31 downto 0);

begin

    not_stall_s <= not stall_i;

    PC_adder: adder
        generic map (nb_bits => 8)
        port map (
            a_i     => pc_w,
            b_i     => X"04",
            sum_o   => pc_next_s,
            cout_o  => open
        );
    
    PC_reg: register_ff
        generic map (invert_clock => 0, nb_bits => 8)
        port map (
            clock    => clk_i,
            write_en => not_stall_s,
            reset    => rst_i,
            d        => pc_next_s,
            q        => pc_w
        );
    
    instruction_memory: rom_64x32
        generic map (HEX_FILE => "C:/Users/benja/Documents/Divers/github/riscv-rv32i/bench/rom.hex")
        port map (
            add_i   => pc_w,
            data_o  => instruction_s
        );

    instruction_o <= instruction_s;

    DEC_CP: register_ff
        generic map (invert_clock => 0, nb_bits => 32)
        port map (
            clock    => clk_i,
            write_en => not_stall_s,
            reset    => rst_i,
            d        => instruction_s,
            q        => dec_instruction_s
        );
    
    register_bank_inst: register_bank
        port map (
            clk_i        => clk_i,
            we_i         => reg_write_i,
            rst_i        => rst_i,
            rd_data_i    => rd_data_w,
            rd_add_i     => rd_add_i,
            rs1_add_i    => dec_instruction_s(19 downto 15),
            rs2_add_i    => dec_instruction_s(24 downto 20),
            rs1_data_o   => rs1_data_s,
            rs2_data_o   => rs2_data_s,
            debug_regs_o => debug_regs_o -- DEBUG: Output all registers for debugging
        );

    imm_gen_inst: imm_gen
        port map (
            instruction_i => dec_instruction_s,
            imm_gen_sel_i => imm_gen_sel_i,
            instruction_o => imm_generated_s
        );
    
    mux_exe_op1_imm: mux2x1
        generic map (nb_bits => 32)
        port map (
            enable   => '1',
            sel      => alu_src1_i,
            mux_in_0 => rs1_data_s,
            mux_in_1 => imm_generated_s,
            mux_out  => exe_op1_s
        );

    mux_exe_op2_imm: mux2x1
        generic map (nb_bits => 32)
        port map (
            enable   => '1',
            sel      => alu_src2_i,
            mux_in_0 => rs2_data_s,
            mux_in_1 => imm_generated_s,
            mux_out  => exe_op2_s
        );
    
    EXE_OP1_IMM_DP: register_ff
        generic map (invert_clock => 0, nb_bits => 32)
        port map (
            clock    => clk_i,
            write_en => '1',
            reset    => rst_i,
            d        => exe_op1_s,
            q        => alu_op1_s
        );

    EXE_OP2_IMM_DP: register_ff
        generic map (invert_clock => 0, nb_bits => 32)
        port map (
            clock    => clk_i,
            write_en => '1',
            reset    => rst_i,
            d        => exe_op2_s,
            q        => alu_op2_s
        );
    
    EXE_OP2_DP: register_ff
        generic map (invert_clock => 0, nb_bits => 32)
        port map (
            clock    => clk_i,
            write_en => '1',
            reset    => rst_i,
            d        => rs2_data_s,
            q        => mem_op2_s
        );
    
    alu_inst: alu
        port map (
            func_i  => alu_control_i,
            op1_i   => alu_op1_s,
            op2_i   => alu_op2_s,
            d_o     => alu_result_s,
            lt_o    => lt_o,
            zero_o  => zero_o
        );
    
    MEM_ALUO_DP: register_ff
        generic map (invert_clock => 0, nb_bits => 32)
        port map (
            clock    => clk_i,
            write_en => '1',
            reset    => rst_i,
            d        => alu_result_s,
            q        => mem_alu_result_s
        );
    
    MEM_OP2_DP: register_ff
        generic map (invert_clock => 0, nb_bits => 32)
        port map (
            clock    => clk_i,
            write_en => '1',
            reset    => rst_i,
            d        => mem_op2_s,
            q        => data_memory_i_s
        );
    
    data_memory_inst: data_memory
        port map (
            clk_i  => clk_i,
            we_i   => mem_we_i,
            re_i   => '1', -- Always read
            add_i  => mem_alu_result_s(7 downto 0),
            d_i    => data_memory_i_s,
            d_o    => data_memory_o_s
        );
    
    -- WB_MEMO_DP: register_ff
    --     generic map (invert_clock => 0, nb_bits => 32)
    --     port map (
    --         clock    => clk_i,
    --         write_en => '1',
    --         reset    => rst_i,
    --         d        => data_memory_o_s,
    --         q        => wb_mem_s
    --     );

    -- WB_ALUO_DP: register_ff
    --     generic map (invert_clock => 0, nb_bits => 32)
    --     port map (
    --         clock    => clk_i,
    --         write_en => '1',
    --         reset    => rst_i,
    --         d        => mem_alu_result_s,
    --         q        => wb_alu_s
    --     );
    
    -- mux_wb: mux2x1
    --     generic map (nb_bits => 32)
    --     port map (
    --         enable   => '1',
    --         sel      => wb_sel_i,
    --         mux_in_0 => wb_mem_s,
    --         mux_in_1 => wb_alu_s,
    --         mux_out  => rd_data_w
    --     );

    mux_wb: mux2x1
        generic map (nb_bits => 32)
        port map (
            enable   => '1',
            sel      => wb_sel_i,
            mux_in_0 => data_memory_o_s,
            mux_in_1 => mem_alu_result_s,
            mux_out  => rd_data_w
        );

end structural;