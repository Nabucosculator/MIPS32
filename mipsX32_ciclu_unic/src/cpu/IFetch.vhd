
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
    Port (
        clk : in STD_LOGIC;                                -- Semnal de ceas
        rst : in STD_LOGIC;                                -- Reset asincron
        en : in STD_LOGIC;                                 -- Semnal de enable pentru actualizarea PC
        BranchAddress : in STD_LOGIC_VECTOR(31 downto 0);  -- Adresa de saritura pentru instructiuni de tip branch
        JumpAddress : in STD_LOGIC_VECTOR(31 downto 0);    -- Adresa pentru instructiuni de tip jump
        Jump : in STD_LOGIC;                               -- Semnal de control: 1 = jump activ
        PCSrc : in STD_LOGIC;                              -- Semnal de control: 1 = branch este luat
        Instruction : out STD_LOGIC_VECTOR(31 downto 0);   -- Instructiunea curenta
        PCp4 : out STD_LOGIC_VECTOR(31 downto 0)           -- Valoarea PC + 4
    );
end IFetch;

architecture Behavioral of IFetch is

    -- ROM: memorie constanta cu instructiuni, 64 locatii a cate 32 de biti
    type tROM is array (0 to 63) of STD_LOGIC_VECTOR(31 downto 0);
    signal ROM : tROM := (
        B"001000_00000_01000_0000000000000000",     -- X"20080000", 00: ADDI $8, $0, 0
        B"001000_00000_10000_0000000000000100",     -- X"20100004", 01: ADDI $16, $0, 4
        B"001000_00000_01010_1111111111111100",     -- X"200AFFFC", 02: ADDI $10, $0, -4
        B"100011_01000_01001_0000000000000000",     -- X"8D290000", 03: LW $9, 0($8)
        B"000000_01001_01010_01011_00000_100100",   -- X"012A5824", 04: AND $11, $9, $10
        B"000000_01001_01011_01100_00000_100010",   -- X"012B6022", 05: SUB $12, $9, $11
        B"001000_00000_01101_0000000000001010",     -- X"200D000A", 06: ADDI $13, $0, 10
        B"000000_01100_01101_01110_00000_100000",   -- X"018D7020", 07: ADD $14, $12, $13
        B"101011_01000_01110_0000000000001000",     -- X"AD0E0008", 08: SW $14, 8($8)
        B"000000_01110_01011_01111_00000_100000",   -- X"01CB7820", 09: ADD $15, $14, $11
        B"101011_01000_01111_0000000000001100",     -- X"AD0F000C", 10: SW $15, 12($8)
        B"000000_01000_10000_01000_00000_100000",   -- X"01084020", 11: ADD $8, $8, $16
        B"000000_01000_10000_10001_00000_101010",   -- X"0110482A", 12: SLT $17, $8, $16
        B"000100_10001_00000_0000000000000001",     -- X"12310001", 13: BEQ $17, $0, +1
        B"000010_00000000000000000000000011",       -- X"08000003", 14: J 3
        B"000010_00000000000000000000001111",       -- X"0800000F", 15: J 15 (loop infinit)
        others => X"00000000"                       -- X"00000000", NOOP (SLL $0, $0, 0)
    );

    -- PC: contorul de program - adresa curenta a instructiunii
    signal PC : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    -- PCAux: valoarea PC + 4
    signal PCAux : STD_LOGIC_VECTOR(31 downto 0);

    -- NextAddr: adresa urmatoarei instructiuni (aleasa din mux)
    signal NextAddr : STD_LOGIC_VECTOR(31 downto 0);

    -- AuxSgn: rezultat intermediar intre PC+4 si BranchAddress
    signal AuxSgn : STD_LOGIC_VECTOR(31 downto 0);

begin

    -- Procesul care actualizeaza PC
    process(clk, rst)
    begin
        if rst = '1' then
            PC <= (others => '0');  -- Reset: seteaza PC la 0
        elsif rising_edge(clk) then
            if en = '1' then
                PC <= NextAddr;     -- Daca enable e activ, trece la urmatoarea instructiune
            end if;
        end if;
    end process;

    -- Scoate instructiunea curenta din ROM
    -- Se foloseste doar PC(6 downto 2) deoarece instructiunile sunt pe 4 octeti
    Instruction <= ROM(conv_integer(PC(6 downto 2)));

    -- Calculeaza PC + 4 (adresa urmatoarei instructiuni in caz normal)
    PCAux <= PC + 4;
    PCp4 <= PCAux;

    -- MUX: alege intre adresa de branch si PC + 4
    AuxSgn <= BranchAddress when PCSrc = '1' else PCAux;

    -- MUX final: alege intre jump si rezultatul anterior
    NextAddr <= JumpAddress when Jump = '1' else AuxSgn;

end Behavioral;
