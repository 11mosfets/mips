// the alu module 

module alu
  #(
   parameter NUM_BITS=32, // default data width
   parameter OP_BITS=4,   // bits needed to define operations
   parameter SHIFT_BITS=5 // bits needed to define shift amount
   )

   (
   output logic [NUM_BITS-1:0] alu_out,     // alu result
   output logic       equal,           // arguments eqaul needed for branches
   output logic       not_equal,       // arguments not equal needed for branches

   input  [NUM_BITS-1:0]   data1,     // two data inputs
   input  [NUM_BITS-1:0]   data2,
   input  [OP_BITS-1:0]    alu_op,    // operation to perform
   input  [SHIFT_BITS-1:0] shamt      // shift amount needed for shifting
   );
    `include "common.vh" // holds the common constant values
    wire [NUM_BITS-1:0]temp;
    assign temp = data1 + (~(data2)+1);
    always_comb begin
      equal <= (data1 == data2);
      not_equal <= (data1 != data2);
      case (alu_op)
	ALU_PASS1:  alu_out <= data1;
        ALU_PASS2:  alu_out <= data2;
        ALU_ADD:  alu_out <= data1 + data2;
        ALU_AND:  alu_out <= data1 & data2;
        ALU_OR:  alu_out <= data1 | data2;
        ALU_NOR:  alu_out <= ~(data1 | data2);
        ALU_SUB:  alu_out <= data1 + (~(data2)+1);
        ALU_SRL:  alu_out <= data2>>shamt;		
        ALU_LTS:  alu_out <= {{NUM_BITS-1{1'b0}}, (data1[NUM_BITS-1] != data2[NUM_BITS-1]) ? data1[NUM_BITS-1] : temp[NUM_BITS-1]};
        ALU_LTU:  alu_out <= (data1<data2);
        ALU_SLL:  alu_out <= data2<<shamt;
        ALU_SRA:  alu_out <= (data2 >> shamt) | ({NUM_BITS{data2[NUM_BITS-1]}} << (NUM_BITS - shamt));
        default: alu_out <= 32'b0;
      endcase
    end

endmodule
