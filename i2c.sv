module i2c_recv (
  inout SCL,
  inout SDA,
  output [6:0]data
);

reg detect_flag = 1'd0;
reg addr_verified = 1'd0;
reg [2:0]count=3'd0;
reg [6:0] addr_buffer;
parameter device_addr = 7'h77;
reg SDA_prev;

// Start bit detection
always @(posedge SCL,SDA)
  begin
    SDA_prev<=SDA;
    detect_flag<=(SDA_prev | SDA) & SCL;
  end

// address confirmation
always@(negedge SCL, SDA) 
begin
  if((count!=3'd7)&& !addr_verified && detect_flag )
  begin
    addr_buffer[count]<= SDA;
    count <= count + 7'd1;
  end
  else if (count == 3'd7 && (addr_buffer == device_addr))
  begin
    count<=3'd0;
    addr_buffer<=7'd0;
    addr_verified <=1'd1;
  end

endmodule
