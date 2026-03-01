# Carry Lookahead Adder (CLA) | CLA Generator (Verilog)

A Verilog implementation of a **4-bit Carry Lookahead Adder (CLA)** using generate (G) and propagate (P) logic, developed with the Vivado IDE. This document explains the theory behind carry lookahead versus ripple-carry addition, derives the carry and sum equations, presents the truth table and Boolean logic, and summarizes the circuit, waveform, and simulation results.

---

## Table of Contents

- [What Is a Carry Lookahead Adder?](#what-is-a-carry-lookahead-adder)
- [CLA Theory: Why Lookahead?](#cla-theory-why-lookahead)
- [Carry Output: Truth Table and Derivation](#carry-output-truth-table-and-derivation)
- [Carry Lookahead Equations (General Case)](#carry-lookahead-equations-general-case)
- [4-Bit CLA Logic and Boolean Equations](#4-bit-cla-logic-and-boolean-equations)
- [Learning Resources](#learning-resources)
- [Circuit Diagram](#circuit-diagram)
- [Waveform Diagram](#waveform-diagram)
- [Testbench Output](#testbench-output)
- [Running the Project in Vivado](#running-the-project-in-vivado)
- [Project Files](#project-files)

---

## What Is a Carry Lookahead Adder?

A **Carry Lookahead Adder (CLA)** is a combinational circuit that **adds two n-bit binary numbers** (here, 4-bit) **plus a carry-in** and produces an **n-bit sum** and a **carry-out**. It is similar to a chain of full adders but is **much faster** because it computes carry signals in parallel instead of waiting for the previous stage.

- **Inputs**
  - **A** = A<sub>3</sub>A<sub>2</sub>A<sub>1</sub>A<sub>0</sub> (first 4-bit number; A<sub>3</sub> = MSB, A<sub>0</sub> = LSB).
  - **B** = B<sub>3</sub>B<sub>2</sub>B<sub>1</sub>B<sub>0</sub> (second 4-bit number; B<sub>3</sub> = MSB, B<sub>0</sub> = LSB).
  - **C<sub>in</sub>** (carry-in, often 0).
- **Outputs**
  - **S** = S<sub>3</sub>S<sub>2</sub>S<sub>1</sub>S<sub>0</sub> (4-bit sum; S<sub>3</sub> = MSB, S<sub>0</sub> = LSB).
  - **C<sub>o</sub>** (carry-out).

The circuit computes **A + B + C<sub>in</sub>** and produces **S** and **C<sub>o</sub>**. The implementation uses **carry generate (G)** and **carry propagate (P)** terms so that all carry bits (C<sub>0</sub>, C<sub>1</sub>, C<sub>2</sub>, C<sub>3</sub>) can be derived in parallel from A, B, and C<sub>in</sub>, then the sum bits are computed with XOR gates.

---

## CLA Theory: Why Lookahead?

The main difference between a **full-adder chain** (ripple-carry) and a **carry lookahead adder** is **propagation delay**:

| Adder type        | How carry is obtained                          | Delay behavior                          |
|-------------------|------------------------------------------------|-----------------------------------------|
| **Ripple-carry**  | Each stage needs the carry from the previous stage. | Sequential: delay grows with bit width. |
| **Carry lookahead** | Carries are **predicted** from A, B, and C<sub>in</sub> using G and P. | Parallel: all carries from inputs only. |

- In a **full adder**, we typically need the sum of two bits to resolve the carry → a **sequential** process along the chain.
- In a **CLA**, we **predict the carry** at each position using only the current A and B bits and C<sub>in</sub>, so all carry bits can be computed **in parallel** with the sum. We trade more gates for **much lower delay**.

---

## Carry Output: Truth Table and Derivation

For a single bit position, the carry-out **C<sub>o</sub>** of a full adder depends on **A**, **B**, and **C<sub>in</sub>**. The truth table is:

| **A** | **B** | **C<sub>in</sub>** | **C<sub>o</sub>** |
|:-----:|:-----:|:------------------:|:-----------------:|
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 0 |
| 0 | 1 | 0 | 0 |
| 0 | 1 | 1 | 1 |
| 1 | 0 | 0 | 0 |
| 1 | 0 | 1 | 1 |
| 1 | 1 | 0 | 1 |
| 1 | 1 | 1 | 1 |

The rows where **C<sub>o</sub> = 1** are:

| **A** | **B** | **C<sub>in</sub>** | **C<sub>o</sub>** |
|:-----:|:-----:|:------------------:|:-----------------:|
| 0 | 1 | 1 | 1 |
| 1 | 0 | 1 | 1 |
| 1 | 1 | 0 | 1 |
| 1 | 1 | 1 | 1 |

From this we see:

- **Last two rows:** when **both A and B are 1**, C<sub>o</sub> is 1 (independent of C<sub>in</sub>). This is the **carry generate**: **G = A · B**.
- **First two rows:** C<sub>o</sub> is 1 when **exactly one of A, B is 1** *and* **C<sub>in</sub> is 1**. That is **(A ⊕ B) · C<sub>in</sub>**. This is the **carry propagate** term: **P = A ⊕ B** (carry propagates when P = 1 and C<sub>in</sub> = 1).

So:

**C<sub>o</sub> = A · B + (A ⊕ B) · C<sub>in</sub>**

Defining:

- **G = A · B** — **carry generate** (no dependence on C<sub>in</sub>).
- **P = A ⊕ B** — **carry propagate** (carry-out equals C<sub>in</sub> when P = 1).

We get:

**C<sub>o</sub> = G + P · C<sub>in</sub>**

For the next stage, the carry-in is the previous carry-out. Writing C<sub>in</sub> as C<sub>−1</sub> for the first stage:

**C<sub>i</sub> = G<sub>i</sub> + P<sub>i</sub> · C<sub>i−1</sub>**

---

## Carry Lookahead Equations (General Case)

By substituting the recurrence C<sub>i</sub> = G<sub>i</sub> + P<sub>i</sub> · C<sub>i−1</sub> repeatedly, we express each carry in terms of only **G**, **P**, and **C<sub>−1</sub>** (the external carry-in), so all carries can be computed in parallel:

| Stage | Carry equation |
|-------|----------------|
| **i = 0** | C<sub>0</sub> = G<sub>0</sub> + P<sub>0</sub> · C<sub>−1</sub> |
| **i = 1** | C<sub>1</sub> = G<sub>1</sub> + P<sub>1</sub> · C<sub>0</sub> = G<sub>1</sub> + P<sub>1</sub> · G<sub>0</sub> + P<sub>1</sub> · P<sub>0</sub> · C<sub>−1</sub> |
| **i = 2** | C<sub>2</sub> = G<sub>2</sub> + P<sub>2</sub> · C<sub>1</sub> = G<sub>2</sub> + P<sub>2</sub> · G<sub>1</sub> + P<sub>2</sub> · P<sub>1</sub> · G<sub>0</sub> + P<sub>2</sub> · P<sub>1</sub> · P<sub>0</sub> · C<sub>−1</sub> |
| **i = 3** | C<sub>3</sub> = G<sub>3</sub> + P<sub>3</sub> · C<sub>2</sub> = G<sub>3</sub> + P<sub>3</sub> · G<sub>2</sub> + P<sub>3</sub> · P<sub>2</sub> · G<sub>1</sub> + P<sub>3</sub> · P<sub>2</sub> · P<sub>1</sub> · G<sub>0</sub> + P<sub>3</sub> · P<sub>2</sub> · P<sub>1</sub> · P<sub>0</sub> · C<sub>−1</sub> |

All **C<sub>i</sub>** depend only on **A**, **B**, and **C<sub>−1</sub>**, so they can be computed in parallel. The sum bits then use **S<sub>i</sub> = P<sub>i</sub> ⊕ C<sub>i−1</sub>** (with C<sub>−1</sub> = C<sub>in</sub> for the LSB).

---

## 4-Bit CLA Logic and Boolean Equations

For a 4-bit CLA, bit indices are **0** (LSB) to **3** (MSB). **C<sub>−1</sub>** denotes the external carry-in (C<sub>in</sub>).

### Generate and propagate (per bit)

| Signal | Equation | Implementation |
|--------|----------|----------------|
| G<sub>3</sub> | G<sub>3</sub> = A<sub>3</sub> · B<sub>3</sub> | AND |
| G<sub>2</sub> | G<sub>2</sub> = A<sub>2</sub> · B<sub>2</sub> | AND |
| G<sub>1</sub> | G<sub>1</sub> = A<sub>1</sub> · B<sub>1</sub> | AND |
| G<sub>0</sub> | G<sub>0</sub> = A<sub>0</sub> · B<sub>0</sub> | AND |
| P<sub>3</sub> | P<sub>3</sub> = A<sub>3</sub> ⊕ B<sub>3</sub> | XOR |
| P<sub>2</sub> | P<sub>2</sub> = A<sub>2</sub> ⊕ B<sub>2</sub> | XOR |
| P<sub>1</sub> | P<sub>1</sub> = A<sub>1</sub> ⊕ B<sub>1</sub> | XOR |
| P<sub>0</sub> | P<sub>0</sub> = A<sub>0</sub> ⊕ B<sub>0</sub> | XOR |

### Carry (all from A, B, C<sub>−1</sub>)

| Signal | Equation |
|--------|----------|
| C<sub>0</sub> | C<sub>0</sub> = G<sub>0</sub> + P<sub>0</sub> · C<sub>−1</sub> |
| C<sub>1</sub> | C<sub>1</sub> = G<sub>1</sub> + P<sub>1</sub> · G<sub>0</sub> + P<sub>1</sub> · P<sub>0</sub> · C<sub>−1</sub> |
| C<sub>2</sub> | C<sub>2</sub> = G<sub>2</sub> + P<sub>2</sub> · G<sub>1</sub> + P<sub>2</sub> · P<sub>1</sub> · G<sub>0</sub> + P<sub>2</sub> · P<sub>1</sub> · P<sub>0</sub> · C<sub>−1</sub> |
| C<sub>3</sub> | C<sub>3</sub> = G<sub>3</sub> + P<sub>3</sub> · G<sub>2</sub> + P<sub>3</sub> · P<sub>2</sub> · G<sub>1</sub> + P<sub>3</sub> · P<sub>2</sub> · P<sub>1</sub> · G<sub>0</sub> + P<sub>3</sub> · P<sub>2</sub> · P<sub>1</sub> · P<sub>0</sub> · C<sub>−1</sub> |

### Sum (XOR of propagate and incoming carry)

| Signal | Equation |
|--------|----------|
| S<sub>0</sub> | S<sub>0</sub> = P<sub>0</sub> ⊕ C<sub>−1</sub> |
| S<sub>1</sub> | S<sub>1</sub> = P<sub>1</sub> ⊕ C<sub>0</sub> |
| S<sub>2</sub> | S<sub>2</sub> = P<sub>2</sub> ⊕ C<sub>1</sub> |
| S<sub>3</sub> | S<sub>3</sub> = P<sub>3</sub> ⊕ C<sub>2</sub> |

**Carry-out:** C<sub>o</sub> = C<sub>3</sub>.

In the Verilog module `carryLookaheadAdder`, these equations are implemented with continuous assignments: inputs **A[3:0]**, **B[3:0]**, **C<sub>in</sub>**; outputs **S3, S2, S1, S0**, **Co**.

---

## Learning Resources

| Resource | Description |
|----------|-------------|
| [Carry Lookahead Adder (YouTube)](https://www.youtube.com/results?search_query=carry+lookahead+adder) | CLA concept, G/P derivation, and multi-bit expansion. |
| [Ripple Carry vs Lookahead (YouTube)](https://www.youtube.com/results?search_query=ripple+carry+vs+lookahead) | Delay comparison and when to use CLA. |
| [Full Adder and Carry Logic (YouTube)](https://www.youtube.com/results?search_query=full+adder+carry+generate+propagate) | Generate (G) and propagate (P) in adders. |
| [Verilog Combinational Circuits (YouTube)](https://www.youtube.com/results?search_query=verilog+combinational+circuits) | RTL and testbench examples in Verilog. |

---

## Circuit Diagram

The logic diagram shows the parallel computation of **G** and **P**, the lookahead carry block (C<sub>0</sub> … C<sub>3</sub> from A, B, C<sub>in</sub>), and the sum XOR gates (S<sub>0</sub> … S<sub>3</sub>).

![4-Bit Carry Lookahead Adder Circuit](imageAssets/carryLookaheadAdderCircuit.png)

*If the image does not appear, add your circuit schematic as `imageAssets/carryLookaheadAdderCircuit.png`.*

---

## Waveform Diagram

The behavioral simulation waveform shows **A**, **B**, and **C<sub>in</sub>** over time, with **S** and **C<sub>o</sub>** giving the expected sum and carry-out for each input combination.

![4-Bit Carry Lookahead Adder Waveform](imageAssets/carryLookaheadAdderWaveform.png)

*If the image does not appear, add your waveform export as `imageAssets/carryLookaheadAdderWaveform.png`.*

---

## Testbench Output

The testbench applies all 256 combinations of **A** and **B** (4-bit each) with **C<sub>in</sub> = 0** and prints **A**, **B**, **C<sub>in</sub>**, **S**, and **C<sub>o</sub>**. A representative portion of the simulation log is shown below. The full output is long; in most viewers the code block is scrollable.

<details>
<summary>Click to expand full testbench output (256 lines)</summary>

```text
A = 0000, B=0000, Cin = 0, S = 0000, Co = 0
A = 0000, B=0001, Cin = 0, S = 0001, Co = 0
A = 0000, B=0010, Cin = 0, S = 0010, Co = 0
A = 0000, B=0011, Cin = 0, S = 0011, Co = 0
A = 0000, B=0100, Cin = 0, S = 0100, Co = 0
A = 0000, B=0101, Cin = 0, S = 0101, Co = 0
A = 0000, B=0110, Cin = 0, S = 0110, Co = 0
A = 0000, B=0111, Cin = 0, S = 0111, Co = 0
A = 0000, B=1000, Cin = 0, S = 1000, Co = 0
A = 0000, B=1001, Cin = 0, S = 1001, Co = 0
A = 0000, B=1010, Cin = 0, S = 1010, Co = 0
A = 0000, B=1011, Cin = 0, S = 1011, Co = 0
A = 0000, B=1100, Cin = 0, S = 1100, Co = 0
A = 0000, B=1101, Cin = 0, S = 1101, Co = 0
A = 0000, B=1110, Cin = 0, S = 1110, Co = 0
A = 0000, B=1111, Cin = 0, S = 1111, Co = 0
A = 0001, B=0000, Cin = 0, S = 0001, Co = 0
A = 0001, B=0001, Cin = 0, S = 0010, Co = 0
A = 0001, B=0010, Cin = 0, S = 0011, Co = 0
A = 0001, B=0011, Cin = 0, S = 0100, Co = 0
A = 0001, B=0100, Cin = 0, S = 0101, Co = 0
A = 0001, B=0101, Cin = 0, S = 0110, Co = 0
A = 0001, B=0110, Cin = 0, S = 0111, Co = 0
A = 0001, B=0111, Cin = 0, S = 1000, Co = 0
A = 0001, B=1000, Cin = 0, S = 1001, Co = 0
A = 0001, B=1001, Cin = 0, S = 1010, Co = 0
A = 0001, B=1010, Cin = 0, S = 1011, Co = 0
A = 0001, B=1011, Cin = 0, S = 1100, Co = 0
A = 0001, B=1100, Cin = 0, S = 1101, Co = 0
A = 0001, B=1101, Cin = 0, S = 1110, Co = 0
A = 0001, B=1110, Cin = 0, S = 1111, Co = 0
A = 0001, B=1111, Cin = 0, S = 0000, Co = 1
A = 0010, B=0000, Cin = 0, S = 0010, Co = 0
A = 0010, B=0001, Cin = 0, S = 0011, Co = 0
A = 0010, B=0010, Cin = 0, S = 0100, Co = 0
A = 0010, B=0011, Cin = 0, S = 0101, Co = 0
A = 0010, B=0100, Cin = 0, S = 0110, Co = 0
A = 0010, B=0101, Cin = 0, S = 0111, Co = 0
A = 0010, B=0110, Cin = 0, S = 1000, Co = 0
A = 0010, B=0111, Cin = 0, S = 1001, Co = 0
A = 0010, B=1000, Cin = 0, S = 1010, Co = 0
A = 0010, B=1001, Cin = 0, S = 1011, Co = 0
A = 0010, B=1010, Cin = 0, S = 1100, Co = 0
A = 0010, B=1011, Cin = 0, S = 1101, Co = 0
A = 0010, B=1100, Cin = 0, S = 1110, Co = 0
A = 0010, B=1101, Cin = 0, S = 1111, Co = 0
A = 0010, B=1110, Cin = 0, S = 0000, Co = 1
A = 0010, B=1111, Cin = 0, S = 0001, Co = 1
A = 0011, B=0000, Cin = 0, S = 0011, Co = 0
A = 0011, B=0001, Cin = 0, S = 0100, Co = 0
A = 0011, B=0010, Cin = 0, S = 0101, Co = 0
A = 0011, B=0011, Cin = 0, S = 0110, Co = 0
A = 0011, B=0100, Cin = 0, S = 0111, Co = 0
A = 0011, B=0101, Cin = 0, S = 1000, Co = 0
A = 0011, B=0110, Cin = 0, S = 1001, Co = 0
A = 0011, B=0111, Cin = 0, S = 1010, Co = 0
A = 0011, B=1000, Cin = 0, S = 1011, Co = 0
A = 0011, B=1001, Cin = 0, S = 1100, Co = 0
A = 0011, B=1010, Cin = 0, S = 1101, Co = 0
A = 0011, B=1011, Cin = 0, S = 1110, Co = 0
A = 0011, B=1100, Cin = 0, S = 1111, Co = 0
A = 0011, B=1101, Cin = 0, S = 0000, Co = 1
A = 0011, B=1110, Cin = 0, S = 0001, Co = 1
A = 0011, B=1111, Cin = 0, S = 0010, Co = 1
A = 0100, B=0000, Cin = 0, S = 0100, Co = 0
A = 0100, B=0001, Cin = 0, S = 0101, Co = 0
A = 0100, B=0010, Cin = 0, S = 0110, Co = 0
A = 0100, B=0011, Cin = 0, S = 0111, Co = 0
A = 0100, B=0100, Cin = 0, S = 1000, Co = 0
A = 0100, B=0101, Cin = 0, S = 1001, Co = 0
A = 0100, B=0110, Cin = 0, S = 1010, Co = 0
A = 0100, B=0111, Cin = 0, S = 1011, Co = 0
A = 0100, B=1000, Cin = 0, S = 1100, Co = 0
A = 0100, B=1001, Cin = 0, S = 1101, Co = 0
A = 0100, B=1010, Cin = 0, S = 1110, Co = 0
A = 0100, B=1011, Cin = 0, S = 1111, Co = 0
A = 0100, B=1100, Cin = 0, S = 0000, Co = 1
A = 0100, B=1101, Cin = 0, S = 0001, Co = 1
A = 0100, B=1110, Cin = 0, S = 0010, Co = 1
A = 0100, B=1111, Cin = 0, S = 0011, Co = 1
A = 0101, B=0000, Cin = 0, S = 0101, Co = 0
A = 0101, B=0001, Cin = 0, S = 0110, Co = 0
A = 0101, B=0010, Cin = 0, S = 0111, Co = 0
A = 0101, B=0011, Cin = 0, S = 1000, Co = 0
A = 0101, B=0100, Cin = 0, S = 1001, Co = 0
A = 0101, B=0101, Cin = 0, S = 1010, Co = 0
A = 0101, B=0110, Cin = 0, S = 1011, Co = 0
A = 0101, B=0111, Cin = 0, S = 1100, Co = 0
A = 0101, B=1000, Cin = 0, S = 1101, Co = 0
A = 0101, B=1001, Cin = 0, S = 1110, Co = 0
A = 0101, B=1010, Cin = 0, S = 1111, Co = 0
A = 0101, B=1011, Cin = 0, S = 0000, Co = 1
A = 0101, B=1100, Cin = 0, S = 0001, Co = 1
A = 0101, B=1101, Cin = 0, S = 0010, Co = 1
A = 0101, B=1110, Cin = 0, S = 0011, Co = 1
A = 0101, B=1111, Cin = 0, S = 0100, Co = 1
A = 0110, B=0000, Cin = 0, S = 0110, Co = 0
A = 0110, B=0001, Cin = 0, S = 0111, Co = 0
A = 0110, B=0010, Cin = 0, S = 1000, Co = 0
A = 0110, B=0011, Cin = 0, S = 1001, Co = 0
A = 0110, B=0100, Cin = 0, S = 1010, Co = 0
A = 0110, B=0101, Cin = 0, S = 1011, Co = 0
A = 0110, B=0110, Cin = 0, S = 1100, Co = 0
A = 0110, B=0111, Cin = 0, S = 1101, Co = 0
A = 0110, B=1000, Cin = 0, S = 1110, Co = 0
A = 0110, B=1001, Cin = 0, S = 1111, Co = 0
A = 0110, B=1010, Cin = 0, S = 0000, Co = 1
A = 0110, B=1011, Cin = 0, S = 0001, Co = 1
A = 0110, B=1100, Cin = 0, S = 0010, Co = 1
A = 0110, B=1101, Cin = 0, S = 0011, Co = 1
A = 0110, B=1110, Cin = 0, S = 0100, Co = 1
A = 0110, B=1111, Cin = 0, S = 0101, Co = 1
A = 0111, B=0000, Cin = 0, S = 0111, Co = 0
A = 0111, B=0001, Cin = 0, S = 1000, Co = 0
A = 0111, B=0010, Cin = 0, S = 1001, Co = 0
A = 0111, B=0011, Cin = 0, S = 1010, Co = 0
A = 0111, B=0100, Cin = 0, S = 1011, Co = 0
A = 0111, B=0101, Cin = 0, S = 1100, Co = 0
A = 0111, B=0110, Cin = 0, S = 1101, Co = 0
A = 0111, B=0111, Cin = 0, S = 1110, Co = 0
A = 0111, B=1000, Cin = 0, S = 1111, Co = 0
A = 0111, B=1001, Cin = 0, S = 0000, Co = 1
A = 0111, B=1010, Cin = 0, S = 0001, Co = 1
A = 0111, B=1011, Cin = 0, S = 0010, Co = 1
A = 0111, B=1100, Cin = 0, S = 0011, Co = 1
A = 0111, B=1101, Cin = 0, S = 0100, Co = 1
A = 0111, B=1110, Cin = 0, S = 0101, Co = 1
A = 0111, B=1111, Cin = 0, S = 0110, Co = 1
A = 1000, B=0000, Cin = 0, S = 1000, Co = 0
A = 1000, B=0001, Cin = 0, S = 1001, Co = 0
A = 1000, B=0010, Cin = 0, S = 1010, Co = 0
A = 1000, B=0011, Cin = 0, S = 1011, Co = 0
A = 1000, B=0100, Cin = 0, S = 1100, Co = 0
A = 1000, B=0101, Cin = 0, S = 1101, Co = 0
A = 1000, B=0110, Cin = 0, S = 1110, Co = 0
A = 1000, B=0111, Cin = 0, S = 1111, Co = 0
A = 1000, B=1000, Cin = 0, S = 0000, Co = 1
A = 1000, B=1001, Cin = 0, S = 0001, Co = 1
A = 1000, B=1010, Cin = 0, S = 0010, Co = 1
A = 1000, B=1011, Cin = 0, S = 0011, Co = 1
A = 1000, B=1100, Cin = 0, S = 0100, Co = 1
A = 1000, B=1101, Cin = 0, S = 0101, Co = 1
A = 1000, B=1110, Cin = 0, S = 0110, Co = 1
A = 1000, B=1111, Cin = 0, S = 0111, Co = 1
A = 1001, B=0000, Cin = 0, S = 1001, Co = 0
A = 1001, B=0001, Cin = 0, S = 1010, Co = 0
A = 1001, B=0010, Cin = 0, S = 1011, Co = 0
A = 1001, B=0011, Cin = 0, S = 1100, Co = 0
A = 1001, B=0100, Cin = 0, S = 1101, Co = 0
A = 1001, B=0101, Cin = 0, S = 1110, Co = 0
A = 1001, B=0110, Cin = 0, S = 1111, Co = 0
A = 1001, B=0111, Cin = 0, S = 0000, Co = 1
A = 1001, B=1000, Cin = 0, S = 0001, Co = 1
A = 1001, B=1001, Cin = 0, S = 0010, Co = 1
A = 1001, B=1010, Cin = 0, S = 0011, Co = 1
A = 1001, B=1011, Cin = 0, S = 0100, Co = 1
A = 1001, B=1100, Cin = 0, S = 0101, Co = 1
A = 1001, B=1101, Cin = 0, S = 0110, Co = 1
A = 1001, B=1110, Cin = 0, S = 0111, Co = 1
A = 1001, B=1111, Cin = 0, S = 1000, Co = 1
A = 1010, B=0000, Cin = 0, S = 1010, Co = 0
A = 1010, B=0001, Cin = 0, S = 1011, Co = 0
A = 1010, B=0010, Cin = 0, S = 1100, Co = 0
A = 1010, B=0011, Cin = 0, S = 1101, Co = 0
A = 1010, B=0100, Cin = 0, S = 1110, Co = 0
A = 1010, B=0101, Cin = 0, S = 1111, Co = 0
A = 1010, B=0110, Cin = 0, S = 0000, Co = 1
A = 1010, B=0111, Cin = 0, S = 0001, Co = 1
A = 1010, B=1000, Cin = 0, S = 0010, Co = 1
A = 1010, B=1001, Cin = 0, S = 0011, Co = 1
A = 1010, B=1010, Cin = 0, S = 0100, Co = 1
A = 1010, B=1011, Cin = 0, S = 0101, Co = 1
A = 1010, B=1100, Cin = 0, S = 0110, Co = 1
A = 1010, B=1101, Cin = 0, S = 0111, Co = 1
A = 1010, B=1110, Cin = 0, S = 1000, Co = 1
A = 1010, B=1111, Cin = 0, S = 1001, Co = 1
A = 1011, B=0000, Cin = 0, S = 1011, Co = 0
A = 1011, B=0001, Cin = 0, S = 1100, Co = 0
A = 1011, B=0010, Cin = 0, S = 1101, Co = 0
A = 1011, B=0011, Cin = 0, S = 1110, Co = 0
A = 1011, B=0100, Cin = 0, S = 1111, Co = 0
A = 1011, B=0101, Cin = 0, S = 0000, Co = 1
A = 1011, B=0110, Cin = 0, S = 0001, Co = 1
A = 1011, B=0111, Cin = 0, S = 0010, Co = 1
A = 1011, B=1000, Cin = 0, S = 0011, Co = 1
A = 1011, B=1001, Cin = 0, S = 0100, Co = 1
A = 1011, B=1010, Cin = 0, S = 0101, Co = 1
A = 1011, B=1011, Cin = 0, S = 0110, Co = 1
A = 1011, B=1100, Cin = 0, S = 0111, Co = 1
A = 1011, B=1101, Cin = 0, S = 1000, Co = 1
A = 1011, B=1110, Cin = 0, S = 1001, Co = 1
A = 1011, B=1111, Cin = 0, S = 1010, Co = 1
A = 1100, B=0000, Cin = 0, S = 1100, Co = 0
A = 1100, B=0001, Cin = 0, S = 1101, Co = 0
A = 1100, B=0010, Cin = 0, S = 1110, Co = 0
A = 1100, B=0011, Cin = 0, S = 1111, Co = 0
A = 1100, B=0100, Cin = 0, S = 0000, Co = 1
A = 1100, B=0101, Cin = 0, S = 0001, Co = 1
A = 1100, B=0110, Cin = 0, S = 0010, Co = 1
A = 1100, B=0111, Cin = 0, S = 0011, Co = 1
A = 1100, B=1000, Cin = 0, S = 0100, Co = 1
A = 1100, B=1001, Cin = 0, S = 0101, Co = 1
A = 1100, B=1010, Cin = 0, S = 0110, Co = 1
A = 1100, B=1011, Cin = 0, S = 0111, Co = 1
A = 1100, B=1100, Cin = 0, S = 1000, Co = 1
A = 1100, B=1101, Cin = 0, S = 1001, Co = 1
A = 1100, B=1110, Cin = 0, S = 1010, Co = 1
A = 1100, B=1111, Cin = 0, S = 1011, Co = 1
A = 1101, B=0000, Cin = 0, S = 1101, Co = 0
A = 1101, B=0001, Cin = 0, S = 1110, Co = 0
A = 1101, B=0010, Cin = 0, S = 1111, Co = 0
A = 1101, B=0011, Cin = 0, S = 0000, Co = 1
A = 1101, B=0100, Cin = 0, S = 0001, Co = 1
A = 1101, B=0101, Cin = 0, S = 0010, Co = 1
A = 1101, B=0110, Cin = 0, S = 0011, Co = 1
A = 1101, B=0111, Cin = 0, S = 0100, Co = 1
A = 1101, B=1000, Cin = 0, S = 0101, Co = 1
A = 1101, B=1001, Cin = 0, S = 0110, Co = 1
A = 1101, B=1010, Cin = 0, S = 0111, Co = 1
A = 1101, B=1011, Cin = 0, S = 1000, Co = 1
A = 1101, B=1100, Cin = 0, S = 1001, Co = 1
A = 1101, B=1101, Cin = 0, S = 1010, Co = 1
A = 1101, B=1110, Cin = 0, S = 1011, Co = 1
A = 1101, B=1111, Cin = 0, S = 1100, Co = 1
A = 1110, B=0000, Cin = 0, S = 1110, Co = 0
A = 1110, B=0001, Cin = 0, S = 1111, Co = 0
A = 1110, B=0010, Cin = 0, S = 0000, Co = 1
A = 1110, B=0011, Cin = 0, S = 0001, Co = 1
A = 1110, B=0100, Cin = 0, S = 0010, Co = 1
A = 1110, B=0101, Cin = 0, S = 0011, Co = 1
A = 1110, B=0110, Cin = 0, S = 0100, Co = 1
A = 1110, B=0111, Cin = 0, S = 0101, Co = 1
A = 1110, B=1000, Cin = 0, S = 0110, Co = 1
A = 1110, B=1001, Cin = 0, S = 0111, Co = 1
A = 1110, B=1010, Cin = 0, S = 1000, Co = 1
A = 1110, B=1011, Cin = 0, S = 1001, Co = 1
A = 1110, B=1100, Cin = 0, S = 1010, Co = 1
A = 1110, B=1101, Cin = 0, S = 1011, Co = 1
A = 1110, B=1110, Cin = 0, S = 1100, Co = 1
A = 1110, B=1111, Cin = 0, S = 1101, Co = 1
A = 1111, B=0000, Cin = 0, S = 1111, Co = 0
A = 1111, B=0001, Cin = 0, S = 0000, Co = 1
A = 1111, B=0010, Cin = 0, S = 0001, Co = 1
A = 1111, B=0011, Cin = 0, S = 0010, Co = 1
A = 1111, B=0100, Cin = 0, S = 0011, Co = 1
A = 1111, B=0101, Cin = 0, S = 0100, Co = 1
A = 1111, B=0110, Cin = 0, S = 0101, Co = 1
A = 1111, B=0111, Cin = 0, S = 0110, Co = 1
A = 1111, B=1000, Cin = 0, S = 0111, Co = 1
A = 1111, B=1001, Cin = 0, S = 1000, Co = 1
A = 1111, B=1010, Cin = 0, S = 1001, Co = 1
A = 1111, B=1011, Cin = 0, S = 1010, Co = 1
A = 1111, B=1100, Cin = 0, S = 1011, Co = 1
A = 1111, B=1101, Cin = 0, S = 1100, Co = 1
A = 1111, B=1110, Cin = 0, S = 1101, Co = 1
A = 1111, B=1111, Cin = 0, S = 1110, Co = 1
```

</details>

These results match the expected 4-bit addition **S = A + B + C<sub>in</sub>** and **C<sub>o</sub>** as the carry-out, confirming that the **implementation is functionally correct**.

---

## Running the Project in Vivado

Follow these steps to open the project in **Vivado** and run the simulation.

### Prerequisites

- **Xilinx Vivado** installed (Vivado HL Design Edition, Lab Edition, or any recent version compatible with your OS).

### 1. Launch Vivado

1. Start Vivado from the Start Menu (Windows) or your application launcher.
2. Choose **Vivado** (or **Vivado HLx**).

### 2. Create a New RTL Project

1. Click **Create Project** (or **File** > **Project** > **New**).
2. Click **Next** on the welcome page.
3. Choose **RTL Project** and leave **Do not specify sources at this time** unchecked if you plan to add sources immediately.
4. Click **Next**.

### 3. Add Design and Simulation Sources

1. In the **Add Sources** step, add the Verilog design files:
   - **Design sources:**
     - `carryLookaheadAdder.v` — 4-bit CLA module (inputs A[3:0], B[3:0], C<sub>in</sub>; outputs S3, S2, S1, S0, C<sub>o</sub>).
   - **Simulation sources:**
     - `carryLookaheadAdder_tb.v` — testbench that applies all 256 (A, B) combinations with C<sub>in</sub> = 0 and prints A, B, C<sub>in</sub>, S, and C<sub>o</sub>.
2. Set the testbench as the **top module for simulation**:
   - In the **Sources** window, under **Simulation Sources**, right-click `carryLookaheadAdder_tb.v` and choose **Set as Top**.
3. Click **Next**, choose a suitable **target device** (or leave default / "Don't specify" for simulation-only), then **Next** and **Finish**.

### 4. Run Behavioral Simulation

1. In the **Flow Navigator** (left panel), under **Simulation**, click **Run Behavioral Simulation**.
2. Vivado will elaborate the design (`carryLookaheadAdder` as the DUT), compile, and open the **Simulation** view with the waveform.
3. Inspect the waveform:
   - Confirm that A and B cycle through all 4-bit combinations.
   - Verify that S = A + B + C<sub>in</sub> and C<sub>o</sub> is the carry-out for each combination.

### 5. (Optional) Re-run or Modify the Design

- To re-run: **Flow Navigator** > **Simulation** > **Run Behavioral Simulation** (or the re-run icon in the simulation toolbar).
- To change the design or testbench: edit `carryLookaheadAdder.v` or `carryLookaheadAdder_tb.v`, save, then re-run behavioral simulation.

### 6. (Optional) Synthesis, Implementation, and Bitstream

To map the design to an FPGA:

1. In **Sources**, right-click the top-level RTL module (`carryLookaheadAdder.v`) and choose **Set as Top** (for synthesis/implementation).
2. Run **Synthesis** from the Flow Navigator.
3. Run **Implementation**.
4. Create or edit a constraints file (e.g. `.xdc`) to assign pins for A, B, C<sub>in</sub>, S, and C<sub>o</sub>.
5. Run **Generate Bitstream** to produce the configuration file for your FPGA board.

---

## Project Files

- `carryLookaheadAdder.v` — RTL for the 4-bit carry lookahead adder: (A[3:0], B[3:0], C<sub>in</sub>) → (S3, S2, S1, S0, C<sub>o</sub>).
- `carryLookaheadAdder_tb.v` — Testbench for the 4-bit CLA; applies all 256 (A, B) combinations with C<sub>in</sub> = 0 and prints A, B, C<sub>in</sub>, S, and C<sub>o</sub>.

---

*Author: **Kadhir Ponnambalam***
