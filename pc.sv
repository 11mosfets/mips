// program counter
`include "common.vh"
module pc
  #(
   parameter BITS=32                  // default number of BITS per word
   )
   (

   output logic [BITS-1:0] pc_addr,      // current instruction address

   input                clk,             // system clock
   input  [BITS-7:0]    addr,            // jump address
   input                rst_,            // system reset
   input                jmp,             // take a jump
   input                load_instr,      // load the next address
   input  [BITS-1:0]    sign_ext_imm,    // branch address
   input                equal,           // values equal for branch
   input                breq,            // doing branch on equal
   input                not_equal,       // values not equal for branch
   input                brne,            // doing branch on not equal
   input                jreg,            // jumping to register value
   input  [BITS-1:0]    r1_data          // value read from register file for jreg
   );
   
   localparam zero = 1'b0;
   localparam one  = 1'b1;
   logic [BITS-1:0] next_addr;
   logic [BITS-1:0] p1_addr;
   assign p1_addr = pc_addr + {{(BITS-1){zero}},one };
   
   assign next_addr = (jmp ? { pc_addr[BITS-1:BITS-4], 2'b0, addr }     : '0) |
       		      (jreg ? r1_data                                   : '0) |
       	     	      ((breq && equal)  ? (pc_addr + sign_ext_imm)      : '0) |
       		      ((brne && not_equal) ? (pc_addr + sign_ext_imm)   : '0) |
       		      ((!jmp && !jreg && !(breq && equal) && !(brne && not_equal)) ? p1_addr : '0);


   always_ff @(posedge clk or negedge rst_) begin
      if (!rst_) begin
        pc_addr <= { BITS {zero} };
      end
      else if (load_instr) begin
        pc_addr <= next_addr;
      end
   end
endmodule
  
 
//pc
