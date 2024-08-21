module fifo (
    input [7:0] i_data,
    input i_en_read, i_en_write, i_reset, i_clk,
    output o_overflow,
    output reg o_underflow,
    output reg [7:0] o_data
);
reg [7:0] r_register [0:15];
reg [4:0] r_ptr_wr;
integer r_i;
localparam s_Size = 16;
localparam s_Size1 = s_Size-1;
localparam s_count = 1;
assign o_overflow = (r_ptr_wr != 0) ? 0 : 1;
 // assign o_underflow = (r_ptr_wr == 15 && (~(i_en_write & i_en_read)) ) ? 1 : 0;
always @ (posedge i_clk , posedge i_reset)
    if (i_en_read && ~i_reset && ~i_en_write)
    begin
        if (!o_underflow)
        begin
            o_data <= r_register[15];
            for (r_i = s_Size1; r_i > 0; r_i = r_i - s_count)
            begin
                r_register[r_i] <= r_register[r_i - s_count];
            end
            r_ptr_wr <= r_ptr_wr + 1;
        end
    end
always @(posedge i_clk) begin 
    o_underflow <= (r_ptr_wr == 15 && (~(i_en_write & i_en_read)) ) ? 1 : 0;
 end 
always @(posedge i_clk) begin 
  if(i_en_read && i_en_write && ~i_reset && (r_ptr_wr == 15 ))
    begin 
      //o_data <= r_register [r_ptr_wr];
      o_data <= i_data;
       //r_register[15] <= i_data;
       //r_ptr_wr <= 14;
     
    end
end
always @(posedge i_clk ,posedge i_reset) 
begin
    if (i_reset)
    begin
        for (r_i = 0; r_i < s_Size; r_i = r_i + s_count)
        begin
            r_register[r_i] = 8'd0; 
        end 
        o_data <= 8'b0;
        r_ptr_wr <= 4'd15;
        //o_overflow <= 0;
        //o_underflow <= 0;
    end 
    else
    begin
       if (i_en_write && ~i_en_read)
        begin
            r_register[r_ptr_wr] <= i_data;
            if (!o_overflow)
            begin
                r_ptr_wr <= r_ptr_wr - 1;
            end
        end
    end 
end
endmodule
