// data memory
//`include "cpu_params.vh"
module memory
  #(
   parameter WORDS=1024,                // default number of words
   parameter BITS=32,                   // default number of bits per word
   parameter BASE_ADDR = 32'h1000	// log base 2 of the number of words
                                        // which is # of bits needed to address
                                        // the memory for read and write
   )
   (

   output [BITS-1:0]       rdata,  // read data

   input                   clk,    // system clock
   input  [BITS-1:0]       wdata,  // data to write
   input                   rw_,    // read=1, write=0
   input  [BITS-1:0]       addr,   // only uses enough bits to access # of words
   input  [3:0]            byte_en // byte enables
   );
	
	reg [BITS-1:0] mem[0:WORDS-1]; // default creates 1024 32-bit words

	localparam ADDR_LEFT=$clog2(WORDS)-1;	

	logic va;

	assign va = (addr>=BASE_ADDR)&&(addr<BASE_ADDR+WORDS);

	always @ ( posedge clk ) begin

		if(!rw_ && va)begin

			case(byte_en)
				4'b0001:mem[addr[ADDR_LEFT:0]] <= {mem[addr[ADDR_LEFT:0]][BITS-1:8],wdata[7:0]};
				4'b0011:mem[addr[ADDR_LEFT:0]] <= {mem[addr[ADDR_LEFT:0]][BITS-1:16],wdata[15:0]};
				4'b1111:mem[addr[ADDR_LEFT:0]] <= wdata;
			endcase
		end
	end
	
	assign rdata = va ? mem[addr[ADDR_LEFT:0]] : { BITS { 1'b0 } };
	

endmodule
//mem

