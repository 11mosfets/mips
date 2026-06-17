// the top level cpu 
module cpu2
   (
   output logic      halt,      // halt signal to end simulation
   output logic      exception, // the exception interupt signal

   input             clk,  // system clock
   input             rst_  // system reset
   );

   `include "cpu_params.vh"

   logic [BITS-1:0]            pc_addr;      // current address
   logic [BITS-1:0]            i_mem_rdata;  // instruction memory read data
   logic [BITS-1:0]            d_mem_rdata;  // data memory read data
   logic [BITS-1:0]            r1_data;      // register file read data 1
   logic [BITS-1:0]            r2_data;      // register file read data 2
   logic [BITS-1:0]            alu_out;      // alu output
   logic [BITS-1:0]            alu_in_1;     // alu input 1
   logic [BITS-1:0]            alu_in_2;     // alu input 2
   logic [REG_ADDR_LEFT:0]     r1_addr;      // register file read addr 1
   logic [REG_ADDR_LEFT:0]     r2_addr;      // register file read addr 2
   logic [REG_ADDR_LEFT:0]     waddr;        // register file write addr
   logic [SHIFT_BITS-1:0]      shamt;        // shift amount
   logic [OP_BITS-1:0]         alu_op;       // alu operation
   logic [IMM_LEFT-1:0]        imm;          // immediate data
   logic [JMP_LEFT:0]          addr;         // jump address to program counter
   logic                       rw_;          // register file read write signal
   logic                       mem_rw_;      // data memory read write signal
   logic                       sel_mem;      // select the output from the memory
   logic                       alu_imm;      // use immediate data for the alu
   logic [BITS-1:0]            reg_wdata;    // data to write to the register file
   logic [BITS-1:0]            sign_ext_imm; // immediate data that has been sign extended
   logic                       signed_ext;   // whether or not to extend the sign bit
   logic [ 3:0]                byte_en;      // byte enables
   logic                       swap;         // swap low 16 bits to high 16 bits
   logic                       load_link_;   // load the link register
   logic                       check_link;   // check if link register is same as address
   logic                       atomic;       // force value to 0 or 1 for atomic operation
   logic                       jmp;          // doing a jump
   logic                       equal;        // values were equal for branches
   logic                       breq;         // doing a branch on equal
   logic                       not_equal;    // values were not equal for branches
   logic                       brne;         // doing o branch o not equal
   logic                       jal;          // doing a jump and link
   logic                       jreg;         // jumping to an address in a register
   logic                       stall;        // stall handling during branch hazards
   logic                       stall_ff;     // ADDED: registered stall signal
   logic [BITS-1:0]            instr_word;   // ADDED: instruction word after NOP insertion
  
   logic [BITS-1:0] 	        return_addr;   // JAL
   logic [BITS-1:0]             swap_alu;      // LUI
   logic [BITS-1:0] 		link_addr;

   logic			 link_valid;

   logic			 link_rw_; 
   logic 			use_mem_rw_; 
   logic 			addr_match; 
   logic [BITS-1:0] 		atomic_result;
   
   localparam [BITS-1:0] NOP = 32'h0000_0020; // add $0,$0,$0

   
   always_ff @(posedge clk or negedge rst_) begin
      if (!rst_)
         stall_ff <= 1'b0;
      else
         stall_ff <= stall;
   end



   //Handle LL and SC
   always_ff @(posedge clk or negedge rst_) begin
	    if (!rst_)
	       link_addr <= '0;
	    else if (!load_link_)
	       link_addr <= alu_out;  
	   end
   

    // Manage link_valid flag
    always_ff @(posedge clk or negedge rst_) begin
		if (!rst_)
	      		 link_valid <= 1'b0;
		 else if (!load_link_)  
	     		 link_valid <= 1'b1;
	  	 else if (check_link)   
	 	         link_valid <= 1'b0;
	  	 else if (!mem_rw_ && (alu_out == link_addr))  
	    		 link_valid <= 1'b0;
    end
    
   assign addr_match = (alu_out == link_addr);
   assign link_rw_ = check_link && (!link_valid || !addr_match);
   assign use_mem_rw_ = mem_rw_ | link_rw_;
   assign atomic_result = {31'b0, ~link_rw_};  
   assign instr_word = stall ? NOP : i_mem_rdata;

   assign return_addr = pc_addr + 1;   //JAL
   assign swap_alu = {alu_out[15:0], 16'b0};//LUI 

   // the program counter
   pc #(.BITS(BITS) ) pc (
          .pc_addr(pc_addr), .clk(clk), .addr(addr), .rst_(rst_),
          .jmp(jmp), .load_instr(1'b1), .sign_ext_imm(sign_ext_imm),
          .equal(equal), .not_equal(not_equal), .breq(breq), .brne(brne),
          .jreg(jreg), .r1_data(r1_data) );

   // the  i-memory
   memory #( .BASE_ADDR(I_MEM_BASE_ADDR), .BITS(BITS), .WORDS(I_MEM_WORDS) ) i_memory(
       .rdata(i_mem_rdata), .clk(clk), .wdata(32'b0), .rw_(1'b1),
       .addr(pc_addr), .byte_en(4'b0) );
    


   instr_reg #( .BITS(BITS), .REG_WORDS(REG_WORDS), .OP_BITS(OP_BITS),
                .SHIFT_BITS(SHIFT_BITS), .JMP_LEFT(JMP_LEFT) ) instr_reg (
       .r1_addr(r1_addr), .r2_addr(r2_addr), .waddr(waddr),
       .jal(jal), .jreg(jreg), .exception(exception),
       .shamt(shamt), .alu_op(alu_op), .imm(imm), .addr(addr),
       .rw_(rw_), .sel_mem(sel_mem), .alu_imm(alu_imm),
       .signed_ext(signed_ext), .byte_en(byte_en), .halt(halt),
       .clk(clk), .load_instr(1'b1), .mem_rw_(mem_rw_), .swap(swap),
       .load_link_(load_link_), .check_link(check_link),
       .atomic(atomic), .jmp(jmp), .breq(breq), .equal(equal), 
       .brne(brne), .not_equal(not_equal),
       .mem_data(instr_word), .rst_(rst_), .stall(stall));

   // select the data to write to the register file:
   // from data memory or atomic value (write a 0 or 1) or swapped else from the alu
   assign reg_wdata = atomic ? atomic_result:
		        (jal ? return_addr : 
                        (swap ? swap_alu : 
                        (sel_mem ? d_mem_rdata : alu_out)));

   // the reg file
   regfile #( .WORDS(REG_WORDS), .BITS(BITS) ) regfile(
       .r1_data(r1_data), .r2_data(r2_data), .clk(clk), .rst_(rst_),
       .rw_(rw_), .wdata(reg_wdata), .waddr(waddr),
       .r1_addr(r1_addr), .r2_addr(r2_addr), .byte_en(byte_en) ); 

      
   assign sign_ext_imm = signed_ext ? {{(BITS-IMM_LEFT){imm[IMM_LEFT-1]}}, imm} : 
				      {{(BITS-IMM_LEFT){1'b0}}, imm}; // do sign extension
   assign alu_in_1 = r1_data;   // always r1_data
   assign alu_in_2 = alu_imm ? sign_ext_imm : r2_data;  // need sign extended version?

   // the alu
   alu #( .NUM_BITS(BITS), .OP_BITS(OP_BITS), .SHIFT_BITS(SHIFT_BITS) ) alu (
       .alu_out(alu_out), .equal(equal), .not_equal(not_equal), 
       .data1(alu_in_1), .data2(alu_in_2), 
       .alu_op(alu_op), .shamt(shamt) );

   // the d-memory
   memory #( .BASE_ADDR(D_MEM_BASE_ADDR), .BITS(BITS), .WORDS(D_MEM_WORDS) ) d_memory (
        .rdata(d_mem_rdata), .clk(clk), .wdata(r2_data),
        .rw_(use_mem_rw_), .addr(alu_out), .byte_en(byte_en) );


endmodule

