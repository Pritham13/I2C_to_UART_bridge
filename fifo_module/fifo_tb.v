`timescale 1ns / 1ps
//`include "fifo_2.v"

module fifo_tb;

  // Inputs
  reg [7:0] data_in;
  reg en_read, reset, clk, en_write;
  integer i = 0;
  wire underflow, overflow;

  // Outputs
  wire [7:0] data_out;

  // Instantiate the FIFO module
  fifo fifo_inst (
    .i_data(data_in),
    .i_en_read(en_read),
    .i_reset(reset),
    .i_clk(clk),
    .i_en_write(en_write),
    .o_data(data_out),
    .o_underflow(underflow),
    .o_overflow(overflow)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Initial block for test scenarios
  initial begin
    $dumpfile("fifo.vcd");
    $dumpvars(0, fifo_tb);
  end

  // Rest of the initial block
  initial begin
    // Initialize inputs
    clk = 1;
    reset = 1;
    en_read = 0;
    en_write = 0;
    data_in = 8'h00;
    #5
    reset = 0;
    en_read = 0;
    en_write = 1;

    // Use a for loop to generate random values
    for (i = 0; i < 15; i = i + 1) begin
      data_in = $random % 256; // 256 is 2^8
      $display("Random 8-bit Number[%0d]: %h", i, data_in);
      #10;
    end

    en_write = 0;
    #10
    en_read = 1;
    #20
    en_read =0;
    #30;$finish;
  end

endmodule
