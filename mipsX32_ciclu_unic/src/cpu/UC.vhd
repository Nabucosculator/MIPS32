
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UC is
    Port (
        Instr : in STD_LOGIC_VECTOR(5 downto 0);         -- Opcode-ul (bits 31..26 din instructiune)
        RegDst : out STD_LOGIC;                          -- 1: selecteaza campul rd ca destinatie (R-type), 0: rt (I-type)
        ExtOp : out STD_LOGIC;                           -- 1: semn-extindere, 0: zero-extindere pentru imediat
        ALUSrc : out STD_LOGIC;                          -- 1: ALU primeste ca input Ext_Imm in loc de RD2
        Branch : out STD_LOGIC;                          -- 1: instructiunea este de tip BEQ (pentru salt conditionat)
        Jump : out STD_LOGIC;                            -- 1: instructiune de tip JUMP
        ALUOp : out STD_LOGIC_VECTOR(2 downto 0);        -- Selectie operatie ALU (decodificare secundara in EX)
        MemWrite : out STD_LOGIC;                        -- 1: activare scriere in memorie
        MemtoReg : out STD_LOGIC;                        -- 1: datele pentru registru vin din memorie
        RegWrite : out STD_LOGIC                          -- 1: activare scriere in registri
    );
end UC;

architecture Behavioral of UC is
begin

    process(Instr)
    begin
        -- Initializare implicita a semnalelor (toate inactive)
        RegDst <= '0'; ExtOp <= '0'; ALUSrc <= '0'; 
        Branch <= '0'; Jump <= '0'; MemWrite <= '0';
        MemtoReg <= '0'; RegWrite <= '0';
        ALUOp <= "000"; -- Default: adunare (ADD)

        case (Instr) is
            -- R-type (opcode = 000000)
            when "000000" =>
                RegDst <= '1';          -- foloseste campul rd
                RegWrite <= '1';        -- scrie rezultatul in registru
                ALUOp <= "010";         -- decodificare functie in EX

            -- ADDI (opcode = 001000)
            when "001000" =>
                ExtOp <= '1';           -- semn-extindere
                ALUSrc <= '1';          -- foloseste valoarea imediata
                RegWrite <= '1';        -- scrie in registru
                ALUOp <= "000";         -- operatie ADD

            -- LW (Load Word) - opcode = 100011
            when "100011" =>
                ExtOp <= '1';           -- semn-extindere
                ALUSrc <= '1';          -- offset din instructiune
                MemtoReg <= '1';        -- valoarea citita din memorie
                RegWrite <= '1';        -- scrie in registru
                ALUOp <= "000";         -- ADD pentru adresa

            -- SW (Store Word) - opcode = 101011
            when "101011" =>
                ExtOp <= '1';           -- semn-extindere
                ALUSrc <= '1';          -- offset din instructiune
                MemWrite <= '1';        -- activare scriere in memorie
                ALUOp <= "000";         -- ADD pentru adresa

            -- BEQ (Branch if Equal) - opcode = 000100
            when "000100" =>
                ExtOp <= '1';           -- semn-extindere pentru offset
                Branch <= '1';          -- activeaza salt conditionat
                ALUOp <= "001";         -- SUB pentru comparare

            -- ANDI - opcode = 001100
            when "001100" =>
                ALUSrc <= '1';          -- foloseste valoarea imediata
                RegWrite <= '1';        -- scrie rezultatul
                ALUOp <= "100";         -- operatie AND

            -- ORI - opcode = 001101
            when "001101" =>
                ALUSrc <= '1';          -- foloseste valoarea imediata
                RegWrite <= '1';        -- scrie rezultatul
                ALUOp <= "011";         -- operatie OR

            -- JUMP - opcode = 000010
            when "000010" =>
                Jump <= '1';            -- activeaza salt neconditionat

            -- Orice altceva (instructiune necunoscuta)
            when others =>
                RegDst <= 'X'; ExtOp <= 'X'; ALUSrc <= 'X'; 
                Branch <= 'X'; Jump <= 'X'; MemWrite <= 'X';
                MemtoReg <= 'X'; RegWrite <= 'X';
                ALUOp <= "XXX";          -- necunoscut
        end case;
    end process;

end Behavioral;
