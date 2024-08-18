// Code your testbench here
// or browse Examples


//`timescale 1ns / 1ps

module Slave_TB ();

  reg clk;
  
  wire SDA;
  wire SCL;
  
  pullup(SDA);
  pullup(SCL);
  
  reg [6:0] addressToSend 	= 7'b1000111; 	//101_1011
  reg readWite 				= 1'b0; 		//write
  reg [7:0] dataToSend 		= 8'b0110_0111; //103 = 0x67
  
  wire ack_bit;
  wire [7:0] out;
  reg rst;
  integer ii=7;

  initial begin
		clk = 1;
    	force SCL = clk;
    #5
		forever begin
			#10 clk =  ~clk;
          	force SCL = clk;
		end		
	end

  
  i2c_slave UUT
    (.SDA(SDA),
     .SCL(SCL),
     .RST(rst),
     .ack_bit(ack_bit),
     .out(out)
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
          $display("Data SDA %h to %h", SDA, dataToSend[ii]);
          #20 force SDA = dataToSend[ii];
        end
      
      #20;force SDA =0; // Wait for ACK bit
      
       // Next SDA will be driven by slave, so release it
      //release SDA;
      force SDA = 0;
      #10 
      
      // Force SDA high again, we are done
     force SDA = 1;
      #200;
      $finish();
    end
  
  initial 
  begin
    // Required to dump signals to EPWave
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  
endmodule
