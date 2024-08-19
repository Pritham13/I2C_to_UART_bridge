`include "../i2c_modules/i2c_recv.v"
`include "../uart_module/uart_tx.v"
`include "../fifo_module/fifo.v"

module top (
  input SCL,SDA,
  input reset,
  output TX
);
  reg uart_en;
  
  
  // Internal signals
  
  wire [7:0] i2c_buffer;
  wire [7:0] uart_buff;
  wire en_write;
  wire en_read;
  wire underflow;  
  wire o_Tx_Done;
  wire o_Tx_Active;

  //assignments 

  assign  en_read = (o_Tx_Done | en_write) & (~o_Tx_Active);

// flip flop delay
always @(posedge SCL) begin
  uart_en <= ~underflow;
end

//instanstiations

i2c_slave i2c (
          .SDA(SDA),
          .SCL(SCL),
          .RST(reset),
          .ack_bit(en_write),
          .out(i2c_buffer)
          );

fifo fifo (
      .i_data(i2c_buffer),
      .en_write(en_write),
      .en_read(en_read),
      .overflow(),
      .underflow(underflow),
      .o_data(uart_buff),
      .reset(reset),
      .clk(SCL)
      );


uart_tx uart (
              .i_Clock(SCL),
              .i_Tx_DV(uart_en),
              .i_Tx_Byte(uart_buff),
              .o_Tx_Active(o_Tx_Active),
              .o_Tx_Serial(TX),
              .o_Tx_Done(o_Tx_Done)
            );

endmodule
