//--------------------------------------------------------------------
// simpleEthernet
// eth_data_mgr.sv
// Manages Rx'd data and formats input data prior to TX
// 4/19/25
//--------------------------------------------------------------------

module eth_data_mgr #(
  parameter pPayload_Only=1
  )(

  input  logic       Clk,
  input  logic       Rst,
  input  logic [9:0] Eth_Byte_Rx_In,
  input  logic       Eth_Byte_Valid_Rx_In,
  output logic [9:0] Eth_Byte_Rx_Out,
  output logic       Eth_Byte_Valid_Rx_Out
);

  //------------------------------------------
  // Constants
  //------------------------------------------
  localparam cNum_Bytes_Remove = 14; // (bytes 0-13)

  //------------------------------------------
  // Logic
  //------------------------------------------
  logic wEOP;
  logic rEOP;
  logic [3:0] rByte_Cnt;

  //------------------------------------------
  // RX Payload Only
  //------------------------------------------
  // removes the following from the byte stream
  //    - DEST MAC ADDRESS
  //    - SRC MAC ADDRESS
  //    - ETHERTYPE

  assign wEOP = Eth_Byte_Rx_In[8];

  always_ff @(posedge Clk)
  begin
    if (Rst)
      rEOP <= 0;
    else
      rEOP <= wEOP;
  end

  always_ff @(posedge Clk)
  begin
    if (Rst) begin
      rByte_Cnt <= 0;
      Eth_Byte_Valid_Rx_Out <= 0;
    end
    else begin

      // only allow payload bytes
      if (pPayload_Only == 1) begin
        if (Eth_Byte_Valid_Rx_In | rEOP) begin

          // only count bytes to remove
          if (rByte_Cnt <= cNum_Bytes_Remove)
            rByte_Cnt <= rByte_Cnt + 1;

          // re-insert SOP
          if (rByte_Cnt == cNum_Bytes_Remove)
            Eth_Byte_Rx_Out <= {2'b10, Eth_Byte_Rx_In[7:0]};
          else
            Eth_Byte_Rx_Out <= Eth_Byte_Rx_In;

          // enable valid after MAC address and EtherType
          if (rByte_Cnt >= cNum_Bytes_Remove) begin
            Eth_Byte_Valid_Rx_Out <= 1;
          end

          // end valid @ end of packet
          if (rEOP) begin
            rByte_Cnt <= 0;
            Eth_Byte_Valid_Rx_Out <= 0;
          end
          
        end
      end

      // allow full RX'd packet
      else begin
        Eth_Byte_Rx_Out <= Eth_Byte_Rx_In;
        Eth_Byte_Valid_Rx_Out <= Eth_Byte_Valid_Rx_In;
      end
    end
  end



endmodule
