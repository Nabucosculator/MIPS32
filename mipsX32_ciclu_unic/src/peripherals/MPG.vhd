
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MPG is
    Port ( 
        enable : out STD_LOGIC; -- semnal de iesire: activ pe un singur ciclu la apasarea butonului
        btn : in STD_LOGIC;     -- intrare: butonul fizic apasat
        clk : in STD_LOGIC      -- semnal de ceas
    );
end MPG;

architecture Behavioral of MPG is

-- Contor folosit pentru debounce: numara pana la o valoare mare
signal cnt_int : STD_LOGIC_VECTOR(17 downto 0) := (others => '0');

-- Registri interni pentru sincronizarea semnalului de buton
signal Q1, Q2, Q3 : STD_LOGIC;

begin

    -- Generare semnal "enable": se activeaza doar atunci cand detectam o tranzitie de la 0 la 1 pe buton
    -- Aceasta expresie detecteaza "frontul" (rising edge) pe semnalul sincronizat
    enable <= Q2 and (not Q3);

    -- Proces 1: incrementeaza contorul la fiecare ciclu de ceas
    -- Contorul este folosit pentru a implementa un delay (debounce) in citirea butonului
    process(clk)
    begin
        if clk'event and clk='1' then
            cnt_int <= cnt_int + 1;
        end if;
    end process;

    -- Proces 2: sincronizare buton la intervale mari (cand contorul este maxim)
    -- Aceasta logica reduce efectul de bouncing (semnale fluctuante cand apasam un buton fizic)
    process(clk)
    begin
        if clk'event and clk='1' then
            if cnt_int(17 downto 0) = "111111111111111111" then -- daca contorul a ajuns la maxim
                Q1 <= btn; -- butonul este salvat doar la acest moment
            end if;
        end if;
    end process;

    -- Proces 3: registri de sincronizare in lant (3 flip-flopuri)
    -- Se foloseste pentru detectia tranzitiei "0->1" a semnalului de buton
    process(clk)
    begin
        if clk'event and clk='1' then
            Q2 <= Q1; -- salveaza starea curenta a butonului
            Q3 <= Q2; -- salveaza starea anterioara
        end if;
    end process;

end Behavioral;
