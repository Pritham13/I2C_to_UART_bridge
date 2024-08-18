
`timescale 1ns / 1ps

module top_tb ();

  reg clk;
  
  wire SDA;
  wire SCL;
   parameter c_CLOCK_PERIOD_NS = 100;
  parameter c_CLKS_PER_BIT    = 87;
  parameter c_BIT_PERIOD      = 8600;
   
reg r_Clock = 0;
  
  pullup(SDA);
  pullup(SCL);
  
  always
    #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;
 
   
  reg [6:0] addressToSend 	= 7'b1000111; 	//101_1011
  reg readWite 				= 1'b0; 		//write
  reg [7:0] dataToSend1 		= 8'b0110_0111; //103 = 0x67
  reg [7:0] dataToSend2 		= 8'd20; 
   reg [7:0] dataToSend3 		= 8'd30; 
 wire ack_bit;
  wire [7:0] out;
  reg rst;
  integer ii=7;
  wire TX;
  initial begin
		clk = 1;
    	force SCL = clk;
    #5
		forever begin
			#10 clk =  ~clk;
          	force SCL = clk;
		end		
	end

  
  top UUT
    (.SDA(SDA),
     .SCL(SCL),
     .reset(rst),
     .clk(r_Clock),
     .TX(TX)
    );

  initial 
    begin
      $display("Starting Testbench...");
      
//       clk = 1 ;
//       force SCL = clk;
      rst = 1 ;
      #5;
      rst = 0;
      #5;
      // Set SDA Low to start
      force SDA = 0;
      #10;
      // Write address
      for(ii=6; ii>=0; ii=ii-1)
        begin
         // $display("Address SDA %h to %h", SDA, addressToSend[ii]);
          force SDA = addressToSend[ii];#20;
        end
      // Are we wanting to read or write to/from the device?
      $display("Read/Write %h SDA: %h", readWite, SDA);
       force SDA = readWite;
      // Next SDA will be driven by slave, so release it
      //release SDA;
      #20 force SDA = 0;
      $display("SDA: %h", SDA);
      //#20; // Wait for ACK bit
      for(ii=7; ii>=0; ii=ii-1)
        begin
      //    $display("Data SDA %h to %h", SDA, dataToSend[ii]);
          #20 force SDA = dataToSend1[ii];
        end 
#20;force SDA =0;

            
      for(ii=7; ii>=0; ii=ii-1)
        begin
 //         $display("Data SDA %h to %h", SDA, dataToSend[ii]);
          #20 force SDA = dataToSend2[ii];
        end
      
      #20;force SDA =0; // Wait for ACK bit
            
      for(ii=7; ii>=0; ii=ii-1)
        begin
   //       $display("Data SDA %h to %h", SDA, dataToSend[ii]);
          #20 force SDA = dataToSend3[ii];
        end 

#20;force SDA =0; 
#30 
      
      // Force SDA high again, we are done
     force SDA = 1;
      #1000;
      $finish();
    end
  
  initial 
  begin
    // Required to dump signals to EPWave
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  
endmodule
