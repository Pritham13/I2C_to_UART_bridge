// TODO work on the changes to the communication start detection
module i2c_recv (
  input SCL,
  inout  SDA,
  output reg [7:0]data
);

reg detect_flag = 1'd0;
reg addr_verified = 1'd0;
reg [2:0]addr_count=3'd0;
reg [2:0]data_count = 3'd0;
reg [7:0] addr_buffer;
reg [7:0]data_buffer;
parameter device_addr = 7'h27;
reg SDA_prev;
reg SDA_drv = 1'd1;

// driving SDA
assign SDA = SDA_drv ? 1'd0 : SDA ;
// Start bit detection
always @(posedge SCL,SDA)
  begin
    SDA_prev<=SDA;
    detect_flag<=(SDA_prev | SDA)&SCL;
  end

// address confirmation
always@(negedge SCL, SDA) 
begin
  if((addr_count!=3'd7)&& !addr_verified && detect_flag )
  begin
    addr_buffer[addr_count]<= SDA;
    addr_count <= addr_count + 7'd1;
  end
  else if (addr_count == 3'd7 && (addr_buffer == device_addr))
  begin
    addr_count<=3'd0;
    addr_buffer<=7'd0;
    addr_verified <=1'd1;
  end
  //data incoming detection 
  if ((data_count != 3'd7) && addr_verified && detect_flag)
  begin
    SDA_drv <=1;
    data_count <=data_count + 1;
    data_buffer[data_count] <= SDA;
  end
  else if(data_count ==  3'd7) begin
    SDA_drv <=0;
    data<= data_buffer;
    data_buffer <= 7'd0;
  end 
end 
endmodule
