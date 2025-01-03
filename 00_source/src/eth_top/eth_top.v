//====================================================================
// simpleEthernet
// eth_top.v
// Experiment implementing simple ethernet communication
// 6/30/24
//====================================================================

module eth_top (

  // AXI-Lite Interface
  input  wire         AXI_Clk,
  input  wire         AXI_Rstn,
  input  wire         AXI_awvalid,
  output wire         AXI_awready,
  input  wire [31:0]  AXI_awaddr,
  input  wire         AXI_wvalid,
  output wire         AXI_wready,
  input  wire [31:0]  AXI_wdata,
  output wire         AXI_bvalid,
  output wire [1:0]   AXI_bresp,
  input  wire         AXI_bready,
  input  wire         AXI_arvalid,
  output wire         AXI_arready,
  input  wire [31:0]  AXI_araddr,
  input  wire         AXI_rready,
  output wire [31:0]  AXI_rdata,
  output wire         AXI_rvalid,
  output wire [1:0]   AXI_rresp,

  // AXI Stream Interface
  input  wire [7:0]   AXIS_Master_tdata,
  input  wire         AXIS_Master_tlast,
  output wire         AXIS_Slave_tready,
  input  wire         AXIS_Master_tvalid,

  // MDIO Interface
  output wire         MDC_Clk,
  inout  wire         MDIO,

  // Ethernet Interface
  input  wire         Eth_Clk,
  input  wire         Eth_Rst,
  input  wire [1:0]   Rxd,
  output wire [1:0]   Txd,
  output wire         Tx_En
);

  //==========================================
  // Wires/Registers
  //==========================================

  // Clock Enable (for 1 MHz MDC Clock)
  wire wMDC_Clk;
  wire wMDC_Rst;

  // MDIO DMA
  wire [4:0]  wMDIO_Phy_Addr_Req;
  wire [4:0]  wMDIO_Reg_Addr_Req;
  wire        wMDIO_Transc_Type_Req;
  wire        wMDIO_En_Req;
  wire [15:0] wMDIO_Wr_Dat_Req;
  wire [5:0]  wMDIO_Reg_Addr_Recv;
  wire        wMDIO_Data_Valid_Recv;
  wire [31:0] wMDIO_Data_Recv;

  //==========================================
  // clk_rst_mgr
  //==========================================
  clk_rst_mgr  clk_rst_mgr_inst (
    .Clk        (AXI_Clk),
    .Rstn       (AXI_Rstn),
    .MDC_Clk    (wMDC_Clk),
    .MDC_Rst    (wMDC_Rst)
  );
  assign MDC_Clk = wMDC_Clk;

  //==========================================
  // eth_rx
  //==========================================
  eth_rx  eth_rx_inst (
    .Clk        (Eth_Clk),
    .Rst        (Eth_Rst),
    .Rxd        (Rxd),
    .Crc_Valid  ()
  );

  //==========================================
  // eth_tx
  //==========================================
  eth_tx eth_tx_inst (
    .Clk            (Eth_Clk),
    .Rst            (Eth_Rst),
    .Eth_Byte       (0),
    .Eth_Byte_Valid (0),
    .Eth_Pkt_Rdy    (0),
    .Txd            (Txd),
    .Tx_En          (Tx_En)
  );

  //==========================================
  // eth_regs
  //==========================================
  eth_regs eth_regs_inst (
    .AXI_Clk              (AXI_Clk),
    .AXI_Rstn             (AXI_Rstn),
    .MDC_Clk              (wMDC_Clk),
    .MDC_Rst              (wMDC_Rst),
    .AXI_Master_awvalid   (AXI_awvalid),
    .AXI_Slave_awready    (AXI_awready),
    .AXI_Master_awaddr    (AXI_awaddr), 
    .AXI_Master_wvalid    (AXI_wvalid), 
    .AXI_Slave_wready     (AXI_wready), 
    .AXI_Master_wdata     (AXI_wdata),  
    .AXI_Slave_bvalid     (AXI_bvalid), 
    .AXI_Slave_bresp      (AXI_bresp),
    .AXI_Master_bready    (AXI_bready),
    .AXI_Master_arvalid   (AXI_arvalid),
    .AXI_Slave_arready    (AXI_arready),
    .AXI_Master_araddr    (AXI_araddr),
    .AXI_Master_rready    (AXI_rready),
    .AXI_Slave_rdata      (AXI_rdata),
    .AXI_Slave_rvalid     (AXI_rvalid),
    .AXI_Slave_rresp      (AXI_rresp),
    .MDIO_Phy_Addr_Req    (wMDIO_Phy_Addr_Req),
    .MDIO_Reg_Addr_Req    (wMDIO_Reg_Addr_Req),
    .MDIO_Transc_Type_Req (wMDIO_Transc_Type_Req),
    .MDIO_En_Req          (wMDIO_En_Req),
    .MDIO_Wr_Dat_Req      (wMDIO_Wr_Dat_Req),
    .MDIO_Reg_Addr_Recv   (wMDIO_Reg_Addr_Recv),
    .MDIO_Data_Valid_Recv (wMDIO_Data_Valid_Recv),
    .MDIO_Data_Recv       (wMDIO_Data_Recv)
  );

  //==========================================
  // eth_mdio
  //==========================================
  eth_mdio  eth_mdio_inst(
    .Clk                    (wMDC_Clk),
    .Rst                    (wMDC_Rst),
    .MDIO                   (MDIO),
    .MDIO_Phy_Addr_Recv     (wMDIO_Phy_Addr_Req),
    .MDIO_Reg_Addr_Recv     (wMDIO_Reg_Addr_Req),
    .MDIO_Transc_Type_Recv  (wMDIO_Transc_Type_Req),
    .MDIO_En_Recv           (wMDIO_En_Req),
    .MDIO_Wr_Dat_Recv       (wMDIO_Wr_Dat_Req),
    .MDIO_Reg_Addr          (wMDIO_Reg_Addr_Recv),
    .MDIO_Data_Valid        (wMDIO_Data_Valid_Recv),
    .MDIO_Data              (wMDIO_Data_Recv)
  );

endmodule
