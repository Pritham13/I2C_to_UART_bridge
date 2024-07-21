module i2c_tb;
  reg scl;
  wire sda;
  wire [7:0] data;
  reg clk_flag = 0;
  parameter addr = 7'h27;

  function automatic void transmit_address (input reg [6:0] addr);
    integer i;
    for (i = 0; i < 7; i = i + 1) begin
      @(negedge scl);
      sda = addr[i];
    end
  endfunction

  function automatic void transmit_data (input reg [7:0] dat);
    integer i;
    for (i = 0; i < 8; i = i + 1) begin
      @(negedge scl);
      sda = dat[i];
    end
  endfunction

  initial begin
    sda = 1;
    scl = 1;
    #10;
    sda = 0;
    clk_flag = 1;
    transmit_address(addr);
    transmit_data(8'd7);  
  end

  always 
    if(clk_flag)
      begin
        scl = ~scl;
        #10;
      end

  i2c_recv(scl, sda, data);

endmodule

