`include "../i2c_modules/i2c_recv.v"
`include "../uart_module/uart_tx.v"
`include "../fifo_module/fifo.v"
module top (
  input i_SCL, i_SDA,
  input i_reset,
  output o_TX
);
  reg r_uart_en;
  
  
  // Internal signals
  
  wire [7:0] w_i2c_buffer;
  wire [7:0] w_uart_buff;
  wire w_en_write;
  wire w_en_read;
  wire w_underflow;  
  wire w_o_Tx_Done;
  wire w_o_Tx_Active;
  //assignments 
  assign  w_en_read = (w_o_Tx_Done | w_en_write) & (~w_o_Tx_Active);
// flip flop delay
always @(posedge i_SCL) begin
  r_uart_en <= ~w_underflow;
end
//instanstiations
i2c_slave i2c (
          .i_SDA(i_SDA),
          .i_SCL(i_SCL),
          .i_RST(i_reset),
          .o_ack_bit(w_en_write),
          .o_out(w_i2c_buffer)
          );
fifo fifo (
      .i_data(w_i2c_buffer),
      .en_write(w_en_write),
      .en_read(w_en_read),
      .overflow(),
      .underflow(w_underflow),
      .o_data(w_uart_buff),
      .reset(i_reset),
      .clk(i_SCL)
      );
uart_tx uart (
              .i_Clock(i_SCL),
              .i_Tx_DV(r_uart_en),
              .i_Tx_Byte(w_uart_buff),
              .o_Tx_Active(w_o_Tx_Active),
              .o_Tx_Serial(o_TX),
              .o_Tx_Done(w_o_Tx_Done)
            );
endmodule
