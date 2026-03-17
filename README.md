# Procesor MIPS32 pe FPGA – Single-Cycle și Pipeline

Acest repository conține două implementări ale unui **procesor MIPS32 scris în VHDL**:

- **MIPS Single-Cycle**
- **MIPS Pipeline**

Proiectul este realizat pentru rulare pe **FPGA** și permite observarea funcționării interne a procesorului folosind **SSD (7-segment display), LED-uri, switch-uri și butoane**.

Scopul proiectului este de a demonstra **arhitectura unui procesor MIPS** și de a compara două implementări clasice:

- execuție **single-cycle**
- execuție **pipeline**


---

# Problema rezolvată

Procesorul execută un program MIPS care procesează **două valori din memorie**.

Valorile sunt citite din:

- `mem[0]`
- `mem[4]`

Pentru fiecare valoare se execută următorii pași:

1. Se determină **cel mai apropiat multiplu de 4 mai mic sau egal** cu numărul.
2. Se calculează **corecția**:

```
corectie = numar - multiplu_de_4
```

3. Se adaugă un **offset fix de 10**:

```
corectie_finala = corectie + 10
```

4. Se scriu rezultatele în memorie:
   - corecția finală
   - rezultatul final

La final programul intră într-o **buclă infinită**, oprind avansarea execuției.


---

# Programul MIPS executat

```asm
00: ADDI $8, $0, 0
01: ADDI $16, $0, 4
02: ADDI $10, $0, -4
03: LW   $9, 0($8)
04: AND  $11, $9, $10
05: SUB  $12, $9, $11
06: ADDI $13, $0, 10
07: ADD  $14, $12, $13
08: SW   $14, 8($8)
09: ADD  $15, $14, $11
10: SW   $15, 12($8)
11: ADD  $8, $8, $16
12: SLT  $17, $8, $16
13: BEQ  $17, $0, 15
14: J    3
15: J    15
```


---

# Arhitecturi implementate

## 1. MIPS Single-Cycle

În această versiune **fiecare instrucțiune este executată într-un singur ciclu de ceas**.

Etape principale:

- IF – Instruction Fetch
- ID – Instruction Decode
- EX – Execute
- MEM – Memory Access
- WB – Write Back

Caracteristici:

- design simplu
- ușor de înțeles și de debug
- toate etapele se execută într-un singur ciclu
- perioada de ceas este mai mare


---

## 2. MIPS Pipeline

În această versiune execuția este **împărțită în etape**, iar mai multe instrucțiuni pot fi executate **în paralel**.

Etapele pipeline:

- IF
- ID
- EX
- MEM
- WB

Caracteristici:

- performanță mai mare
- execuție paralelă a instrucțiunilor
- structură hardware mai complexă
- necesită registre de pipeline


---

# Comparație

| Caracteristică | Single-Cycle | Pipeline |
|---|---|---|
| Execuție instrucțiuni | 1 ciclu / instrucțiune | instrucțiuni suprapuse |
| Complexitate | mică | mai mare |
| Perioadă de ceas | mare | mai mică |
| Performanță | mai mică | mai mare |
| Ușurință debugging | ridicată | mai dificilă |


---

# Interacțiunea cu FPGA

Proiectul permite observarea execuției procesorului în timp real:

**SSD (7-segment display)**  
afișează diferite semnale interne

**Switch-uri**  
selectează valoarea afișată

**LED-uri**  
arată semnalele de control ale procesorului

**Buton + MPG**  
permite avansarea execuției pas cu pas


---

# Structura repository

```
docs/            documentație și explicații
assembly/        programul MIPS
src/             implementarea VHDL a procesorului
constraints/     maparea pinilor FPGA
diagrams/        diagrame arhitecturale
```


---

# Tehnologii utilizate

- VHDL
- Vivado
- FPGA (Nexys / similar)
- arhitectura MIPS32
- SSD / LED debugging


---

# Scop educațional

Acest proiect demonstrează:

- proiectarea unui procesor
- implementarea datapath + unitate de control
- diferențele dintre arhitectura **single-cycle** și **pipeline**
- implementare hardware pe FPGA

Este un proiect potrivit pentru **portofoliu în domeniul embedded systems, digital design și computer architecture**.
