----------------------------------------------------------------------------------
-- Company: Technical University of Cluj-Napoca 
-- Engineer: Cristian Vancea
-- 
-- Module Name: test_env - Behavioral
-- Description: 
--      MIPS 32, single-cycle
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

component SSD is
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component IFetch
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           en : in STD_LOGIC;
           BranchAddress : in STD_LOGIC_VECTOR(31 downto 0);
           JumpAddress : in STD_LOGIC_VECTOR(31 downto 0);
           Jump : in STD_LOGIC;
           PCSrc : in STD_LOGIC;
           Instruction : out STD_LOGIC_VECTOR(31 downto 0);
           PCp4 : out STD_LOGIC_VECTOR(31 downto 0));
end component;

component ID
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;    
           Instr : in STD_LOGIC_VECTOR(25 downto 0);
           WD : in STD_LOGIC_VECTOR(31 downto 0);
           WA : in STD_LOGIC_VECTOR(4 downto 0);
           RegWrite : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           RD1 : out STD_LOGIC_VECTOR(31 downto 0);
           RD2 : out STD_LOGIC_VECTOR(31 downto 0);
           Ext_Imm : out STD_LOGIC_VECTOR(31 downto 0);
           func : out STD_LOGIC_VECTOR(5 downto 0);
           sa : out STD_LOGIC_VECTOR(4 downto 0);
           rt : out STD_LOGIC_VECTOR(4 downto 0);--
           rd : out STD_LOGIC_VECTOR(4 downto 0)--
           );
end component;

component UC
    Port ( Instr : in STD_LOGIC_VECTOR(5 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Jump : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR(2 downto 0);
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC);
end component;

component EX is
    Port ( PCp4 : in STD_LOGIC_VECTOR(31 downto 0);
           RD1 : in STD_LOGIC_VECTOR(31 downto 0);
           RD2 : in STD_LOGIC_VECTOR(31 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR(31 downto 0);
           func : in STD_LOGIC_VECTOR(5 downto 0);
           sa : in STD_LOGIC_VECTOR(4 downto 0);
           ALUSrc : in STD_LOGIC;
           ALUOp : in STD_LOGIC_VECTOR(2 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR(31 downto 0);
           ALURes : out STD_LOGIC_VECTOR(31 downto 0);
           Zero : out STD_LOGIC;
           rt : in STD_LOGIC_VECTOR(4 downto 0);--
           rd : in STD_LOGIC_VECTOR(4 downto 0);--
           RegDst : in STD_LOGIC;--
           rWA : out STD_LOGIC_VECTOR(4 downto 0)--
           );
end component;

component MEM
    port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           ALUResIn : in STD_LOGIC_VECTOR(31 downto 0);
           RD2 : in STD_LOGIC_VECTOR(31 downto 0);
           MemWrite : in STD_LOGIC;			
           MemData : out STD_LOGIC_VECTOR(31 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR(31 downto 0));
end component;

signal Instruction, PCp4, RD1, RD2, WD, Ext_imm : STD_LOGIC_VECTOR(31 downto 0); 
signal JumpAddress, BranchAddress, ALURes, ALURes1, MemData : STD_LOGIC_VECTOR(31 downto 0);
signal func : STD_LOGIC_VECTOR(5 downto 0);
signal sa : STD_LOGIC_VECTOR(4 downto 0);
signal zero : STD_LOGIC;
signal digits : STD_LOGIC_VECTOR(31 downto 0);
signal en, rst, PCSrc : STD_LOGIC; 
-- main controls 
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR(2 downto 0);

--pipeline
signal rt_ID, rd_ID : STD_LOGIC_VECTOR(4 downto 0);--
signal IFID_Instruction : STD_LOGIC_VECTOR(31 downto 0);--
signal IFID_PCp4       : STD_LOGIC_VECTOR(31 downto 0);--

signal RegDst_IDEX, Branch_IDEX, RegWrite_IDEX : STD_LOGIC;--
signal RD1_IDEX, RD2_IDEX, ExtImm_IDEX : STD_LOGIC_VECTOR(31 downto 0);--
signal func_IDEX : STD_LOGIC_VECTOR(5 downto 0);--
signal sa_IDEX : STD_LOGIC_VECTOR(4 downto 0);--
signal rt_IDEX, rd_IDEX : STD_LOGIC_VECTOR(4 downto 0);--
signal PCp4_IDEX : STD_LOGIC_VECTOR(31 downto 0);--
signal MemtoReg_IDEX   : STD_LOGIC;--
signal ALUOp_IDEX : STD_LOGIC_VECTOR(2 downto 0);--
signal ALUSrc_IDEX : STD_LOGIC;--
signal MemWrite_IDEX : STD_LOGIC;
signal rWA_EX : STD_LOGIC_VECTOR(4 downto 0);--

signal RegWrite_EXMEM : STD_LOGIC;--
signal Branch_EXMEM : STD_LOGIC;--
signal Zero_EXMEM : STD_LOGIC;--
signal MemtoReg_EXMEM  : STD_LOGIC;--
signal BranchAddress_EXMEM : STD_LOGIC_VECTOR(31 downto 0);--
signal ALURes_EXMEM : STD_LOGIC_VECTOR(31 downto 0);--
signal RD2_EXMEM : STD_LOGIC_VECTOR(31 downto 0);--
signal WA_EXMEM : STD_LOGIC_VECTOR(4 downto 0);--
signal MemWrite_EXMEM : STD_LOGIC;--


signal RegWrite_MEMWB : STD_LOGIC;--
signal WA_MEMWB : STD_LOGIC_VECTOR(4 downto 0);--
signal ALURes_MEMWB : STD_LOGIC_VECTOR(31 downto 0);--
signal MemData_MEMWB : STD_LOGIC_VECTOR(31 downto 0);--
signal MemtoReg_MEMWB : STD_LOGIC;--

begin

    monopulse : MPG port map(en, btn(0), clk);
    
    -- main units
    inst_IFetch : IFetch port map(clk, btn(1), en, BranchAddress_EXMEM, JumpAddress, Jump, PCSrc, Instruction, PCp4);
    
    -- IF/ID Pipeline Register
    process(clk)
    begin
        if falling_edge(clk) then
            if en = '1' then
                IFID_Instruction <= Instruction;
                IFID_PCp4 <= PCp4;
            end if;
        end if;
    end process;

    inst_ID : ID port map(clk, en, IFID_Instruction(25 downto 0), WD, WA_MEMWB, RegWrite_MEMWB, ExtOp, RD1, RD2, Ext_imm, func, sa, rt_ID, rd_ID);
    inst_UC : UC port map(IFID_Instruction(31 downto 26), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite);
    
    --ID/EX Pipeline Register
    process(clk)
    begin
        if falling_edge(clk) then
            if en = '1' then
                RegDst_IDEX <= RegDst;
                Branch_IDEX <= Branch;--
                RegWrite_IDEX <= RegWrite;--
                RD1_IDEX <= RD1;
                RD2_IDEX <= RD2;
                ExtImm_IDEX <= Ext_Imm;
                func_IDEX <= func;
                sa_IDEX <= sa;
                rt_IDEX <= rt_ID;
                rd_IDEX <= rd_ID;
                PCp4_IDEX <= IFID_PCp4;
                MemtoReg_IDEX <= MemtoReg;
                ALUOp_IDEX <= ALUOp;
                ALUSrc_IDEX <= ALUSrc;
                MemWrite_IDEX <= MemWrite;
            end if;
        end if;
    end process;
    
    inst_EX : EX port map(PCp4_IDEX, RD1_IDEX, RD2_IDEX, ExtImm_IDEX, func_IDEX, sa_IDEX, ALUSrc_IDEX, ALUOp_IDEX, BranchAddress, ALURes, Zero, rt_IDEX, rd_IDEX, RegDst_IDEX, rWA_EX); 
    
    --EX/MEM Pipeline Register
    process(clk)
    begin
        if falling_edge(clk) then
            if en = '1' then
                RegWrite_EXMEM <= RegWrite_IDEX;
                Branch_EXMEM <= Branch_IDEX;
                Zero_EXMEM <= Zero;
                BranchAddress_EXMEM <= BranchAddress;
                ALURes_EXMEM <= ALURes;
                RD2_EXMEM <= RD2_IDEX;
                WA_EXMEM <= rWA_EX;
                PCSrc <= Branch_EXMEM and Zero_EXMEM;
                MemtoReg_EXMEM <= MemtoReg_IDEX;
                MemWrite_EXMEM <= MemWrite_IDEX;
            end if;
        end if;
    end process;

    inst_MEM : MEM port map(clk, en, ALURes_EXMEM, RD2_EXMEM, MemWrite_EXMEM, MemData, ALURes1);
    
    process(clk)
    begin
        if falling_edge(clk) then
            if en = '1' then
                RegWrite_MEMWB <= RegWrite_EXMEM;
                WA_MEMWB <= WA_EXMEM;
                ALURes_MEMWB <= ALURes1;
                MemData_MEMWB <= MemData;
                MemtoReg_MEMWB <= MemtoReg_EXMEM;
            end if;
        end if;
    end process;

    -- Write-Back unit 
    WD <= MemData_MEMWB when MemtoReg_MEMWB = '1' else ALURes_MEMWB; 

    -- jump address
    JumpAddress <= IFID_PCp4(31 downto 28) & IFID_Instruction(25 downto 0) & "00";

   -- SSD display MUX
    with sw(7 downto 5) select
        digits <=  Instruction when "000", 
                   PCp4 when "001",
                   RD1 when "010",
                   RD2 when "011",
                   Ext_Imm when "100",
                   ALURes when "101",
                   MemData when "110",
                   WD when "111",
                   (others => 'X') when others; 

    display : SSD port map(clk, digits, an, cat);
    
    -- main controls on the leds
    led(10 downto 0) <= ALUOp_IDEX & RegDst_IDEX & ExtOp & 	ALUSrc_IDEX & Branch_EXMEM & Jump & MemWrite_EXMEM & MemtoReg_MEMWB & RegWrite_MEMWB;
    
end Behavioral;