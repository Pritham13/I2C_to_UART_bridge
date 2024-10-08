
`timescale 1ns / 1ps

module top_tb ();

  reg clk;
  
  wire SDA;
  wire SCL;

  pullup(SDA);
  pullup(SCL);
  

   
  reg [6:0] addressToSend 	= 7'b1000111; 	//101_1011
  reg readWite 				= 1'b0; 		//write
  reg [7:0] dataToSend1 		= 8'b0110_0111; //103 = 0x67
  reg [7:0] dataToSend2 		= 8'd20; 
  reg [7:0] dataToSend3 		= 8'd30; 
  reg rst;

  wire ack_bit;
  wire [7:0] out;
  wire TX;

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

  
  top UUT
    (.i_SDA(SDA),
     .i_SCL(SCL),
     .i_reset(rst),
     .o_TX(TX)
    );

  initial 
    begin
    $display("Starting Testbench...");
      
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

          force SDA = addressToSend[ii];#20;
        
        end
      
      $display("Read/Write %h SDA: %h", readWite, SDA);
      
       force SDA = readWite;
      
      #20 force SDA = 0;
      
      $display("SDA: %h", SDA);
      
      for(ii=7; ii>=0; ii=ii-1)
        begin
      
          #20 force SDA = dataToSend1[ii];
      
        end 
      
      #20;force SDA =0;

            
      for(ii=7; ii>=0; ii=ii-1)
        begin
      
          #20 force SDA = dataToSend2[ii];
      
        end
      
      #20;force SDA =0;            
      
      for(ii=7; ii>=0; ii=ii-1)
        begin
      
          #20 force SDA = dataToSend3[ii];
      
        end 

      #20;force SDA =0; 
      
      #30 
      //changing SDA to 1 when SCL is 1 to stop
     force SDA = 1;
      //delay for uart to transmit
      
      #1000;
      $finish();
    end
  
  initial 
  begin
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  
endmodule
