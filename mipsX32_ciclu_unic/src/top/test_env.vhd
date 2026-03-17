
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_env is
    Port (
        clk : in STD_LOGIC;                      -- semnal de ceas global
        btn : in STD_LOGIC_VECTOR (4 downto 0);  -- butoane externe (btn(0)=enable, btn(1)=reset)
        sw : in STD_LOGIC_VECTOR (15 downto 0);  -- switch-uri pentru selectie afisaj
        led : out STD_LOGIC_VECTOR (15 downto 0);-- iesire catre leduri
        an : out STD_LOGIC_VECTOR (7 downto 0);  -- anodo pentru afisaj 7 segmente
        cat : out STD_LOGIC_VECTOR (6 downto 0)  -- catod pentru afisaj 7 segmente
    );
end test_env;

architecture Behavioral of test_env is

-- Declararea componentelor
component MPG is
    Port (
        enable : out STD_LOGIC; -- semnal activat pe un singur ciclu cand se apasa un buton
        btn : in STD_LOGIC;
        clk : in STD_LOGIC
    );
end component;

component SSD is
    Port (
        clk : in STD_LOGIC;
        digits : in STD_LOGIC_VECTOR(31 downto 0); -- datele afisate pe SSD
        an : out STD_LOGIC_VECTOR(7 downto 0);
        cat : out STD_LOGIC_VECTOR(6 downto 0)
    );
end component;

component IFetch
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        en : in STD_LOGIC;
        BranchAddress : in STD_LOGIC_VECTOR(31 downto 0); -- adresa de salt (BEQ)
        JumpAddress : in STD_LOGIC_VECTOR(31 downto 0);   -- adresa de saritura (J)
        Jump : in STD_LOGIC;
        PCSrc : in STD_LOGIC;                             -- selecteaza adresa noua: branch sau secvential
        Instruction : out STD_LOGIC_VECTOR(31 downto 0);  -- instructiunea citita
        PCp4 : out STD_LOGIC_VECTOR(31 downto 0)          -- PC + 4 (adresa urmatoarei instructiuni)
    );
end component;

component ID
    Port (
        clk : in STD_LOGIC;
        en : in STD_LOGIC;
        Instr : in STD_LOGIC_VECTOR(25 downto 0);         -- partea de jos a instructiunii
        WD : in STD_LOGIC_VECTOR(31 downto 0);            -- valoarea ce trebuie scrisa in registri
        RegWrite : in STD_LOGIC;                          -- semnal de control pentru scriere
        RegDst : in STD_LOGIC;                            -- selecteaza registrul tinta (rd/rt)
        ExtOp : in STD_LOGIC;                             -- semnal de extensie semn
        RD1 : out STD_LOGIC_VECTOR(31 downto 0);          -- iesire registru sursa 1
        RD2 : out STD_LOGIC_VECTOR(31 downto 0);          -- iesire registru sursa 2
        Ext_Imm : out STD_LOGIC_VECTOR(31 downto 0);      -- valoare immediate extinsa
        func : out STD_LOGIC_VECTOR(5 downto 0);          -- functia pentru instructiunile R
        sa : out STD_LOGIC_VECTOR(4 downto 0)             -- shift amount
    );
end component;

component UC
    Port (
        Instr : in STD_LOGIC_VECTOR(5 downto 0);          -- opcode
        RegDst : out STD_LOGIC;
        ExtOp : out STD_LOGIC;
        ALUSrc : out STD_LOGIC;
        Branch : out STD_LOGIC;
        Jump : out STD_LOGIC;
        ALUOp : out STD_LOGIC_VECTOR(2 downto 0);
        MemWrite : out STD_LOGIC;
        MemtoReg : out STD_LOGIC;
        RegWrite : out STD_LOGIC
    );
end component;

component EX is
    Port (
        PCp4 : in STD_LOGIC_VECTOR(31 downto 0);          -- PC+4 din IF
        RD1 : in STD_LOGIC_VECTOR(31 downto 0);           -- operand ALU 1
        RD2 : in STD_LOGIC_VECTOR(31 downto 0);           -- operand ALU 2
        Ext_Imm : in STD_LOGIC_VECTOR(31 downto 0);       -- valoare immediate extinsa
        func : in STD_LOGIC_VECTOR(5 downto 0);
        sa : in STD_LOGIC_VECTOR(4 downto 0);
        ALUSrc : in STD_LOGIC;                            -- selecteaza operand ALU 2: RD2 sau Imm
        ALUOp : in STD_LOGIC_VECTOR(2 downto 0);
        BranchAddress : out STD_LOGIC_VECTOR(31 downto 0);-- adresa pentru branch
        ALURes : out STD_LOGIC_VECTOR(31 downto 0);       -- rezultat ALU
        Zero : out STD_LOGIC                              -- semnal Zero (pentru instructiuni de salt conditionat)
    );
end component;

component MEM
    Port (
        clk : in STD_LOGIC;
        en : in STD_LOGIC;
        ALUResIn : in STD_LOGIC_VECTOR(31 downto 0);      -- adresa folosita pentru memorie
        RD2 : in STD_LOGIC_VECTOR(31 downto 0);           -- valoarea ce poate fi scrisa
        MemWrite : in STD_LOGIC;
        MemData : out STD_LOGIC_VECTOR(31 downto 0);      -- valoare citita din memorie
        ALUResOut : out STD_LOGIC_VECTOR(31 downto 0)     -- ALURes propagata mai departe
    );
end component;

-- Declarare semnale interne
signal Instruction, PCp4, RD1, RD2, WD, Ext_imm : STD_LOGIC_VECTOR(31 downto 0);
signal JumpAddress, BranchAddress, ALURes, ALURes1, MemData : STD_LOGIC_VECTOR(31 downto 0);
signal func : STD_LOGIC_VECTOR(5 downto 0);
signal sa : STD_LOGIC_VECTOR(4 downto 0);
signal zero : STD_LOGIC;
signal digits : STD_LOGIC_VECTOR(31 downto 0);
signal en, rst, PCSrc : STD_LOGIC;

-- Semnale de control
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR(2 downto 0);

begin

    -- Generator de impuls (MPG) pentru buton enable
    Q1 : MPG port map(en, btn(0), clk);

    -- Modul IFetch: citeste instructiunea din ROM si genereaza PC+4
    Q2 : IFetch port map(clk, btn(1), en, BranchAddress, JumpAddress, Jump, PCSrc, Instruction, PCp4);

    -- Modul ID: decodifica instructiunea si citeste valorile din registri
    Q3 : ID port map(clk, en, Instruction(25 downto 0), WD, RegWrite, RegDst, ExtOp, RD1, RD2, Ext_imm, func, sa);

    -- Unitatea de control: genereaza semnale de control in functie de opcode
    Q4 : UC port map(Instruction(31 downto 26), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite);

    -- Modul EX: executa instructiunea (ALU)
    Q5 : EX port map(PCp4, RD1, RD2, Ext_imm, func, sa, ALUSrc, ALUOp, BranchAddress, ALURes, Zero); 

    -- Modul MEM: citeste/scrie in memorie in functie de instructiune
    Q6 : MEM port map(clk, en, ALURes, RD2, MemWrite, MemData, ALURes1);

    -- Etapa de Write-Back: selecteaza ce valoare se scrie in registri
    WD <= MemData when MemtoReg = '1' else ALURes1;

    -- Selectia adresei urmatoare: branch
    PCSrc <= Zero and Branch;

    -- Calcularea adresei pentru instructiunea JUMP
    JumpAddress <= PCp4(31 downto 28) & Instruction(25 downto 0) & "00";

    -- Afisaj pe SSD in functie de switch-uri
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

    Q7 : SSD port map(clk, digits, an, cat);

    -- LED-urile reflecta starea semnalelor de control principale
    led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;

end Behavioral;
