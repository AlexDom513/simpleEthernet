//====================================================================
// simpleEthernet
// eth_rx_ctrl.v
// Ethernet RMII receive module control
// 12/15/24
//====================================================================

module eth_rx_ctrl (
  input wire        Clk,
  input wire        Rst,
  input wire [1:0]  Rxd,
  input wire        Byte_Rdy,
  input wire [7:0]  Byte,
  input wire [31:0] Crc_Recv,
  output reg        Rx_En,
  output reg        Crc_En
);

  //==========================================
  // Constants
  //==========================================

  // number of parallel data lines to PHY
  localparam pMII_WIDTH = 2;

  // shift to conver bytes to bits
  localparam pBytes_To_Bits = 3;

  // eth_rx_ctrl_fsm
  localparam RX_IDLE            = 2'h0;
  localparam RX_PREAMBLE        = 2'h1;
  localparam RX_DATA            = 2'h2;

  // eth_byte_ctrl_fsm
  localparam IDLE               = 3'h0;
  localparam DEST_ADDR          = 3'h1;
  localparam SRC_ADDR           = 3'h2;
  localparam LEN_TYPE           = 3'h3;
  localparam PAYLOAD_LEN        = 3'h4;
  localparam PAYLOAD            = 3'h5;
  localparam FCS                = 3'h6;
  localparam IPG                = 3'h7;

  // byte counts
  localparam pMAC_Addr_Bytes    = 16'h6;
  localparam pLen_Type_Bytes    = 16'h2;
  localparam pPayload_Len_Bytes = 16'h4;
  localparam pFCS_Len_Bytes     = 16'h4;
  localparam pIPG_Bytes         = 16'h12;

  // bit counts
  localparam pIPG_Bits          = pIPG_Bytes << pBytes_To_Bits;
  
  // serial counts (# iterations to process data given some MII width)
  localparam pIPG_Cnt           = pIPG_Bits >> (pMII_WIDTH >> 1);

  //==========================================
  // Wires/Registers
  //==========================================

  // registered input
  reg           rByte_Rdy;
  reg [7:0]     rByte;

  // fsm/control
  reg [1:0]     rRx_Ctrl_FSM_State;
  reg [2:0]     rByte_Ctrl_FSM_State;
  reg [15:0]    rByte_Ctrl_Cnt;
  reg [15:0]    rByte_Cnt;
  reg           rByte_Ctrl_Done;

  // parsed
  reg [15:0]    rTot_Payload_Bytes;
  reg [31:0]    rCrc_Recv;

  //==========================================
  // eth_rx_ctrl_fsm
  //==========================================
  always @(posedge Clk)
  begin
    if (Rst) begin
      rRx_Ctrl_FSM_State <= RX_IDLE;
    end
    else begin

      case(rRx_Ctrl_FSM_State)

        //================
        // RX_IDLE (0)
        //================
        RX_IDLE:
        begin
          if (Rxd == 2'b01)
            rRx_Ctrl_FSM_State <= RX_PREAMBLE;
        end

        //================
        // RX_PREAMBLE (1)
        //================
        RX_PREAMBLE:
        begin
          if (Rxd == 2'b11) begin
            Rx_En <= 1;
            rRx_Ctrl_FSM_State <= RX_DATA;
          end
        end

        //================
        // RX_DATA (2)
        //================
        RX_DATA:
        begin
          if (rByte_Ctrl_Done)
            Rx_En <= 0;
          if (rByte_Ctrl_FSM_State == IDLE)
            rRx_Ctrl_FSM_State <= RX_IDLE;
        end

        //================
        // Default
        //================
        default:
          rRx_Ctrl_FSM_State <= RX_IDLE;
      endcase
    end
  end

  //==========================================
  // eth_byte_ctrl_fsm
  //==========================================

  // register input data
  always @(posedge Clk)
  begin
    rByte_Rdy <= Byte_Rdy;
    rByte <= Byte;
  end

  always @(posedge Clk)
  begin
    if (Rst) begin
      rByte_Ctrl_FSM_State <= 0;
      rByte_Ctrl_Cnt <= 0;
      rByte_Cnt <= 0;
      rByte_Ctrl_Done <= 0;
      rTot_Payload_Bytes <= 0;
    end
    else begin

      case (rByte_Ctrl_FSM_State)

        //================
        // IDLE (0)
        //================
        IDLE:
        begin
          rByte_Ctrl_FSM_State <= 0;
          rByte_Ctrl_Cnt <= 0;
          rByte_Cnt <= 0;
          rByte_Ctrl_Done <= 0;
          rTot_Payload_Bytes <= 0;
          Crc_En <= 0;
          if (Byte_Rdy) begin
            Crc_En <= 1;
            rByte_Ctrl_FSM_State <= DEST_ADDR;
          end
        end

        //================
        // DEST_ADDR (1)
        //================
        DEST_ADDR:
        begin
          if (Byte_Rdy) begin
            rByte_Cnt <= rByte_Cnt + 1;

            if (rByte_Cnt == pMAC_Addr_Bytes-1) begin
              rByte_Cnt <= 0;
              rByte_Ctrl_FSM_State <= SRC_ADDR;
            end
          end
        end

        //================
        // SRC_ADDR (2)
        //================
        SRC_ADDR:
        begin
          if (Byte_Rdy) begin
            rByte_Cnt <= rByte_Cnt + 1;

            if (rByte_Cnt == pMAC_Addr_Bytes-1) begin
              rByte_Cnt <= 0;
              rByte_Ctrl_FSM_State <= LEN_TYPE;
            end
          end
        end

        //================
        // LEN_TYPE (3)
        //================
        LEN_TYPE:
        begin
          if (Byte_Rdy) begin
            rByte_Cnt <= rByte_Cnt + 1;

            if (rByte_Cnt == pLen_Type_Bytes-1) begin
              rByte_Cnt <= 0;
              rByte_Ctrl_FSM_State <= PAYLOAD_LEN;
            end
          end
        end

        //================
        // PAYLOAD_LEN (4)
        //================
        PAYLOAD_LEN:
        begin
          if (Byte_Rdy) begin
            rByte_Cnt <= rByte_Cnt + 1;

            if (rByte_Cnt == pPayload_Len_Bytes-1)
              rByte_Ctrl_FSM_State <= PAYLOAD;
            else
              rTot_Payload_Bytes <= {rTot_Payload_Bytes[7:0], Byte};
          end
        end

        //================
        // PAYLOAD (5)
        //================
        PAYLOAD:
        begin
          if (Byte_Rdy) begin
            rByte_Cnt <= rByte_Cnt + 1;

            if (rByte_Cnt == rTot_Payload_Bytes-1) begin
              Crc_En <= 0;
              rCrc_Recv <= {rCrc_Recv[23:0], Byte};
              rByte_Cnt <= 0;
              rByte_Ctrl_FSM_State <= FCS;
            end
          end
        end

        //================
        // FCS (6)
        //================
        FCS:
        begin
          if (Byte_Rdy) begin
            rCrc_Recv <= {rCrc_Recv[23:0], Byte};
            rByte_Cnt <= rByte_Cnt + 1;

            if (rByte_Cnt == pFCS_Len_Bytes-2) begin
              rByte_Ctrl_Done <= 1;
              rByte_Ctrl_FSM_State <= IPG;
            end
          end
        end

        //================
        // IPG (7)
        //================
        IPG:
        begin
          rByte_Ctrl_Cnt <= rByte_Ctrl_Cnt + 1;
          
          if (rByte_Ctrl_Cnt == pIPG_Cnt)
            rByte_Ctrl_FSM_State <= IDLE;
        end

      endcase
      
    end
  end

endmodule































































      // //================
      // // SRC_ADDR (3)
      // //================
      // SRC_ADDR:
      // begin
      //   rCtrl_Cnt <= rCtrl_Cnt + 1;
      //   if (rCtrl_Cnt == pMAC_Addr_Cnt-1) begin
      //     rCtrl_Cnt <= 0;
      //     rRx_Ctrl_FSM_State <= LEN_TYPE;
      //   end
      // end

      // //================
      // // LEN_TYPE (4)
      // //================
      // LEN_TYPE:
      // begin
      //   rCtrl_Cnt <= rCtrl_Cnt + 1;

      //   // // form 16-bit word indicating LEN_TYPE
      //   // if (wByte_Rdy)
      //   //   rLen_Type <= {rLen_Type[7:0], wByte_Rx};

      //   if (rCtrl_Cnt == pLen_Type_Cnt-1) begin
      //     rCtrl_Cnt <= 0;
      //     rRx_Ctrl_FSM_State <= PAYLOAD_LEN;
      //   end
      // end

      // //================
      // // PAYLOAD_LEN (5)
      // //================
      // PAYLOAD_LEN:
      // begin
      //   rCtrl_Cnt <= rCtrl_Cnt + 1;

      //   // // only operate on IP packets
      //   // if (rLen_Type == IP_LEN_TYPE) begin

      //   // //   // form 16-bit word indicating # bytes in IP header + payload
      //   // //   if (wByte_Rdy) begin
      //   // //     rIP_Curr_Payload_Bytes <= rIP_Curr_Payload_Bytes + 1;
      //   // //     rIP_Prev_Byte <= wByte_Rx;
      //   // //   end

      //   // //   if (rCtrl_Cnt == pPayload_Len_Cnt-1) begin
      //   // //     rIP_Tot_Payload_Bytes <= {rIP_Prev_Byte, wByte_Rx};
      //   // //     rCtrl_Cnt <= 0;
      //   // //     rRx_Ctrl_FSM_State <= PAYLOAD;
      //   // //   end
      //   // end

      //   // // LEN_TYPE is not IP, return to RX_IDLE
      //   // else
      //   //   rRx_Ctrl_FSM_State <= RX_IDLE;
      //   rRx_Ctrl_FSM_State <= PAYLOAD;
      // end

      // //================
      // // PAYLOAD (6)
      // //================
      // PAYLOAD:
      // begin
      //   // if (wByte_Rdy) begin
      //   //   rIP_Curr_Payload_Bytes <= rIP_Curr_Payload_Bytes + 1;
      //   // end

      //   // if (rIP_Curr_Payload_Bytes == rIP_Tot_Payload_Bytes) begin
      //   //   //rCrc_En <= 0;
      //   //   if (wByte_Rdy) begin
      //   //     rCrc_Recv <= {rCrc_Recv[23:0], wByte_Rx};
      //   //     rRx_Ctrl_FSM_State <= FCS;
      //   //   end
      //   // end


      //   rCtrl_Cnt <= 0;
      //   rRx_Ctrl_FSM_State <= FCS;
      // end

      // //================
      // // FCS (7)
      // //================

      // // assuming FCS enters LSB first from PHY

      // FCS:
      // begin
      //   // rCtrl_Cnt <= rCtrl_Cnt + 1;

      //   // if (wByte_Rdy & rCtrl_Cnt < pFCS_Len_Cnt-1)
      //   //   rCrc_Recv <= {rCrc_Recv[23:0], wByte_Rx};


      //   // if (rCtrl_Cnt == pFCS_Len_Cnt-4) begin
      //   //   if (rCrc == rCrc_Recv)
      //   //     rCrc_Valid <= 1;
      //   //   else
      //   //     rCrc_Valid <= 0;
      //   // end
      //   // else if (rCtrl_Cnt == pFCS_Len_Cnt-3) begin
      //   //   Rx_En   <= 0;
      //   //   rCtrl_Cnt <= 0;
      //   //   rRx_Ctrl_FSM_State <= IPG;
      //   // end

      //   rCtrl_Cnt <= 0;
      //   rRx_Ctrl_FSM_State <= IPG;
      // end

      // //================
      // // IPG (8)
      // //================
      // IPG:
      // begin
      //   // rCtrl_Cnt <= rCtrl_Cnt + 1;
      //   rCtrl_Cnt <= 0;
      //   rRx_Ctrl_FSM_State <= RX_IDLE;
      // end

//       //================
//       // Default
//       //================
//       default:
//         rRx_Ctrl_FSM_State <= RX_IDLE;

//       endcase
//     end
//   end

// endmodule
















  // //==========================================
  // // eth_rx_fsm
  // //==========================================
  // always @(posedge Clk)
  // begin
  //   if (Rst) begin
  //     rCrc_En <= 0;
  //     rIP_Curr_Payload_Bytes <= 0;
  //     rCtrl_Cnt <= 0;
  //     rRx_Ctrl_FSM_State <= RX_IDLE;
  //   end
  //   else begin

  //     case(rRx_Ctrl_FSM_State)

  //     //================
  //     // RX_IDLE (0)
  //     //================
  //     RX_IDLE:
  //     begin
  //       rCrc_En <= 0;
  //       rIP_Curr_Payload_Bytes <= 0;
  //       rCtrl_Cnt <= 0;

  //       if (Rxd == 2'b01)
  //         rRx_Ctrl_FSM_State <= RX_PREAMBLE;
  //     end

  //     //================
  //     // RX_PREAMBLE (1)
  //     //================
  //     RX_PREAMBLE:
  //     begin
  //       if (Rxd == 2'b11) begin
  //         rCrc_En <= 1;
  //         rRx_Ctrl_FSM_State <= DEST_ADDR;
  //       end
  //     end

  //     //================
  //     // DEST_ADDR (2)
  //     //================
  //     DEST_ADDR:
  //     begin
  //       rCtrl_Cnt <= rCtrl_Cnt + 1;
  //       if (rCtrl_Cnt == pDest_Addr_Cnt-1) begin
  //         rCtrl_Cnt <= 0;
  //         rRx_Ctrl_FSM_State <= SRC_ADDR;
  //       end
  //     end

  //     //================
  //     // SRC_ADDR (3)
  //     //================
  //     SRC_ADDR:
  //     begin
  //       rCtrl_Cnt <= rCtrl_Cnt + 1;
  //       if (rCtrl_Cnt == pSrc_Addr_Cnt-1) begin
  //         rCtrl_Cnt <= 0;
  //         rRx_Ctrl_FSM_State <= LEN_TYPE;
  //       end
  //     end

  //     //================
  //     // LEN_TYPE (4)
  //     //================
  //     LEN_TYPE:
  //     begin
  //       rCtrl_Cnt <= rCtrl_Cnt + 1;

  //       // form 16-bit word indicating LEN_TYPE
  //       if (wByte_Rdy)
  //         rLen_Type <= {rLen_Type[7:0], wByte_Rx};

  //       if (rCtrl_Cnt == pLen_Type_Cnt-1) begin
  //         rCtrl_Cnt <= 0;
  //         rRx_Ctrl_FSM_State <= PAYLOAD_LEN;
  //       end
  //     end

  //     //================
  //     // PAYLOAD_LEN (5)
  //     //================
  //     PAYLOAD_LEN:
  //     begin
  //       rCtrl_Cnt <= rCtrl_Cnt + 1;

  //       // only operate on IP packets
  //       if (rLen_Type == IP_LEN_TYPE) begin

  //         // form 16-bit word indicating # bytes in IP header + payload
  //         if (wByte_Rdy) begin
  //           rIP_Curr_Payload_Bytes <= rIP_Curr_Payload_Bytes + 1;
  //           rIP_Prev_Byte <= wByte_Rx;
  //         end

  //         if (rCtrl_Cnt == pPayload_Len_Cnt-1) begin
  //           rIP_Tot_Payload_Bytes <= {rIP_Prev_Byte, wByte_Rx};
  //           rCtrl_Cnt <= 0;
  //           rRx_Ctrl_FSM_State <= PAYLOAD;
  //         end
  //       end

  //       // LEN_TYPE is not IP, return to RX_IDLE
  //       else
  //         rRx_Ctrl_FSM_State <= RX_IDLE;
  //     end

  //     //================
  //     // PAYLOAD (6)
  //     //================
  //     PAYLOAD:
  //     begin
  //       if (wByte_Rdy) begin
  //         rIP_Curr_Payload_Bytes <= rIP_Curr_Payload_Bytes + 1;
  //       end

  //       if (rIP_Curr_Payload_Bytes == rIP_Tot_Payload_Bytes) begin
  //         rCrc_En <= 0;
  //         if (wByte_Rdy) begin
  //           rCrc_Recv <= {rCrc_Recv[23:0], wByte_Rx};
  //           rRx_Ctrl_FSM_State <= FCS;
  //         end
  //       end
  //     end

  //     //================
  //     // FCS (7)
  //     //================

  //     // assuming FCS enters LSB first from PHY

  //     FCS:
  //     begin
  //       rCtrl_Cnt <= rCtrl_Cnt + 1;

  //       if (wByte_Rdy & rCtrl_Cnt < pFCS_Len_Cnt-1)
  //         rCrc_Recv <= {rCrc_Recv[23:0], wByte_Rx};


  //       if (rCtrl_Cnt == pFCS_Len_Cnt-4) begin
  //         if (rCrc == rCrc_Recv)
  //           rCrc_Valid <= 1;
  //         else
  //           rCrc_Valid <= 0;
  //       end
  //       else if (rCtrl_Cnt == pFCS_Len_Cnt-3) begin
  //         rCtrl_Cnt <= 0;
  //         rRx_Ctrl_FSM_State <= IPG;
  //       end
  //     end

  //     //================
  //     // IPG (8)
  //     //================
  //     IPG:
  //     begin
  //       rCtrl_Cnt <= rCtrl_Cnt + 1;
        
  //     end

  //     //================
  //     // Default
  //     //================
  //     default:
  //       rRx_Ctrl_FSM_State <= RX_IDLE;

  //     endcase
  //   end
  // end
