# MIPS Processor Showcase

A modern, interactive web dashboard showcasing a 32-bit single-cycle MIPS System on Chip (SOC) implemented by [Akshat Baranwal](https://github.com/11mosfets).

![MIPS Processor Showcase](https://img.shields.io/badge/Architecture-32--Bit_MIPS-blue) ![Status](https://img.shields.io/badge/Status-Completed-success)

## Overview

This repository contains the front-end code for the MIPS Processor interactive dashboard. The site serves as a visual portfolio piece, highlighting the architectural features and instruction set of a custom MIPS SOC. 

The dashboard features:
- **Interactive High-Level Block Diagram**: A sleek, Mermaid-rendered diagram of the core datapath, memory, and control unit routing.
- **Architecture Specifications**: Quick-glance metrics detailing the 32-bit datapath, Harvard architecture, single-cycle execution, and active instruction count.
- **Instruction Set Reference**: A dynamic grid of the 32 supported MIPS instructions. Hovering over any instruction tag reveals a custom tooltip containing its exact RTL (Register Transfer Level) formula based strictly on the official Patterson & Hennessy MIPS "Greencard".
- **Modern Glassmorphism UI**: A premium dark-mode aesthetic built with smooth animations, dynamic glowing background effects, and responsive CSS grid layouts.

## Technologies Used

- **HTML5**: Semantic layout and structure.
- **Vanilla CSS3**: Custom properties, Flexbox, CSS Grid, keyframe animations, and glassmorphism styling (`backdrop-filter`).
- **Vanilla JavaScript**: Dynamic DOM manipulation for generating instruction tags, stagger animations, and tooltip attributes.
- **[Mermaid JS](https://mermaid.js.org/)**: Diagram rendering for the High-Level Block Diagram.
- **Typography**: [Inter](https://fonts.google.com/specimen/Inter) for UI elements and [JetBrains Mono](https://fonts.google.com/specimen/JetBrains+Mono) for code/instructions.

## Setup & Running Locally

Since this is a fully static website built with vanilla web technologies, there is no complicated build step required.

1. Clone the repository:
   ```bash
   git clone https://github.com/11mosfets/mips.git
   ```
2. Navigate into the directory:
   ```bash
   cd mips
   ```
3. Open `index.html` directly in your favorite web browser, or serve it using a local development server for the best experience (e.g., Python's simple HTTP server):
   ```bash
   python3 -m http.server 8000
   ```
4. Visit `http://localhost:8000` to view the dashboard.

## Acknowledgements

- RTL operations and instruction definitions were extracted from the *Computer Organization and Design (5th Edition)* MIPS Reference Data Card ("Greencard").

---
&copy; 2026 Akshat Baranwal. All Rights Reserved.
