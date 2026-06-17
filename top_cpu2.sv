// test bench for the cpu
module top_cpu2();

   //logic [31:0] rdata;
   logic        halt;
   logic        exception;

   logic         clk;
   logic         rst_;
   logic  [31:0] counter;

   initial // read the array to load the program
   begin
     $readmemh("prog_i.txt",cpu2.i_memory.mem); // loading the i_memory
     /*$readmemh("prog_d.txt",cpu2.d_memory.mem); // loading the d_memory */
     for ( integer ind = 0 ; ind < 5 ; ind = ind+1 )begin
        $display("memory index %d is %h",ind,cpu2.i_memory.mem[ind]);
	end
    /*for ( integer i = 0 ; i < 5 ; i = i+1 )begin
        $display("memory index %d is %h",i,cpu2.d_memory.mem[i]);
	end*/
   end

   cpu2 cpu2( .halt(halt), .exception(exception), .clk(clk), .rst_(rst_) );

   initial
   begin
     clk <= 1'b0;
     rst_ <= 1'b0;
     counter <= 32'h0;
     #10 rst_ <= 1'b1;
     while ( 1 )
     begin
        #10 clk <= 1'b1;
        #10 clk <= 1'b0;
     end
   end

   always @ ( * ) 
   begin 
      if ( ( rst_ == 1'b1 ) && ( exception == 1'b1 ) && ( halt == 1'b0 ) )
      	$display("Illegal Instruction @ cycle %d", counter);
   end

   always @ ( posedge clk ) 
   begin
      if ( halt == 1'b1 )
         $finish;
   end

   always @ ( negedge clk )
   begin
     if ( rst_ == 1'b1 )
       counter <= counter + 1;
     if ((counter>0)&&( halt || exception ))
     begin
       #5;
       $finish;
     end
   end

  final   // dump the regfile to verify things worked
  begin
     for ( integer index = 0 ; index < 32 ; index++ )
        $display("regfile %d is %h",index,cpu2.regfile.mem[index]);
  end

  /*
  initial begin
   $dumpfile("cpu_waves.vcd");      // dump the waves to view on your laptop
   $dumpvars(0,top_cpu2);
  end*/
endmodule
