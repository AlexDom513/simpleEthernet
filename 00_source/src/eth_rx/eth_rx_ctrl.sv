//--------------------------------------------------------------------
// simpleEthernet
// eth_rx_ctrl.sv
// Ethernet RMII receive module control
// 12/15/24
//--------------------------------------------------------------------

module eth_rx_ctrl (
  input  logic        Clk,
  input  logic        Rst,
  input  logic        Crs_Dv,
  input  logic [1:0]  Rxd,
  input  logic        Byte_Rdy,
  input  logic [7:0]  Byte,
  input  logic [31:0] Crc_Computed,
  output logic        Rx_En,
  output logic        Crc_En,
  output logic        Crc_Valid
);

  //------------------------------------------
  // Constants
  //------------------------------------------

  // eth_rx_ctrl_fsm
  typedef enum logic [1:0] {
    RX_IDLE     = 2'h0,
    RX_PREAMBLE = 2'h1,
    RX_DATA     = 2'h2
  } eth_rx_ctrl_state_t;

  // eth_byte_ctrl_fsm
  typedef enum logic [2:0] {
    IDLE      = 3'h0,
    DEST_ADDR = 3'h1,
    SRC_ADDR  = 3'h2,
    LEN_TYPE  = 3'h3,
    PAYLOAD   = 3'h4,
    FCS       = 3'h5
  } eth_byte_ctrl_state_t;

  localparam pPREAMBLE_CNT   = 8'h20;
  localparam pMAC_ADDR_BYTES = 16'h6;
  localparam pLEN_TYPE_BYTES = 16'h2;
  localparam pLEN_TYPE       = 16'hFFFF;

  //------------------------------------------
  // Logic
  //------------------------------------------
  eth_rx_ctrl_state_t   sRx_Ctrl_State;
  logic [7:0]           rRx_Ctrl_Cnt;

  eth_byte_ctrl_state_t sByte_Ctrl_State;
  logic [15:0]          rByte_Cnt;
  logic                 rByte_Ctrl_Done;

  // parsed
  logic [15:0]          rLen_Type;
  logic [31:0]          rCrc_Recv;

  //------------------------------------------
  // eth_rx_ctrl_fsm
  //------------------------------------------
  // monitor read-in of bits from PHY

  always_ff @(posedge Clk)
  begin
    if (Rst) begin
      Rx_En <= 0;
      rRx_Ctrl_Cnt <= 0;
      sRx_Ctrl_State <= RX_IDLE;
    end
    else begin

      case(sRx_Ctrl_State)

        //----------------
        // RX_IDLE (0)
        //----------------
        RX_IDLE:
        begin
          Rx_En <= 0;
          rRx_Ctrl_Cnt <= 0;
          if (Rxd == 2'b01 & Crs_Dv) begin
            rRx_Ctrl_Cnt <= rRx_Ctrl_Cnt + 1;
            sRx_Ctrl_State <= RX_PREAMBLE;
          end
        end

        //----------------
        // RX_PREAMBLE (1)
        //----------------
        RX_PREAMBLE:
        begin
          if (Rxd == 2'b01 & Crs_Dv)
            rRx_Ctrl_Cnt <= rRx_Ctrl_Cnt + 1;
          else if (Rxd == 2'b11 & rRx_Ctrl_Cnt == pPREAMBLE_CNT-1 & Crs_Dv) begin
            Rx_En <= 1;
            sRx_Ctrl_State <= RX_DATA;
          end
          else
            sRx_Ctrl_State <= RX_IDLE;
        end

        //----------------
        // RX_DATA (2)
        //----------------
        RX_DATA:
        begin
          if (rByte_Ctrl_Done | ~Crs_Dv) begin
            Rx_En <= 0;
            sRx_Ctrl_State <= RX_IDLE;
          end
        end

        //----------------
        // Default
        //----------------
        default:
          sRx_Ctrl_State <= RX_IDLE;
      endcase
    end
  end

  //------------------------------------------
  // eth_byte_ctrl_fsm
  //------------------------------------------
  // monitor formed bytes for packet content

  always_ff @(posedge Clk)
  begin
    if (Rst) begin
      sByte_Ctrl_State <= IDLE;
      rByte_Cnt <= 0;
      rLen_Type <= 0;
      rCrc_Recv <= 0;
      Crc_Valid <= 0;
    end
    else begin

      case (sByte_Ctrl_State)

        //----------------
        // IDLE (0)
        //----------------
        IDLE:
        begin
          Crc_En <= 0;
          Crc_Valid <= 0;
          rByte_Cnt <= 0;
          rLen_Type <= 0;
          rCrc_Recv <= 0;
          rByte_Ctrl_Done <= 0;
          if (Byte_Rdy) begin
            Crc_En <= 1;
            sByte_Ctrl_State <= DEST_ADDR;
          end
        end

        //----------------
        // DEST_ADDR (1)
        //----------------
        DEST_ADDR:
        begin
          if (Byte_Rdy) begin
            rByte_Cnt <= rByte_Cnt + 1;

            if (rByte_Cnt == pMAC_ADDR_BYTES-1) begin
              rByte_Cnt <= 0;
              sByte_Ctrl_State <= SRC_ADDR;
            end
          end
        end

        //----------------
        // SRC_ADDR (2)
        //----------------
        SRC_ADDR:
        begin
          if (Byte_Rdy) begin
            rByte_Cnt <= rByte_Cnt + 1;

            if (rByte_Cnt == pMAC_ADDR_BYTES-1) begin
              rLen_Type <= {rLen_Type[7:0], Byte};
              rByte_Cnt <= 0;
              sByte_Ctrl_State <= LEN_TYPE;
            end
          end
        end

        //----------------
        // LEN_TYPE (3)
        //----------------
        // parse ethertype

        LEN_TYPE:
        begin
          if (Byte_Rdy) begin
            rByte_Cnt <= rByte_Cnt + 1;

            if (rByte_Cnt == pLEN_TYPE_BYTES-1) begin
              if (rLen_Type == pLEN_TYPE) begin
                rByte_Cnt <= 0;
                sByte_Ctrl_State <= PAYLOAD;
              end
              else begin
                rByte_Ctrl_Done <= 1;
                sByte_Ctrl_State <= IDLE;
              end
            end
            else
              rLen_Type <= {rLen_Type[7:0], Byte};
          end
        end

        //----------------
        // PAYLOAD (4)
        //----------------
        PAYLOAD:
        begin
          if (Byte_Rdy & Crs_Dv) begin
            rByte_Cnt <= rByte_Cnt + 1;
            rCrc_Recv <= {Byte, rCrc_Recv[31:8]};
          end
          else if (Byte_Rdy & ~Crs_Dv) begin
            Crc_En <= 0;
            rCrc_Recv <= {Byte, rCrc_Recv[31:8]};
            sByte_Ctrl_State <= FCS;
          end
          else if (~Crs_Dv) begin
            Crc_En <= 0;
            sByte_Ctrl_State <= FCS;
          end
        end

        //----------------
        // FCS (5)
        //----------------
        FCS:
        begin
          if (rCrc_Recv == Crc_Computed)
            Crc_Valid <= 1;
          sByte_Ctrl_State <= IDLE;
        end

        default:
          sByte_Ctrl_State <= IDLE;

      endcase
    end
  end
endmodule
