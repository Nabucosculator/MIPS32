# MIPS32 FPGA Processor - Single-Cycle & Pipeline

This repository contains two FPGA implementations of a **MIPS32 processor** written in **VHDL**:

- **Single-Cycle MIPS**
- **Pipelined MIPS**

Both versions are designed for educational use and hardware demonstration on FPGA, with support for step-by-step execution, signal inspection, and debugging through **SSD**, **LEDs**, **switches**, and control buttons.

---

## Project Overview

The project was built to compare two classic processor architectures:

- a **single-cycle design**, where each instruction is completed in one clock cycle
- a **pipeline design**, where instruction execution is split into stages and multiple instructions can overlap in execution

The goal is to show both the **functional behavior** of a MIPS32 processor and the **architectural differences** between the two implementations.

---

## Problem Solved by the Program

Both processors execute a MIPS program that processes two numbers stored in memory.

For each value:

1. the closest multiple of 4 less than or equal to the number is computed
2. the correction is determined as the difference between the number and that multiple
3. a fixed offset of **10** is added
4. the correction and final result are written back to memory

At the end, the processor enters an infinite loop.

### MIPS program

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

## Architectures Included

### 1. Single-Cycle MIPS
Main modules:
- `IFetch`
- `ID`
- `EX`
- `MEM`
- `UC`
- `test_env`

Characteristics:
- simple control flow
- easier to understand and debug
- one instruction completes in one full cycle
- longer clock period because all stages are traversed in the same cycle

### 2. Pipeline MIPS
Main idea:
- instruction execution is split into stages
- instructions advance in parallel through the pipeline
- improves throughput compared to the single-cycle version

Typical stages:
- IF
- ID
- EX
- MEM
- WB

Characteristics:
- better performance
- more efficient instruction flow
- more complex control and datapath organization
- useful for understanding pipeline registers and execution overlap

---

## Comparison

| Feature | Single-Cycle | Pipeline |
|---|---|---|
| Instruction execution | One full cycle per instruction | Multiple overlapped stages |
| Complexity | Lower | Higher |
| Clock period | Longer | Shorter |
| Throughput | Lower | Higher |
| Debugging | Easier | More complex |
| Educational value | Great for basics | Great for advanced architecture concepts |

---

## FPGA Interaction

The designs are intended for FPGA demonstration and debugging.

Available hardware interaction:
- **SSD** for displaying internal values
- **LEDs** for control signals
- **Switches** for selecting displayed signals
- **Button + MPG** for controlled stepping

This makes it possible to observe how instructions move through the processor and how internal signals change during execution.

---

## Repository Structure

```text
docs/            project notes, screenshots, explanations
assembly/        MIPS assembly program
src/             VHDL source files
constraints/     FPGA constraints file
diagrams/        architecture and pipeline diagrams
```

---

## Technologies Used

- **VHDL**
- **Vivado**
- **FPGA board constraints**
- **MIPS32 architecture**
- **7-segment display / LED debug interface**

---

## Why this project matters

This project highlights:
- digital design skills
- computer architecture fundamentals
- FPGA implementation experience
- datapath and control unit design
- architectural comparison between single-cycle and pipelined processors

It is a strong academic and portfolio project for embedded systems, digital design, and hardware-oriented roles.
