// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
  
module uart_tx #(parameter CLKS_PER_BIT)
( 
  input       i_Clock,
  input       i_Tx_DV,
  input [7:0] i_Tx_Byte, 
  output      o_Tx_Active,
  output reg  o_Tx_Serial,
  output      o_Tx_Done
);

  parameter s_IDLE         = 3'b000;
  parameter s_TX_START_BIT = 3'b001;
  parameter s_TX_DATA_BITS = 3'b010;
  parameter s_TX_STOP_BIT  = 3'b011;
  parameter s_CLEANUP      = 3'b100;

  wire w_Clock_Count_Flag;

  reg [2:0]    r_state       = 0;
  reg [7:0]    r_Clock_Count = 0;
  reg [2:0]    r_Bit_Index   = 0;
  reg [7:0]    r_Tx_Data     = 0;
  reg          r_Tx_Done     = 0;
  reg          r_Tx_Active   = 0;

  assign w_Clock_Count_Flag =  (r_Clock_Count < CLKS_PER_BIT-1);
  assign w_bit_index_flag = (r_Bit_Index < 7);
  assign o_Tx_Active = r_Tx_Active;
  assign o_Tx_Done   = r_Tx_Done;
  //////////state machine////////// 
  always @ (posedge i_Clock)
    case (r_state)
      s_IDLE : 
        begin 
            o_Tx_Serial   <= 1'b1;         // Drive Line High for Idle
            r_Tx_Done     <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
            if (i_Tx_DV)
            begin 
              r_Tx_Active <= 1'b1;
              r_Tx_Data   <= i_Tx_Byte;
              r_state   <= s_TX_START_BIT;
            end
            else 
              r_state <= s_IDLE;
        end
      s_TX_START_BIT : 
        begin 
          o_Tx_Serial <= 1'b0;
          if (w_Clock_Count_Flag)
          begin 
            r_Clock_Count <= r_Clock_Count + 1;
            r_state <= s_TX_START_BIT;
          end 
          else 
          begin
            r_Clock_Count <= 0;
            r_state   <= s_TX_DATA_BITS;
          end
        end 
      
      s_TX_DATA_BITS :
        begin
          o_Tx_Serial <= r_Tx_Data[r_Bit_Index];
          
          if (w_Clock_Count_Flag)
            begin
              r_Clock_Count <= r_Clock_Count + 1;
              r_state     <= s_TX_DATA_BITS;
            end
          else
            begin
              r_Clock_Count <= 0;
              // Check if we have sent out all bits
              if (w_bit_index_flag)
                begin
                  r_Bit_Index <= r_Bit_Index + 1;
                  r_state   <= s_TX_DATA_BITS;
                end
              else
                begin
                  r_Bit_Index <= 0;
                  r_state   <= s_TX_STOP_BIT;
                end
            end
        end // case: s_TX_DATA_BIT
        s_TX_STOP_BIT :
          begin
            o_Tx_Serial <= 1'b1;
             
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (w_Clock_Count_Flag)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_TX_STOP_BIT;
              end
            else
              begin
                r_Tx_Done     <= 1'b1;
                r_Clock_Count <= 0;
                r_Tx_Active   <= 1'b0;
                r_SM_Main     <= s_IDLE;
              end
          end // case: s_Tx_STOP_BIT
          default :
            r_SM_Main <= s_IDLE;
          endcase
