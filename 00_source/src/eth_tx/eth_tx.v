//====================================================================
// 02_simple_ethernet
// eth_tx.v
// Ethernet RMII transmit module
// 7/4/24
//====================================================================

`include "eth_tx_pkg.vh"

module eth_tx (
  input  wire         Clk,
  input  wire         Rst,
  input  wire [7:0]   Eth_Byte,
  input  wire         Eth_Byte_Valid,
  input  wire         Eth_Pkt_Rdy,
  output wire [1:0]   Txd, // bit[0] ('first')
  output wire         Tx_En
);

  //==========================================
  // Constants
  //==========================================
  localparam pPreamble  = 56'h55555555555555; // 0101_0101 ... 7x, read out as 1010_1010 ...
  localparam pSFD       = 8'hD5;              // 1101_0101 ... read out as 1010_1011
  localparam pDest_Addr = 48'hF0A0FFFFFFFF;   // broadcast address
  localparam pSrc_Addr  = 48'h000000000000;   // locally administered address for testing
  localparam pLen_Type  = 16'h0800;           // IPv4

  //==========================================
  // Wires/Registers
  //==========================================

  // fsm/control
  reg [3:0]   rTx_Ctrl_FSM_State;
  reg [3:0]   rTx_Ctrl_FSM_State_d1;
  reg         rTx_En;
  reg         rFifo_Empty;
  reg         rCrc_En;
  reg         rCrc_En_d1;
  reg         rCrc_En_d2;
  reg [1:0]   rCrc_Bits_Cnt;

  // data
  reg [1:0]   rTx_Data;
  reg         rFifo_Rd_Valid;
  reg         rFifo_Rd_Valid_d1;
  reg [7:0]   rFifo_Rd_Data;

  // crc
  reg [7:0]   rCrc_Byte;
  wire        wCrc_Byte_Valid;
  wire [31:0] wCrc_Out;
  wire [31:0] wCrc_Computed;
  reg [31:0]  rCrc_Computed;
  wire [31:0] wCrc_Computed_Tx;

  // buffer regs
  reg [55:0]  rPreamble_Buf;
  reg [7:0]   rSFD_Buf;
  reg [47:0]  rDest_Addr_Buf;
  reg [47:0]  rSrc_Addr_Buf;
  reg [15:0]  rLen_Type_Buf;
  reg [7:0]   rPayload_Buf;
  reg [7:0]   rPad_Buf;
  reg [31:0]  rFCS_Buf;

  //==========================================
  // eth_tx_ctrl
  //==========================================
  eth_tx_ctrl eth_tx_ctrl_inst (
    .Clk                (Clk),
    .Rst                (Rst),
    .Eth_Pkt_Rdy        (Eth_Pkt_Rdy),
    .Tx_Ctrl_FSM_State  (rTx_Ctrl_FSM_State),
    .Tx_En              (rTx_En),
    .Fifo_Empty         (rFifo_Empty),
    .Fifo_Rd            (rFifo_Rd_Valid),
    .Crc_En             (rCrc_En)
  );

  // register previous state
  always @(posedge Clk)
  begin
    rTx_Ctrl_FSM_State_d1 <= rTx_Ctrl_FSM_State;
  end

  //==========================================
  // data_fifo
  //==========================================
  // holds payload bytes prior to transmission

  async_fifo async_fifo_inst (
    .wclk     (Clk),
    .wrst_n   (~Rst),
    .winc     (Eth_Byte_Valid),
    .wdata    (Eth_Byte),
    .wfull    (),
    .awfull   (),
    .rclk     (Clk),
    .rrst_n   (~Rst),
    .rinc     (rFifo_Rd_Valid),
    .rdata    (rFifo_Rd_Data),
    .rempty   (rFifo_Empty),
    .arempty  ()
  );

  always @(posedge Clk)
  begin
    if (Rst)
      rFifo_Rd_Valid_d1 <= 0;
    else
      rFifo_Rd_Valid_d1 <= rFifo_Rd_Valid;
  end

  //==========================================
  // eth_buffer_regs
  //==========================================
  // in register, shift right by pMII_WIDTH to make
  // LSBs avaliable first for eth_data_mux

  always @(posedge Clk)
  begin
    if (Rst) begin
      rPreamble_Buf  <= 0;
      rSFD_Buf       <= 0;
      rDest_Addr_Buf <= 0;
      rSrc_Addr_Buf  <= 0;
      rLen_Type_Buf  <= 0;
      rPayload_Buf   <= 0;
      rPad_Buf       <= 0;
      rFCS_Buf       <= 0;
    end
    else begin
      case (rTx_Ctrl_FSM_State)

        `IDLE:
        begin
          rPreamble_Buf   <= {{pPreamble[7:0]},     {pPreamble[15:8]},
                              {pPreamble[23:16]},   {pPreamble[31:24]},
                              {pPreamble[39:32]},   {pPreamble[47:40]},
                              {pPreamble[55:48]}};
          rSFD_Buf        <= pSFD;
          rDest_Addr_Buf  <= {{pDest_Addr[7:0]},    {pDest_Addr[15:8]},
                              {pDest_Addr[23:16]},  {pDest_Addr[31:24]},
                              {pDest_Addr[39:32]},  {pDest_Addr[47:40]}};
          rSrc_Addr_Buf   <= {{pSrc_Addr[7:0]},     {pSrc_Addr[15:8]},
                              {pSrc_Addr[23:16]},   {pSrc_Addr[31:24]},
                              {pSrc_Addr[39:32]},   {pSrc_Addr[47:40]}};
          rLen_Type_Buf   <= {{pLen_Type[7:0]},     {pLen_Type[15:8]}};
          rPad_Buf        <= 0; // unused
        end

        `PREAMBLE:
        begin
          rPreamble_Buf <= rPreamble_Buf >> `pMII_WIDTH;
        end

        `SFD:
        begin
          rSFD_Buf <= rSFD_Buf >> `pMII_WIDTH;
        end

        `DEST_ADDR:
        begin
          rDest_Addr_Buf <= rDest_Addr_Buf >> `pMII_WIDTH;
        end

        `SRC_ADDR:
        begin
          rSrc_Addr_Buf <= rSrc_Addr_Buf >> `pMII_WIDTH;
        end

        `LEN_TYPE:
        begin
          rLen_Type_Buf <= rLen_Type_Buf >> `pMII_WIDTH;
          rPayload_Buf <= rFifo_Rd_Data;
        end

        `DATA:
        begin
          if (rFifo_Rd_Valid_d1)
            rPayload_Buf <= rFifo_Rd_Data;
          else
            rPayload_Buf <= rPayload_Buf >> `pMII_WIDTH;
        end

        `FCS:
        begin
          if (rTx_Ctrl_FSM_State_d1 == `DATA)
            rFCS_Buf <= (wCrc_Computed_Tx >> `pMII_WIDTH);
          else
            rFCS_Buf <= rFCS_Buf >> `pMII_WIDTH;
        end

        default:
        begin
          rPreamble_Buf <= 0;
          rSFD_Buf      <= 0;
          rDest_Addr_Buf<= 0;
          rSrc_Addr_Buf <= 0;
          rLen_Type_Buf <= 0;
        end

      endcase
    end
  end

  //==========================================
  // eth_data_mux
  //==========================================
  // muxes data to be transmitted

  assign Txd = rTx_Data;

  always @(*)
  begin
    case(rTx_Ctrl_FSM_State)
      `IDLE:
        rTx_Data = 0;
      `PREAMBLE:
        rTx_Data = rPreamble_Buf[`pMII_WIDTH-1:0];
      `SFD:
        rTx_Data = rSFD_Buf[`pMII_WIDTH-1:0];
      `DEST_ADDR:
        rTx_Data = rDest_Addr_Buf[`pMII_WIDTH-1:0];
      `SRC_ADDR:
        rTx_Data = rSrc_Addr_Buf[`pMII_WIDTH-1:0]; 
      `LEN_TYPE:
        rTx_Data = rLen_Type_Buf[`pMII_WIDTH-1:0];
      `DATA:
        rTx_Data = rPayload_Buf[`pMII_WIDTH-1:0];
      `PAD:
        rTx_Data = rPad_Buf[`pMII_WIDTH-1:0];
      `FCS:
        if (rTx_Ctrl_FSM_State_d1 == `DATA)
          rTx_Data = wCrc_Computed_Tx[`pMII_WIDTH-1:0];
        else
          rTx_Data = rFCS_Buf[`pMII_WIDTH-1:0];

      default:
        rTx_Data = 0;
    endcase
  end

  //==========================================
  // crc
  //==========================================
  // computes 32-bit CRC for transmitted data

  // pipeline crc_en
  always @(posedge Clk)
  begin
    if (Rst) begin
      rCrc_En_d1 <= 0;
      rCrc_En_d2 <= 0;
    end 
    else begin
      rCrc_En_d1 <= rCrc_En;
      rCrc_En_d2 <= rCrc_En_d1;
    end
  end

  // form up bytes for crc, indicate when formed byte is valid
  assign wCrc_Byte_Valid = (rCrc_Bits_Cnt == 0) & (rCrc_En_d1 != 0);

  always @(posedge Clk)
  begin
    if (Rst)
      rCrc_Byte <= 0;
    else begin
      if (rCrc_En) begin
        rCrc_Bits_Cnt <= rCrc_Bits_Cnt + 1;
        rCrc_Byte <= {rTx_Data, rCrc_Byte[7:2]};
      end
      else begin
        rCrc_Bits_Cnt <= 0;
        rCrc_Byte <= 0;
      end
    end
  end

  // instantiate crc generator
  eth_crc_gen eth_crc_gen_inst (
    .Clk      (Clk),
    .Rst      (Rst),
    .Crc_Req  (rCrc_En),
    .Byte_Rdy (wCrc_Byte_Valid),
    .Byte     (rCrc_Byte),
    .Crc_Out  (wCrc_Out)
  );

  // only update rCrc_Computed when byte is ready
  assign wCrc_Computed = (wCrc_Byte_Valid) ? wCrc_Out : rCrc_Computed;

  always @(posedge Clk)
  begin
    if (wCrc_Byte_Valid & rCrc_En_d2)
      rCrc_Computed <= wCrc_Out;
  end

  // flip crc byte order for transmission
  assign wCrc_Computed_Tx = {wCrc_Computed[7:0], wCrc_Computed[15:8],
                             wCrc_Computed[23:16], wCrc_Computed[31:24]};
    
endmodule
