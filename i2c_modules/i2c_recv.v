module i2c_slave(
  input SCL,RST,
  input SDA,
  output ack_bit,
  output  [7:0] out 
);
parameter [6:0] device_address = 7'b1000111;

parameter [2:0] STATE_IDLE      = 3'd0,//idle
                STATE_DEV_ADDR  = 3'd1,//the slave addr match
                STATE_READ      = 3'd2,//the op=read 
                STATE_IDX_PTR   = 3'd3,//get the index of inner-register
                STATE_WRITE     = 3'd4;//write the data in the reg 

wire start_rst;
wire stop_rst;
//wire add_act_bit;
//wire ack_bit;
wire address_detect;
wire read_write_bit;
wire write_strobe;
wire [6:0]addr_buffer;
wire [7:0]out_buffer;

reg add_act_bit;
reg start_detect;
reg start_resetter;
reg stop_detect;
reg stop_resetter;
reg [2:0]state;
reg [8:0]buffer;
reg [3:0]bit_counter;
// Assignments
assign start_rst = RST | start_resetter; // Detect the START for one cycle
assign stop_rst = RST | stop_resetter;   // Detect the STOP for one cycle
//assign add_act_bit = (bit_counter == 4'd6) && !start_detect && (state == STATE_DEV_ADDR); // the 8 bits one-byte data
assign ack_bit = (bit_counter == 4'd9) && !start_detect; // The 9 bits ACK
assign address_detect = (addr_buffer == device_address); // The input address matches the slave
assign read_write_bit = SDA; // The write or read operation 0=write and 1=read
assign write_flag = (state == STATE_WRITE) && ack_bit; // Write state and finish one byte = 8 bits
assign addr_buffer = buffer[6:0];
assign out_buffer = buffer[7:0];
assign out = (ack_bit) ? buffer[7:0] : 0 ;
//////////////////////////////////////////// 
////////////////start detect /////////////// 
////////////////////////////////////////////
always @ (posedge start_rst or negedge SDA)
begin
        if (start_rst)
                start_detect <= 1'b0;
        else
                start_detect <= SCL;
end

always @ (posedge RST or posedge SCL)
begin
        if (RST)
                start_resetter <= 1'b0;
        else
                start_resetter <= start_detect;
end
//the START just last for one cycle of SCL

////////////////////////////////////////////////////// 
////////////////////state machine//////////////////// 
//////////////////////////////////////////////////////
always @ (posedge RST or negedge SCL)//jcyuan comment
begin
        if (RST)
                state <= STATE_IDLE;
        else if (start_detect)
                state <= STATE_DEV_ADDR;
        else if (add_act_bit)//at the 9th cycle and change the state by ACK
        begin
                case (state)
                STATE_IDLE:
                        state <= STATE_IDLE;

                STATE_DEV_ADDR:
                        if (!address_detect)//addr don't match
                                state <= STATE_IDLE;
                        else if (read_write_bit)// addr match and operation is read
                                state <= STATE_READ;
                        else//addr match and operation is write
                                state <= STATE_WRITE;

                STATE_READ:
                                state <= STATE_READ;

                STATE_WRITE:
                        state <= STATE_WRITE;//when the state is write the state 
                endcase
        end
        //if don't write and master send a stop,need to jump idle
        //the stop_detect is the next cycle of ACK
        else if(stop_detect)  
                state <= STATE_IDLE;
end
//////////////////////////////////////////// 
////////////////stop detect /////////////// 
////////////////////////////////////////////
always @ (posedge stop_rst or posedge SDA)
begin   
        if (stop_rst)
                stop_detect <= 1'b0;
        else
                stop_detect <= SCL;
end

always @ (posedge RST or posedge SCL)
begin   
        if (RST)
                stop_resetter <= 1'b0;
        else
                stop_resetter <= stop_detect;
end

/////////////////////count data ////////////// 
always @ (posedge SCL)
begin
        if ( add_act_bit || ack_bit || start_detect || (state == STATE_IDLE))
                bit_counter <= 4'h0;
        else
                bit_counter <= bit_counter + 4'h1;
end

////////////////////load data to buffer ///////////////
//counter to 9(from 0 to 8), one byte=8bits and one ack 
always @ (posedge SCL)
        if (!ack_bit)
                buffer <= {buffer[7:0], SDA};
                //buffer[bit_counter] <= SDA;

//always @ (posedge SCL)
//  if(ack_bit && !start_detect)
//    out <= buffer;

  /////////////////////////////////////////////////////// 
always @ (posedge SCL)
   add_act_bit = (bit_counter == 4'd5) && !start_detect && (state == STATE_DEV_ADDR);
endmodule
