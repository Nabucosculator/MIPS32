
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ID is
    Port (
        clk : in STD_LOGIC;                        -- Semnal de ceas
        en : in STD_LOGIC;                         -- Semnal de enable pentru scriere
        Instr : in STD_LOGIC_VECTOR(25 downto 0);  -- Parte din instructiune (fara opcode)
        WD : in STD_LOGIC_VECTOR(31 downto 0);     -- Datele care trebuie scrise in registru
        RegWrite : in STD_LOGIC;                   -- Semnal de control: activeaza scrierea in registru
        RegDst : in STD_LOGIC;                     -- Selecteaza intre campul rd si rt ca adresa de destinatie
        ExtOp : in STD_LOGIC;                      -- Selecteaza tipul extensiei (semn/zero) pentru immediate
        RD1 : out STD_LOGIC_VECTOR(31 downto 0);   -- Date citite din registrul rs
        RD2 : out STD_LOGIC_VECTOR(31 downto 0);   -- Date citite din registrul rt
        Ext_Imm : out STD_LOGIC_VECTOR(31 downto 0); -- Valoarea immediate extinsa pe 32 de biti
        func : out STD_LOGIC_VECTOR(5 downto 0);   -- Codul functiei (pentru instructiuni R-type)
        sa : out STD_LOGIC_VECTOR(4 downto 0)      -- Shift amount (pentru instructiuni de deplasare)
    );
end ID;

architecture Behavioral of ID is

    -- Declarare registri: 32 de registre pe 32 biti
    type reg_array is array(0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal reg_file : reg_array := (others => X"00000000");

    -- Adresa destinatie pentru scriere (aleasa cu ajutorul RegDst)
    signal WriteAddress: STD_LOGIC_VECTOR(4 downto 0);

begin

    -- Selectie adresa de scriere: daca RegDst = 1 -> rd (Instr(15:11)), altfel rt (Instr(20:16))
    WriteAddress <= Instr(15 downto 11) when RegDst = '1' else Instr(20 downto 16);

    -- Proces de scriere in registri
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' and RegWrite = '1' then
                -- Scrierea valorii WD in registrul specificat de WriteAddress
                reg_file(conv_integer(WriteAddress)) <= WD;
            end if;
        end if;
    end process;

    -- Citirea din registri:
    -- RD1 preia continutul registrului rs (Instr(25:21))
    -- RD2 preia continutul registrului rt (Instr(20:16))
    RD1 <= reg_file(conv_integer(Instr(25 downto 21))); -- rs
    RD2 <= reg_file(conv_integer(Instr(20 downto 16))); -- rt

    -- Extinderea valorii immediate (Instr(15:0)) la 32 de biti
    -- Daca ExtOp = 1 => semn-extindere (completeaza cu bitul de semn)
    -- Daca ExtOp = 0 => zero-extindere
    Ext_Imm(15 downto 0) <= Instr(15 downto 0);
    Ext_Imm(31 downto 16) <= (others => Instr(15)) when ExtOp = '1' else (others => '0');

    -- Valoarea shift amount pentru instructiuni de deplasare
    sa <= Instr(10 downto 6);

    -- Codul functiei pentru instructiuni R-type
    func <= Instr(5 downto 0);

end Behavioral;
