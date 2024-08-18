module fifo (
    input [7:0] data_in,
    input en_read, en_write, reset, clk,
    output reg overflow, underflow,
    output reg [7:0] data_out
);

reg [7:0] register [0:15];
reg [3:0] ptr_wr;
integer i;
localparam Size = 16;
localparam Size1 = 15;
localparam count = 1;

always @(posedge clk ,posedge reset) 
begin
    if (reset)
    begin
        for (i = 0; i < Size; i = i + count)
        begin
            register[i] = 8'd0; 
        end 
        data_out <= 8'b0;
        ptr_wr <= 4'd15;
        overflow <= 0;
        underflow <= 0;
    end 
    else
    begin
        if (ptr_wr != 4'b0)
            begin
                overflow <= 1'b0;
            end
            else
                overflow <= 1'b1;
        if (ptr_wr==15)
            begin
                underflow<=1;
            end
        else
            begin
                underflow<=0;
            end
        if (en_write)
        begin
            register[ptr_wr] <= data_in;
            if (!overflow)
            begin
                ptr_wr <= ptr_wr - 1;
            end
        end
        if (en_read)
        begin
            if (!underflow)
            begin
                data_out <= register[15];
                for (i = Size1; i > 0; i = i - count)
                begin
                    register[i] <= register[i - count];
                end
                ptr_wr <= ptr_wr + 1;
            end
        end
        else 
        begin
            data_out <= 8'b0;
        end
    end 
end
endmodule
