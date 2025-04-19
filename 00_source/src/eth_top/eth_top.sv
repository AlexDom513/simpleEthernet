//--------------------------------------------------------------------
// simpleEthernet
// eth_top.sv
// Experiment implementing simple ethernet communication
// 6/30/24
//--------------------------------------------------------------------

module eth_top #(
  parameter pBuild_Option=0
  )(

  // AXI-Lite Interface
  input  logic        AXI_Clk,
  input  logic        AXI_Rstn,
  input  logic        AXI_awvalid,
  output logic        AXI_awready,
  input  logic [31:0] AXI_awaddr,
  input  logic        AXI_wvalid,
  output logic        AXI_wready,
  input  logic [31:0] AXI_wdata,
  output logic        AXI_bvalid,
  output logic [1:0]  AXI_bresp,
  input  logic        AXI_bready,
  input  logic        AXI_arvalid,
  output logic        AXI_arready,
  input  logic [31:0] AXI_araddr,
  input  logic        AXI_rready,
  output logic [31:0] AXI_rdata,
  output logic        AXI_rvalid,
  output logic [1:0]  AXI_rresp,

  // Data Interface
  output logic [9:0]  Eth_Byte_Rx,
  output logic        Eth_Byte_Valid_Rx,
  output logic [9:0]  Eth_Byte_Tx,
  output logic        Eth_Byte_Valid_Tx,

  // MDIO Interface
  output logic        MDC_Clk,
  inout  logic        MDIO,

  // Ethernet Interface
  input  logic        Eth_Clk,
  input  logic        Eth_Rst,
  input  logic        Eth_Tx_Test_En,
  input  logic        Crs_Dv,
  input  logic [1:0]  Rxd,
  output logic [1:0]  Txd,
  output logic        Tx_En
);

  //------------------------------------------
  // Constants
  //------------------------------------------
  localparam cLoopback = 0; // data entering RX is sent back to TX
  localparam cTx_Rx    = 1; // data enters RX and leaves eth_top, data sent to TX from outside eth_top
  localparam cTpg      = 2; // TX data created by TPG

  //------------------------------------------
  // Logic
  //------------------------------------------

  // Clock Enable (for 1 MHz MDC Clock)
  logic wMDC_Clk;
  logic wMDC_Rst;

  // Test TX Data
  logic [7:0]  wEth_Byte_Test;
  logic        wEth_Byte_Valid_Test;

  // RX Data
  logic [9:0]  wEth_Byte_Rx;
  logic        wEth_Byte_Valid_Rx;

  // Selected TX Data
  logic [9:0]  wEth_Byte_Tx;
  logic        wEth_Byte_Valid_Tx;

  // MDIO DMA
  logic [4:0]  wMDIO_Phy_Addr_Req;
  logic [4:0]  wMDIO_Reg_Addr_Req;
  logic        wMDIO_Transc_Type_Req;
  logic        wMDIO_En_Req;
  logic [15:0] wMDIO_Wr_Dat_Req;
  logic [5:0]  wMDIO_Reg_Addr_Recv;
  logic        wMDIO_Data_Valid_Recv;
  logic [31:0] wMDIO_Data_Recv;
  logic        wMDIO_Busy_Recv;
  logic        wEth_Tx_Test_En;

  //------------------------------------------
  // clk_rst_mgr
  //------------------------------------------
  clk_rst_mgr  clk_rst_mgr_inst (
    .Clk     (AXI_Clk),
    .Rstn    (AXI_Rstn),
    .MDC_Clk (wMDC_Clk),
    .MDC_Rst (wMDC_Rst)
  );
  assign MDC_Clk = wMDC_Clk;

  //------------------------------------------
  // eth_rx
  //------------------------------------------
  eth_rx  eth_rx_inst (
    .Clk           (Eth_Clk),
    .Rst           (Eth_Rst),
    .Crs_Dv        (Crs_Dv),
    .Rxd           (Rxd),
    .Recv_Byte     (wEth_Byte_Rx),
    .Recv_Byte_Rdy (wEth_Byte_Valid_Rx)
  );
  assign Eth_Byte_Rx = wEth_Byte_Rx;
  assign Eth_Byte_Valid_Rx = wEth_Byte_Valid_Rx;

  //------------------------------------------
  // eth_tx
  //------------------------------------------
  // automatically inserts Preamble, SFD, MAC destination,
  // MAC source, Ethertype, and CRC. User is responsible
  // for providing all other Payload bytes
  //
  // - to TX, write 1 byte (Eth_Byte) per CC while asserting (Eth_Byte_Valid)
  // - to guarantee proper readout, all bytes belonging to same packet must enter on
  //   consecutive clock cycles
  // - first and last bytes of a packet must be marked with proper SOP (bit 9) & EOP (bit 8) flags

  // loopback, tx_rx, or test data depending on parameter
  case(pBuild_Option)
    cLoopback:
    begin
      assign wEth_Byte_Tx       = wEth_Byte_Rx;
      assign wEth_Byte_Valid_Tx = wEth_Byte_Valid_Rx;
    end

    cTx_Rx:
    begin
      assign wEth_Byte_Tx       = Eth_Byte_Tx;
      assign wEth_Byte_Valid_Tx = Eth_Byte_Valid_Tx;
    end

    cTpg:
    begin
      assign wEth_Byte_Tx       = wEth_Byte_Test;
      assign wEth_Byte_Valid_Tx = wEth_Byte_Valid_Test;
    end

    default:
    begin
      assign wEth_Byte_Tx       = wEth_Byte_Test;
      assign wEth_Byte_Valid_Tx = wEth_Byte_Valid_Test;
    end
  endcase

  eth_tx eth_tx_inst (
    .Clk            (Eth_Clk),
    .Rst            (Eth_Rst),
    .Eth_Byte       (wEth_Byte_Tx),
    .Eth_Byte_Valid (wEth_Byte_Valid_Tx),
    .Txd            (Txd),
    .Tx_En          (Tx_En)
  );

  //------------------------------------------
  // eth_tx_tpg
  //------------------------------------------
  eth_tx_tpg  eth_tx_tpg_inst (
    .Clk                 (Eth_Clk),
    .Rst                 (Eth_Rst),
    .Eth_Tx_Test_En      (Eth_Tx_Test_En),
    .Eth_Byte_Test       (wEth_Byte_Test),
    .Eth_Byte_Valid_Test (wEth_Byte_Valid_Test)
  );

  //------------------------------------------
  // eth_regs
  //------------------------------------------
  eth_regs eth_regs_inst (
    .AXI_Clk              (AXI_Clk),
    .AXI_Rstn             (AXI_Rstn),
    .MDC_Clk              (wMDC_Clk),
    .MDC_Rst              (wMDC_Rst),
    .AXI_awvalid          (AXI_awvalid),
    .AXI_awready          (AXI_awready),
    .AXI_awaddr           (AXI_awaddr), 
    .AXI_wvalid           (AXI_wvalid), 
    .AXI_wready           (AXI_wready), 
    .AXI_wdata            (AXI_wdata),  
    .AXI_bvalid           (AXI_bvalid), 
    .AXI_bresp            (AXI_bresp),
    .AXI_bready           (AXI_bready),
    .AXI_arvalid          (AXI_arvalid),
    .AXI_arready          (AXI_arready),
    .AXI_araddr           (AXI_araddr),
    .AXI_rready           (AXI_rready),
    .AXI_rdata            (AXI_rdata),
    .AXI_rvalid           (AXI_rvalid),
    .AXI_rresp            (AXI_rresp),
    .MDIO_Phy_Addr_Req    (wMDIO_Phy_Addr_Req),
    .MDIO_Reg_Addr_Req    (wMDIO_Reg_Addr_Req),
    .MDIO_Transc_Type_Req (wMDIO_Transc_Type_Req),
    .MDIO_En_Req          (wMDIO_En_Req),
    .MDIO_Wr_Dat_Req      (wMDIO_Wr_Dat_Req),
    .MDIO_Reg_Addr_Recv   (wMDIO_Reg_Addr_Recv),
    .MDIO_Data_Valid_Recv (wMDIO_Data_Valid_Recv),
    .MDIO_Data_Recv       (wMDIO_Data_Recv),
    .MDIO_Busy_Recv       (wMDIO_Busy_Recv),
    .Eth_Tx_Test_En       (wEth_Tx_Test_En)
  );

  //------------------------------------------
  // eth_mdio
  //------------------------------------------
  eth_mdio  eth_mdio_inst (
    .Clk                   (wMDC_Clk),
    .Rst                   (wMDC_Rst),
    .MDIO                  (MDIO),
    .MDIO_Phy_Addr_Recv    (wMDIO_Phy_Addr_Req),
    .MDIO_Reg_Addr_Recv    (wMDIO_Reg_Addr_Req),
    .MDIO_Transc_Type_Recv (wMDIO_Transc_Type_Req),
    .MDIO_En_Recv          (wMDIO_En_Req),
    .MDIO_Wr_Dat_Recv      (wMDIO_Wr_Dat_Req),
    .MDIO_Reg_Addr         (wMDIO_Reg_Addr_Recv),
    .MDIO_Data_Valid       (wMDIO_Data_Valid_Recv),
    .MDIO_Data             (wMDIO_Data_Recv),
    .MDIO_Busy             (wMDIO_Busy_Recv)
  );

endmodule
