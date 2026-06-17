// the register file - 2 read, 1 write
`include "cpu_params.vh"

module regfile
  #(
   parameter BITS = 32,
   parameter WORDS = 32,
   parameter REG_ADDR_LEFT = $clog2(WORDS)-1
   )
   (

   output [BITS-1:0] r1_data,          // read value 1
   output [BITS-1:0] r2_data,          // read value 2

   input                       clk,           // system clock
   input                       rw_,           // read=1, write=0
   input		               rst_,
   input  [BITS-1:0]           wdata,         // data to write
   input  [REG_ADDR_LEFT:0]    waddr,         // write address
   input  [REG_ADDR_LEFT:0]    r1_addr,       // read address 1
   input  [REG_ADDR_LEFT:0]    r2_addr,       // read address 2
   input  [3:0]                byte_en        // byte enables
   );

	reg [BITS-1:0] mem[0:WORDS-1]; // default creates 32 32-bit words

	assign r1_data = mem[r1_addr];

	assign r2_data = mem[r2_addr];
	
	always@(posedge clk or negedge rst_)begin
		if(!rst_) begin
			for ( integer index = 0 ; index < WORDS ; index++ )
				mem[index] <= { BITS { 1'b0 } };
			end
		else if(!rw_ && (waddr != {BITS{1'b0}}))begin
			case(byte_en)
                		4'b0001:mem[waddr] <= {24'b0,wdata[7:0]};

                		4'b0011:mem[waddr] <= {16'b0,wdata[15:0]};
						
						//4'b1100:mem[waddr] <= {wdata[31:16],16'b0};

                		4'b1111:mem[waddr] <= wdata;
            		endcase	
		end

	end

endmodule
//rf

