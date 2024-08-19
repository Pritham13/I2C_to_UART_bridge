module i2c_slave(
  input i_SCL, i_RST,
  input i_SDA,
  output o_ack_bit,
  output [7:0] o_out 
);
parameter [6:0] device_address = 7'b1000111;
parameter [1:0] s_STATE_IDLE      = 2'd0,//idle
                s_STATE_DEV_ADDR  = 2'd1,//addr match
                s_STATE_READ      = 2'd2,//the op=read 
                s_STATE_WRITE     = 2'd3;//write data
wire w_start_rst;
wire w_stop_rst;
wire w_address_detect;
wire w_read_write_bit;
wire w_write_strobe;
wire [6:0] w_addr_buffer;
wire [7:0] w_out_buffer;
reg r_addr_act_bit;
reg r_start_detect;
reg r_start_resetter;
reg r_stop_detect;
reg r_stop_resetter;
reg [2:0] r_state;
reg [8:0] r_buffer;
reg [3:0] r_bit_counter;
// Assignments
assign w_start_rst = i_RST | r_start_resetter; // Detect the START for one cycle
assign w_stop_rst = i_RST | r_stop_resetter;   // Detect the STOP for one cycle
assign o_ack_bit = (r_bit_counter == 4'd9) && !r_start_detect; // The 9 bits ACK
assign w_address_detect = (w_addr_buffer == device_address); // The input address matches the slave
assign w_read_write_bit = i_SDA; // The write or read operation 0=write and 1=read
assign w_addr_buffer = r_buffer[6:0];
assign w_out_buffer = r_buffer[7:0];
assign o_out = (o_ack_bit) ? r_buffer[7:0] : 0 ;
////////////////start detect /////////////// 
always @ (posedge w_start_rst or negedge i_SDA)
begin
        if (w_start_rst)
                r_start_detect <= 1'b0;
        else
                r_start_detect <= i_SCL;
end
always @ (posedge i_RST or posedge i_SCL)
begin
        if (i_RST)
                r_start_resetter <= 1'b0;
        else
                r_start_resetter <= r_start_detect;
end
//the START just lasts for one cycle of SCL
////////////////////state machine//////////////////// 
always @ (posedge i_RST or negedge i_SCL)
begin
        if (i_RST)
                r_state <= s_STATE_IDLE;
        else if (r_start_detect)
                r_state <= s_STATE_DEV_ADDR;
        else if (r_addr_act_bit)//at the 9th cycle and change the state by ACK
        begin
                case (r_state)
                s_STATE_IDLE:
                        r_state <= s_STATE_IDLE;
                s_STATE_DEV_ADDR:
                        if (!w_address_detect)//addr don't match
                                r_state <= s_STATE_IDLE;
                        else if (w_read_write_bit)// addr match and operation is read
                                r_state <= s_STATE_READ;
                        else//addr match and operation is write
                                r_state <= s_STATE_WRITE;
                s_STATE_READ:
                                r_state <= s_STATE_READ;
                s_STATE_WRITE:
                        r_state <= s_STATE_WRITE;//when the state is write the state 
                endcase
        end
        //if don't write and master send a stop,need to jump idle
        //the stop_detect is the next cycle of ACK
        else if(r_stop_detect)  
                r_state <= s_STATE_IDLE;
end
////////////////stop detect /////////////// 
always @ (posedge w_stop_rst or posedge i_SDA)
begin   
        if (w_stop_rst)
                r_stop_detect <= 1'b0;
        else
                r_stop_detect <= i_SCL;
end
always @ (posedge i_RST or posedge i_SCL)
begin   
        if (i_RST)
                r_stop_resetter <= 1'b0;
        else
                r_stop_resetter <= r_stop_detect;
end
/////////////////////count data ////////////////// 
always @ (posedge i_SCL)
begin
        if ( r_addr_act_bit || o_ack_bit || r_start_detect || (r_state == s_STATE_IDLE))
                r_bit_counter <= 4'h0;
        else
                r_bit_counter <= r_bit_counter + 4'h1;
end
////////////////////load data to buffer ///////////////
//counter to 9(from 0 to 8), one byte=8bits and one ack 
always @ (posedge i_SCL)
        if (!o_ack_bit)
                r_buffer <= {r_buffer[7:0], i_SDA};
                //r_buffer[r_bit_counter] <= i_SDA;
////////////////////ack for address detection/////////////////////// 
always @ (posedge i_SCL)
   r_addr_act_bit = (r_bit_counter == 4'd5) && !r_start_detect && (r_state == s_STATE_DEV_ADDR);
endmodule
