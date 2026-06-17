# 32-Bit Single-Cycle MIPS Processor

A custom 32-bit MIPS Processor implemented entirely in SystemVerilog. This repository contains the complete Register Transfer Level (RTL) design, testbenches, and documentation for a functional single-cycle CPU.

![Status](https://img.shields.io/badge/Status-Completed-success) ![Language](https://img.shields.io/badge/Language-SystemVerilog-blue)

## Project Overview

This project implements a non-pipelined, single-cycle MIPS System on Chip (SOC). It demonstrates a deep understanding of computer architecture by implementing the complete datapath and control logic required to execute a core subset of the MIPS instruction set architecture (ISA).

### Key Architectural Features
- **32-Bit Datapath**: Full 32-bit registers, ALU, and data buses.
- **Harvard Architecture**: Separate instruction and data memories.
- **Single-Cycle Execution**: Every instruction is fetched, decoded, executed, and written back within a single clock cycle.
- **Extensive Instruction Set**: Supports 32 fundamental MIPS instructions including Arithmetic/Logic (ADD, SUB, AND, OR), Branching (BEQ, BNE), Jumps (J, JAL, JR), and Memory Operations (LW, SW).

## Hardware Implementation Details

The processor is modularized into several key SystemVerilog components:
- **`cpu2.sv`**: The top-level CPU module containing the main control unit logic, wire routing, and module instantiations.
- **`alu.sv`**: The Arithmetic Logic Unit, responsible for performing all mathematical and bitwise operations.
- **`regfile.sv`**: A 32x32-bit register file with asynchronous reads and synchronous writes.
- **`pc.sv`**: Program Counter module to track execution flow.
- **`instr_reg.sv`**: Instruction decoder logic based on the MIPS opcode and funct fields.
- **`memory.sv`**: Simulates the separate instruction and data memories.
- **`top_cpu2.sv`**: The primary testbench for simulating execution, loading hex programs (e.g., `prog_i.txt`), and verifying output state via register file dumps.

## Simulation & Testing

The CPU can be simulated using standard Verilog simulators (e.g., ModelSim, VCS, or Verilator). The provided testbench (`top_cpu2.sv`) runs the processor against loaded instructions and asserts on illegal instructions and halts.

## Interactive Web Dashboard

To explore the architecture, datapath, and detailed RTL formulas of the supported instructions, check out the interactive showcase:
👉 **[Live MIPS Web Dashboard](https://mips-ex1.pages.dev)**

---
&copy; 2026 Akshat Baranwal. All Rights Reserved.
