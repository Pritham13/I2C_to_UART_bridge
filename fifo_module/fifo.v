module fifo (
    input [7:0] i_data,
    input en_read, en_write, reset, clk,
    output  overflow,
    output  reg underflow,
    output reg [7:0] o_data
);

reg [7:0] register [0:15];
reg [4:0] ptr_wr;
integer i;
localparam Size = 16;
localparam Size1 = Size-1;
localparam count = 1;

assign overflow = (ptr_wr != 0) ? 0 : 1;

 // assign underflow = (ptr_wr == 15 && (~(en_write & en_read)) ) ? 1 : 0;

always @ (posedge clk , posedge reset)
    if (en_read && ~reset && ~en_write)
    begin
        if (!underflow)
        begin
            o_data <= register[15];
            for (i = Size1; i > 0; i = i - count)
            begin
                register[i] <= register[i - count];
            end
            ptr_wr <= ptr_wr + 1;
        end
    end

always @(posedge clk) begin 
    underflow <= (ptr_wr == 15 && (~(en_write & en_read)) ) ? 1 : 0;
 end 

always @(posedge clk) begin 
  if(en_read && en_write && ~reset && (ptr_wr == 15 ))
    begin 
      //o_data <= register [ptr_wr];
      o_data <= i_data;
       //register[15] <= i_data;
       //ptr_wr <= 14;
     
    end
end

always @(posedge clk ,posedge reset) 
begin
    if (reset)
    begin
        for (i = 0; i < Size; i = i + count)
        begin
            register[i] = 8'd0; 
        end 
        o_data <= 8'b0;
        ptr_wr <= 4'd15;
        //overflow <= 0;
        //underflow <= 0;
    end 
    else
    begin
       if (en_write && ~en_read)
        begin
            register[ptr_wr] <= i_data;
            if (!overflow)
            begin
                ptr_wr <= ptr_wr - 1;
            end
        end

    end 
end
endmodule
