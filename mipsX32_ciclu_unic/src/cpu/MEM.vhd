library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Declararea entitatii MEM (modulul de memorie de date)
entity MEM is
    port (
        clk : in STD_LOGIC;                              -- Semnalul de ceas
        en : in STD_LOGIC;                               -- Semnal de activare (enable)
        ALUResIn : in STD_LOGIC_VECTOR(31 downto 0);     -- Adresa de memorie calculata de ALU
        RD2 : in STD_LOGIC_VECTOR(31 downto 0);          -- Datele de scris in memorie
        MemWrite : in STD_LOGIC;                         -- Semnal de control pentru scriere
        MemData : out STD_LOGIC_VECTOR(31 downto 0);     -- Datele citite din memorie
        ALUResOut : out STD_LOGIC_VECTOR(31 downto 0)    -- Rezultatul ALU propagat mai departe
    );
end MEM;

architecture Behavioral of MEM is

-- Declararea unei memorii RAM simple cu 64 de locatii a cate 32 de biti
type mem_type is array (0 to 63) of STD_LOGIC_VECTOR(31 downto 0);
signal MEM : mem_type := (
    X"0000000A",  -- MEM[0] = 10
    X"0000000B",  -- MEM[1] = 11
    X"0000000C",  -- MEM[2] = 12
    X"0000000D",  -- MEM[3] = 13
    X"0000000E",  -- MEM[4] = 14
    X"0000000F",  -- MEM[5] = 15
    X"00000009",  -- MEM[6] = 9
    X"00000008",  -- MEM[7] = 8
    others => X"00000000"  -- Toate celelalte locatii initializeaza cu 0
);

begin

    -- Proces pentru scriere in memorie (sincron cu clk)
    process(clk) 			
    begin
        if rising_edge(clk) then
            -- Se scrie doar daca modulul este activat si semnalul MemWrite este activ
            if en = '1' and MemWrite = '1' then
                -- Se scrie in adresa calculata de ALU, folosind biti 7:2 pentru aliniere pe cuvinte de 4 octeti
                MEM(conv_integer(ALUResIn(7 downto 2))) <= RD2;
            end if;
        end if;
    end process;

    -- Citirea din memorie este continua (combinatorie)
    MemData <= MEM(conv_integer(ALUResIn(7 downto 2)));

    -- ALUResOut propaga rezultatul ALU neschimbat
    ALUResOut <= ALUResIn;

end Behavioral;
