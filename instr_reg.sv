module instr_reg #(
   parameter BITS=32,
   parameter REG_WORDS=32,
   parameter ADDR_LEFT=$clog2(REG_WORDS)-1,
   parameter OP_BITS=4,
   parameter SHIFT_BITS=5,
   parameter JMP_LEFT=25,
   parameter IMM_LEFT=BITS/2
)(
   output logic [ADDR_LEFT:0]    r1_addr,      
   output logic [ADDR_LEFT:0]    r2_addr,      
   output logic [ADDR_LEFT:0]    waddr,        
   output logic [SHIFT_BITS-1:0] shamt,        
   output logic [OP_BITS-1:0]    alu_op,       
   output logic [IMM_LEFT-1:0]   imm,          
   output logic [JMP_LEFT:0]     addr,         
   output logic                  rw_,          
   output logic                  mem_rw_,      
   output logic                  sel_mem,      
   output logic                  alu_imm,      
   output logic                  signed_ext,   
   output logic [ 3:0]           byte_en,      
   output logic                  halt,         
   output logic                  swap,         
   output logic                  load_link_,   
   output logic                  check_link,   
   output logic                  atomic,       
   output logic                  jmp,          
   output logic                  breq,         
   output logic                  brne,         
   output logic                  jal,          
   output logic                  jreg,         
   output logic                  exception,    
   output logic                  stall,        // CHANGED: Output, not input!
   input                         clk,          
   input                         load_instr,   
   input  [BITS-1:0]            mem_data,     
   input                         rst_,         
   input                         equal,        
   input                         not_equal
);

   `include "common.vh"
   `include "instr_reg_params.vh"

   localparam CODE_BITS = 6;
   localparam FUNC_BITS = 6;
   localparam NUM_REG_BITS = 5;
   
   localparam OP_LEFT = 31;      // Opcode: bits [31:26]
   localparam RS_LEFT = 25;      // Rs: bits [25:21]
   localparam RT_LEFT = 20;      // Rt: bits [20:16]
   localparam RD_LEFT = 15;      // Rd: bits [15:11]
   localparam SH_LEFT = 10;      // Shamt: bits [10:6]
   localparam FU_LEFT = 5;       // Funct: bits [5:0]

  
   logic [BITS-1:0]         instr;
   logic [CODE_BITS-1:0]    opcode;
   logic [FUNC_BITS-1:0]    funct_field;
   logic [ADDR_LEFT:0]      rs;
   logic [ADDR_LEFT:0]      rt;
   logic [ADDR_LEFT:0]      rd;
   logic [IMM_LEFT-1:0]     immediate;

   localparam [BITS-1:0] NOP = 32'h0000_0020; // add $0,$0,$0

  
   always_ff @(posedge clk or negedge rst_) begin
      if (!rst_)
         instr <= NOP;  // CHANGED: Use valid NOP
      else if (load_instr)
         instr <= mem_data;
   end

   always_comb begin
      opcode      = instr[OP_LEFT -: CODE_BITS];      // [31:26]
      rs          = instr[RS_LEFT -: NUM_REG_BITS];   // [25:21]
      rt          = instr[RT_LEFT -: NUM_REG_BITS];   // [20:16]
      rd          = instr[RD_LEFT -: NUM_REG_BITS];   // [15:11]
      funct_field = instr[FU_LEFT -: FUNC_BITS];      // [5:0]
      immediate   = instr[IMM_LEFT-1:0];              // [15:0]
      
      // Output extracted fields
      shamt   = instr[SH_LEFT -: SHIFT_BITS];
      addr    = instr[JMP_LEFT:0];
      imm     = immediate;
   end

   
   always_comb begin
      // DEFAULT VALUES 
      rw_        = 1'b1;       // Default: don't write register
      mem_rw_    = 1'b1;       // Default: don't write memory
      alu_op     = ALU_PASS1;  
      alu_imm    = 1'b0;       // Default: ALU uses r2_data
      sel_mem    = 1'b0;       // Default: write ALU result
      signed_ext = 1'b0;       // Default: zero-extend
      halt       = 1'b0;
      byte_en    = 4'hF;
      waddr      = '0;
      swap       = 1'b0;
      load_link_ = 1'b1;
      check_link = 1'b0;
      atomic     = 1'b0;
      jmp        = 1'b0;
      breq       = 1'b0;
      brne       = 1'b0;
      jal        = 1'b0;
      jreg       = 1'b0;
      exception  = 1'b0;
      stall      = 1'b0;       // ADDED: Initialize stall
      
      // CHANGED: Initialize register addresses to 0
      r1_addr    = '0;
      r2_addr    = '0;

      // DECODE BASED ON OPCODE
      case (opcode)
         // R-TYPE:
         6'h00: begin
            case (funct_field)
               6'h00: begin  // SLL: rd = rt << shamt
                  rw_ = 1'b0;
                  alu_op = ALU_SLL;
                  r2_addr = rt;  // CHANGED: Only rt is used
                  waddr = rd;
               end
               
               6'h02: begin  // SRL: rd = rt >> shamt
                  rw_ = 1'b0;
                  alu_op = ALU_SRL;
                  r2_addr = rt;  // CHANGED: Only rt is used
                  waddr = rd;
               end
               
               6'h03: begin  // SRA: rd = rt >>> shamt (arithmetic)
                  rw_ = 1'b0;
                  alu_op = ALU_SRA;
                  r2_addr = rt;  // CHANGED: Only rt is used
                  waddr = rd;
               end
               
               // ADDED: JR instruction
               6'h08: begin  // JR: PC = rs
                  jreg = 1'b1;
                  r1_addr = rs;
                  stall = 1'b1;
	
               end
               
               6'h20: begin  // ADD: rd = rs + rt
                  rw_ = 1'b0;
                  alu_op = ALU_ADD;
                  r1_addr = rs;  // ADDED: Explicit assignment
                  r2_addr = rt;  // ADDED: Explicit assignment
                  waddr = rd;
               end
               
               6'h21: begin  // ADDU: rd = rs + rt
                  rw_ = 1'b0;
                  alu_op = ALU_ADD;
                  r1_addr = rs;  // ADDED: Explicit assignment
                  r2_addr = rt;  // ADDED: Explicit assignment
                  waddr = rd;
               end
               
               6'h22: begin  // SUB: rd = rs - rt
                  rw_ = 1'b0;
                  alu_op = ALU_SUB;
                  r1_addr = rs;  // ADDED: Explicit assignment
                  r2_addr = rt;  // ADDED: Explicit assignment
                  waddr = rd;
               end
               
               6'h23: begin  // SUBU: rd = rs - rt
                  rw_ = 1'b0;
                  alu_op = ALU_SUB;
                  r1_addr = rs;  // ADDED: Explicit assignment
                  r2_addr = rt;  // ADDED: Explicit assignment
                  waddr = rd;
               end
               
               6'h24: begin  // AND: rd = rs & rt
                  rw_ = 1'b0;
                  alu_op = ALU_AND;
                  r1_addr = rs;  // ADDED: Explicit assignment
                  r2_addr = rt;  // ADDED: Explicit assignment
                  waddr = rd;
               end
               
               6'h25: begin  // OR: rd = rs | rt
                  rw_ = 1'b0;
                  alu_op = ALU_OR;
                  r1_addr = rs;  // ADDED: Explicit assignment
                  r2_addr = rt;  // ADDED: Explicit assignment
                  waddr = rd;
               end
               
               6'h27: begin  // NOR: rd = ~(rs | rt)
                  rw_ = 1'b0;
                  alu_op = ALU_NOR;
                  r1_addr = rs;  // ADDED: Explicit assignment
                  r2_addr = rt;  // ADDED: Explicit assignment
                  waddr = rd;
               end
              
	   6'h2A: begin  //SLT
              rw_ = 1'b0;
              alu_op = ALU_LTS;
              alu_imm = 1'b0;
              r1_addr = rs;
              r2_addr = rt;
              waddr = rd;
           end

          6'h2B: begin  //SLTU

              rw_ = 1'b0;
              alu_op = ALU_LTU;
              alu_imm = 1'b0;
              r1_addr = rs;
              r2_addr = rt;
              waddr = rd;

          end
 
              default: begin
                  exception = 1'b1;
                  halt = 1'b1;
               end
            endcase
         end
         
         // J-TYPE: Jump
         6'h02: begin  // ADDED: J instruction
            jmp = 1'b1;
            stall = 1'b1;
         end

	6'h03: begin  // JAL instruction
	   jmp = 1'b1;
	   jal = 1'b1;
	  // stall = 1'b1;
	   waddr = 5'd31;  // Write to $ra
  	   rw_ = 1'b0;  
	end
         
         // I-TYPE: Branches
         6'h04: begin  // BEQ: if (rs == rt) branch
            breq = 1'b1;
            signed_ext = 1'b1;
            r1_addr = rs;
  	    r2_addr = rt;
	    stall  = equal; 
         end
         
         6'h05: begin  // BNE: if (rs != rt) branch
            brne = 1'b1;
            signed_ext = 1'b1;
	    r1_addr = rs;
   	    r2_addr = rt;
            stall = not_equal;

         end

         // I-TYPE: Arithmetic (SIGN-EXTEND immediate)
         6'h08: begin  // ADDI: rt = rs + imm
            rw_ = 1'b0;
            alu_op = ALU_ADD;
            alu_imm = 1'b1;
            signed_ext = 1'b1;  // SIGN extend
            r1_addr = rs;       // ADDED: Explicit assignment
            waddr = rt;
         end
         
         6'h09: begin  // ADDIU: rt = rs + imm
            rw_ = 1'b0;
            alu_op = ALU_ADD;
            alu_imm = 1'b1;
            signed_ext = 1'b1;  // SIGN extend
            r1_addr = rs;       // ADDED: Explicit assignment
            waddr = rt;
         end

         // I-TYPE: Logical (ZERO-EXTEND immediate)
         6'h0c: begin  // ANDI: rt = rs & imm
            rw_ = 1'b0;
            alu_op = ALU_AND;
            alu_imm = 1'b1;
            signed_ext = 1'b0;  // ZERO extend!
            r1_addr = rs;       // ADDED: Explicit assignment
            waddr = rt;
         end
         
         6'h0d: begin  // ADDED: ORI: rt = rs | imm
            rw_ = 1'b0;
            alu_op = ALU_OR;
            alu_imm = 1'b1;
            signed_ext = 1'b0;  // ZERO extend!
            r1_addr = rs;
            waddr = rt;
         end

	6'h0A: begin  // SLTI
	    rw_ = 1'b0;
            alu_op = ALU_LTS;
            alu_imm = 1'b1;
            signed_ext = 1'b1;  // SIGN extend
            r1_addr = rs;       
            waddr = rt;
         end

	 6'h0B: begin  // SLTIU
            rw_ = 1'b0;
            alu_op = ALU_LTU;
            alu_imm = 1'b1;
            signed_ext = 1'b1;  // SIGN extend
            r1_addr = rs;    
            waddr = rt;
         end
 
	 6'h0f: begin  // LUI: $rt = {imm, 16'b0}
            rw_ = 1'b0;          //  write register
            alu_imm = 1'b1;
            signed_ext = 1'b0;
            waddr = rt;
	    alu_op = ALU_PASS2;
	    swap = 1'b1;
         end

         
         // I-TYPE: Memory Access
         6'h23: begin  // ADDED: LW: rt = mem[rs + offset]
            rw_ = 1'b0;          // Write to register
            mem_rw_ = 1'b1;      // Read from memory
            alu_op = ALU_ADD;    // Address = rs + offset
            alu_imm = 1'b1;
            signed_ext = 1'b1;
            sel_mem = 1'b1;      // Write data from memory!
            r1_addr = rs;
            waddr = rt;
         end
         
         6'h2b: begin  // SW: mem[rs + offset] = rt
            rw_ = 1'b1;          // Don't write register
            mem_rw_ = 1'b0;      // Write to memory
            alu_op = ALU_ADD;    // Address = rs + offset
            alu_imm = 1'b1;
            signed_ext = 1'b1;
            r1_addr = rs;        // ADDED: Explicit assignment
            r2_addr = rt;        // ADDED: Explicit assignment
         end
	
	6'h24: begin // LBU
   	    rw_ = 1'b0;
            mem_rw_ = 1'b1;
	    alu_op = ALU_ADD;
	    alu_imm = 1'b1;
	    signed_ext = 1'b1; 
	    sel_mem = 1'b1;
	    r1_addr = rs;
	    waddr = rt;
	    byte_en = 4'b0001;
	end

	6'h25: begin // LHU
	   rw_ = 1'b0;
	   mem_rw_ = 1'b1;
	   alu_op = ALU_ADD;
	   alu_imm = 1'b1;
	   signed_ext = 1'b1;
	   sel_mem = 1'b1;
	   r1_addr = rs;
	   waddr = rt;
	   byte_en = 4'b0011;
	end

	6'h28: begin // SB
	   rw_ = 1'b1;
	   mem_rw_ = 1'b0;
	   alu_op = ALU_ADD;
	   alu_imm = 1'b1;
	   signed_ext = 1'b1;  
	   r1_addr = rs;
	   r2_addr= rt;
	   byte_en = 4'b0001;
	end

	6'h29: begin // SH
	   rw_ = 1'b1;
	   mem_rw_ = 1'b0;
	   alu_op = ALU_ADD;
	   alu_imm = 1'b1;
	   signed_ext = 1'b1; 
	   r1_addr = rs;
	   r2_addr= rt;
	   byte_en = 4'b0011;
	end


	6'h30: begin  // LL
            rw_ = 1'b0;          
            mem_rw_ = 1'b1;    
            alu_op = ALU_ADD;    
            alu_imm = 1'b1;
            signed_ext = 1'b1;
            sel_mem = 1'b1;    
            r1_addr = rs;
            waddr = rt;
            load_link_ = 1'b0;  
	end
        
	6'h38: begin  // SC
	  rw_ = 1'b0;        
  	  mem_rw_ = 1'b0;     
	  alu_op = ALU_ADD;  
	  alu_imm = 1'b1;
	  signed_ext = 1'b1;
	  r1_addr = rs;     
	  r2_addr = rt; 
	  waddr = rt;      
	  check_link = 1'b1;  
	  atomic = 1'b1;     
	end
         
	
         6'h3f: begin//halt
            halt = 1'b1;
         end
         
         default: begin
            exception = 1'b1;
            halt = 1'b1;
         end
      endcase
   end
endmodule

