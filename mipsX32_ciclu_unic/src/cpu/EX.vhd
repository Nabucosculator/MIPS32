library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.ALL;
--use IEEE.std_logic_arith.ALL;

entity EX is
    Port ( 
        PCp4 : in STD_LOGIC_VECTOR(31 downto 0);         -- Adresa curenta a PC + 4
        RD1 : in STD_LOGIC_VECTOR(31 downto 0);          -- Valoare citita din registrul rs
        RD2 : in STD_LOGIC_VECTOR(31 downto 0);          -- Valoare citita din registrul rt
        Ext_Imm : in STD_LOGIC_VECTOR(31 downto 0);      -- Valoarea imediata extinsa
        func : in STD_LOGIC_VECTOR(5 downto 0);          -- Campul funct din instructiune (R-type)
        sa : in STD_LOGIC_VECTOR(4 downto 0);            -- Shamt: numar de biti pentru shift
        ALUSrc : in STD_LOGIC;                           -- Selecteaza intre RD2 si Ext_Imm pentru ALU
        ALUOp : in STD_LOGIC_VECTOR(2 downto 0);         -- Cod operatie din UC
        BranchAddress : out STD_LOGIC_VECTOR(31 downto 0); -- Adresa de salt pentru branch
        ALURes : out STD_LOGIC_VECTOR(31 downto 0);      -- Rezultatul operatiei ALU
        Zero : out STD_LOGIC                             -- 1 daca rezultatul este 0
    );
end EX;

architecture Behavioral of EX is

-- Semnale interne pentru operanzii ALU si rezultat
signal A, B, C : STD_LOGIC_VECTOR(31 downto 0);
signal ALUCtrl : STD_LOGIC_VECTOR(2 downto 0); -- Codul de control pentru ALU

begin

    -- Selectarea operatiei ALU in functie de ALUOp si funct
    process(ALUOp, func)
    begin
        case ALUOp is
            when "010" => -- Instructiuni R-type
                case func is
                    when "100000" => ALUCtrl <= "000"; -- ADD
                    when "100010" => ALUCtrl <= "100"; -- SUB
                    when "000000" => ALUCtrl <= "011"; -- SLL
                    when "000010" => ALUCtrl <= "101"; -- SRL
                    when "100100" => ALUCtrl <= "001"; -- AND
                    when "100101" => ALUCtrl <= "010"; -- OR
                    when "100110" => ALUCtrl <= "110"; -- XOR
                    when "101010" => ALUCtrl <= "111"; -- SLT
                    when others => ALUCtrl <= (others => 'X'); -- Necunoscuta
                end case;
            when "000" => ALUCtrl <= "000"; -- Operatie implicita: ADD
            when "001" => ALUCtrl <= "100"; -- BEQ: SUB pentru comparare
            when "100" => ALUCtrl <= "001"; -- ANDI
            when "011" => ALUCtrl <= "010"; -- ORI
            when others => ALUCtrl <= (others => 'X'); -- Necunoscuta
        end case;
    end process;

    -- Selectia operanzilor pentru ALU
    A <= RD1;                                         -- Operand A = valoare din rs
    B <= Ext_Imm when ALUSrc = '1' else RD2;          -- Operand B = Ext_Imm (daca ALUSrc = 1) sau RD2

    -- Executia efectiva a operatiei ALU
    process(ALUCtrl, A, B, sa)
    begin
        case ALUCtrl is
            when "000" => C <= A + B;                                  -- ADD
            when "100" => C <= A - B;                                  -- SUB
            when "011" => C <= to_stdlogicvector(to_bitvector(B) sll conv_integer(sa)); -- SLL
            when "101" => C <= to_stdlogicvector(to_bitvector(B) srl conv_integer(sa)); -- SRL
            when "001" => C <= A and B;                                -- AND
            when "010" => C <= A or B;                                 -- OR
            when "110" => C <= A xor B;                                -- XOR
            when "111" =>                                            -- SLT
                if signed(A) < signed(B) then
                    C <= X"00000001";
                else
                    C <= X"00000000";
                end if;
            when others => C <= (others => 'X');                       -- Necunoscut
        end case;
    end process;

    -- Detectarea rezultatului zero
    Zero <= '1' when C = X"00000000" else '0';

    -- Rezultatul operatiei ALU
    ALURes <= C;

    -- Calcularea adresei pentru branch (PC + offset * 4)
    BranchAddress <= PCp4 + (Ext_Imm(29 downto 0) & "00");

end Behavioral;
