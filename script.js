document.addEventListener('DOMContentLoaded', () => {
    // Initialize Mermaid with custom settings for better dark mode rendering
    mermaid.initialize({
        startOnLoad: true,
        securityLevel: 'loose',
        theme: 'base',
        fontFamily: 'Inter, sans-serif'
    });

    // Map of instructions to their descriptions from MIPS Greencard
    const instructions = {
        "ADD": "Add | R[rd] = R[rs] + R[rt]",
        "ADDI": "Add Immediate | R[rt] = R[rs] + SignExtImm",
        "ADDIU": "Add Imm. Unsigned | R[rt] = R[rs] + SignExtImm",
        "ADDU": "Add Unsigned | R[rd] = R[rs] + R[rt]",
        "AND": "And | R[rd] = R[rs] & R[rt]",
        "ANDI": "And Immediate | R[rt] = R[rs] & ZeroExtImm",
        "BEQ": "Branch On Equal | if(R[rs]==R[rt]) PC=PC+4+BranchAddr",
        "BNE": "Branch On Not Equal | if(R[rs]!=R[rt]) PC=PC+4+BranchAddr",
        "J": "Jump | PC=JumpAddr",
        "JAL": "Jump And Link | R[31]=PC+8; PC=JumpAddr",
        "JR": "Jump Register | PC=R[rs]",
        "LBU": "Load Byte Unsigned | R[rt]={24'b0,M[R[rs]+SignExtImm](7:0)}",
        "LHU": "Load Halfword Unsigned | R[rt]={16'b0,M[R[rs]+SignExtImm](15:0)}",
        "LL": "Load Linked | R[rt] = M[R[rs]+SignExtImm]",
        "LUI": "Load Upper Imm. | R[rt] = {imm, 16'b0}",
        "LW": "Load Word | R[rt] = M[R[rs]+SignExtImm]",
        "NOR": "Nor | R[rd] = ~(R[rs] | R[rt])",
        "OR": "Or | R[rd] = R[rs] | R[rt]",
        "ORI": "Or Immediate | R[rt] = R[rs] | ZeroExtImm",
        "SB": "Store Byte | M[R[rs]+SignExtImm](7:0) = R[rt](7:0)",
        "SC": "Store Conditional | M[R[rs]+SignExtImm]=R[rt]; R[rt]=(atomic)?1:0",
        "SH": "Store Halfword | M[R[rs]+SignExtImm](15:0) = R[rt](15:0)",
        "SLL": "Shift Left Logical | R[rd] = R[rt] << shamt",
        "SLT": "Set Less Than | R[rd] = (R[rs] < R[rt]) ? 1 : 0",
        "SLTI": "Set Less Than Imm. | R[rt] = (R[rs] < SignExtImm) ? 1 : 0",
        "SLTIU": "Set Less Than Imm. Unsigned | R[rt] = (R[rs] < SignExtImm) ? 1 : 0",
        "SLTU": "Set Less Than Unsig. | R[rd] = (R[rs] < R[rt]) ? 1 : 0",
        "SRA": "Shift Right Arithmetic | R[rd] = R[rt] >> shamt",
        "SRL": "Shift Right Logical | R[rd] = R[rt] >>> shamt",
        "SUB": "Subtract | R[rd] = R[rs] - R[rt]",
        "SUBU": "Subtract Unsigned | R[rd] = R[rs] - R[rt]",
        "SW": "Store Word | M[R[rs]+SignExtImm] = R[rt]"
    };

    const instrKeys = Object.keys(instructions);

    // Populate the instruction count
    document.getElementById('instr-count').textContent = instrKeys.length;

    // Populate the instruction grid dynamically
    const grid = document.getElementById('instruction-grid');
    
    // Sort instructions alphabetically for better UX
    instrKeys.sort().forEach((instr, index) => {
        const tag = document.createElement('div');
        tag.className = 'instruction-tag';
        tag.textContent = instr;
        tag.setAttribute('data-tooltip', instructions[instr]);
        
        // Add a stagger animation effect
        tag.style.opacity = '0';
        tag.style.animation = `fadeIn 0.5s ease forwards ${0.3 + (index * 0.02)}s`;
        
        grid.appendChild(tag);
    });
});
