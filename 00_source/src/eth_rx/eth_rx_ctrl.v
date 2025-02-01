//====================================================================
// simpleEthernet
// eth_rx_ctrl.v
// Ethernet RMII receive module control
// 12/15/24
//====================================================================

module eth_rx_ctrl (
  input wire        Clk,
  input wire        Rst,
  input wire        Crs_Dv,
  input wire [1:0]  Rxd,
  input wire        Byte_Rdy,
  input wire [7:0]  Byte,
  input wire [31:0] Crc_Computed,
  output reg        Rx_En,
  output reg        Crc_En,
  output reg        Crc_Valid
);

  //==========================================
  // Constants
  //==========================================

  // preamble count
  localparam pPreamble_Cnt      = 8'h20;

  // eth_rx_ctrl_fsm
  localparam RX_IDLE            = 2'h0;
  localparam RX_PREAMBLE        = 2'h1;
  localparam RX_DATA            = 2'h2;

  // eth_byte_ctrl_fsm
  localparam IDLE               = 3'h0;
  localparam DEST_ADDR          = 3'h1;
  localparam SRC_ADDR           = 3'h2;
  localparam LEN_TYPE           = 3'h3;
  localparam PAYLOAD            = 3'h4;
  localparam FCS                = 3'h5;

  // byte counts
  localparam pMAC_Addr_Bytes    = 16'h6;
  localparam pLen_Type_Bytes    = 16'h2;

  // len type
  //localparam pLen_Type          = 16'h0800;
  localparam pLen_Type          = 16'hFFFF;

  //==========================================
  // Wires/Registers
  //==========================================

  // fsm/control
  reg [1:0]     rRx_Ctrl_FSM_State;
  reg [7:0]     rRx_Ctrl_Cnt;
  reg [2:0]     rByte_Ctrl_FSM_State;
  reg [15:0]    rByte_Cnt;
  reg           rByte_Ctrl_Done;

  // parsed
  reg [15:0]    rLen_Type;
  reg [31:0]    rCrc_Recv;

  //==========================================
  // eth_rx_ctrl_fsm
  //==========================================
  // monitor read-in of bits from PHY

  always @(posedge Clk)
  begin
    if (Rst) begin
      Rx_En <= 0;
      rRx_Ctrl_Cnt <= 0;
      rRx_Ctrl_FSM_State <= RX_IDLE;
    end
    else begin

      case(rRx_Ctrl_FSM_State)

        //================
        // RX_IDLE (0)
        //================
        RX_IDLE:
        begin
          Rx_En <= 0;
          rRx_Ctrl_Cnt <= 0;
          if (Rxd == 2'b01 & Crs_Dv) begin
            rRx_Ctrl_Cnt <= rRx_Ctrl_Cnt + 1;
            rRx_Ctrl_FSM_State <= RX_PREAMBLE;
          end
        end

        //================
        // RX_PREAMBLE (1)
        //================
        RX_PREAMBLE:
        begin
          if (Rxd == 2'b01 & Crs_Dv)
            rRx_Ctrl_Cnt <= rRx_Ctrl_Cnt + 1;
          else if (Rxd == 2'b11 & rRx_Ctrl_Cnt == pPreamble_Cnt-1 & Crs_Dv) begin
            Rx_En <= 1;
            rRx_Ctrl_FSM_State <= RX_DATA;
          end
          else
            rRx_Ctrl_FSM_State <= RX_IDLE;
        end

        //================
        // RX_DATA (2)
        //================
        RX_DATA:
        begin
          if (rByte_Ctrl_Done | ~Crs_Dv) begin
            Rx_En <= 0;
            rRx_Ctrl_FSM_State <= RX_IDLE;
          end
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
  // monitor formed bytes for packet content

  always @(posedge Clk)
  begin
    if (Rst) begin
      rByte_Ctrl_FSM_State <= IDLE;
      rByte_Cnt <= 0;
      rLen_Type <= 0;
      rCrc_Recv <= 0;
      Crc_Valid <= 0;
    end
    else begin

      case (rByte_Ctrl_FSM_State)

        //================
        // IDLE (0)
        //================
        IDLE:
        begin
          rByte_Cnt <= 0;
          rByte_Ctrl_Done <= 0;
          rLen_Type <= 0;
          rCrc_Recv <= 0;
          Crc_En <= 0;
          Crc_Valid <= 0;
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
              rLen_Type <= {rLen_Type[7:0], Byte};
              rByte_Cnt <= 0;
              rByte_Ctrl_FSM_State <= LEN_TYPE;
            end
          end
        end

        //================
        // LEN_TYPE (3)
        //================
        // parse ethertype, only proceed with IP packets, else return to IDLE

        LEN_TYPE:
        begin
          if (Byte_Rdy) begin
            rByte_Cnt <= rByte_Cnt + 1;

            if (rByte_Cnt == pLen_Type_Bytes-1) begin
              if (rLen_Type == pLen_Type) begin
                rByte_Cnt <= 0;
                rByte_Ctrl_FSM_State <= PAYLOAD;
              end
              else begin
                rByte_Ctrl_Done <= 1;
                rByte_Ctrl_FSM_State <= IDLE;
              end
            end
            else
              rLen_Type <= {rLen_Type[7:0], Byte};
          end
        end

        //================
        // PAYLOAD (4)
        //================
        PAYLOAD:
        begin
          if (Byte_Rdy & Crs_Dv) begin
            rByte_Cnt <= rByte_Cnt + 1;
            rCrc_Recv <= {Byte, rCrc_Recv[31:8]};
          end
          else if (~Crs_Dv) begin
            Crc_En <= 0;
            rCrc_Recv <= {Byte, rCrc_Recv[31:8]};
            rByte_Ctrl_FSM_State <= FCS;
            end
        end

        //================
        // FCS (5)
        //================
        FCS:
        begin
          if (rCrc_Recv == Crc_Computed)
            Crc_Valid <= 1;
          rByte_Ctrl_FSM_State <= IDLE;
        end

        default:
          rByte_Ctrl_FSM_State <= IDLE;

      endcase
    end
  end
endmodule
