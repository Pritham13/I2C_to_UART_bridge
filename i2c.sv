//TODO decide the state table for recieving bits
module i2c_recv (
  inout SCL,
  inout SDA,
  output [6:0]data
);

reg detect_flag = 1'd0;
parameter device_addr = 7'h77;
reg SDA_prev;
always @(posedge SCL)
  begin
    SDA_prev<=SDA;
    detect_flag<=(SDA_prev | SDA) & SCL;
  end
endmodule
