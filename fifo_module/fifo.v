module fifo (
    input [7:0] i_data,
    input en_read, en_write, reset, clk,
    output reg overflow, underflow,
    output reg [7:0] o_data
);

reg [7:0] register [0:15];
reg [3:0] ptr_wr;
integer i;
localparam Size = 16;
localparam Size1 = Size-1;
localparam count = 1;

always @ (posedge clk , posedge reset)
    if (en_read && ~reset)
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
always @(en_write , posedge clk) begin 
//   if (ptr_wr==15)
 //           begin
 //               underflow<=1;
 //           end
  //      else
   //         begin
    //            underflow<=0;
     //       end
   underflow <= (ptr_wr == 15 ) ? 1 : 0;
end
always @(posedge (clk|en_write) ,posedge reset) 
begin
    if (reset)
    begin
        for (i = 0; i < Size; i = i + count)
        begin
            register[i] = 8'd0; 
        end 
        o_data <= 8'b0;
        ptr_wr <= 4'd15;
        overflow <= 0;
        //underflow <= 0;
    end 
    else
    begin
        if (ptr_wr != 4'b0)
            begin
                overflow <= 1'b0;
            end
            else
                overflow <= 1'b1;
             if (en_write)
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
