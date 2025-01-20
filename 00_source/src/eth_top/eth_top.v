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

  // Test TX Data
  reg         rEth_Tx_Test_En_meta;
  reg         rEth_Tx_Test_En;
  reg         rEth_Tx_Test_Start;
  reg [7:0]   rEth_Byte_Test;
  reg         rEth_Byte_Valid_Test;
  reg         rEth_Pkt_Rdy_Test;

  // MDIO DMA
  wire [4:0]  wMDIO_Phy_Addr_Req;
  wire [4:0]  wMDIO_Reg_Addr_Req;
  wire        wMDIO_Transc_Type_Req;
  wire        wMDIO_En_Req;
  wire [15:0] wMDIO_Wr_Dat_Req;
  wire [5:0]  wMDIO_Reg_Addr_Recv;
  wire        wMDIO_Data_Valid_Recv;
  wire [31:0] wMDIO_Data_Recv;
  wire        wMDIO_Busy_Recv;
  wire        wEth_Tx_Test_En;

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
  // including some test infrastructure

  always @(posedge Eth_Clk)
  begin
  if (Eth_Rst) begin
    rEth_Tx_Test_En_meta <= 0;
    rEth_Tx_Test_En <= 0;
  end
  else begin
    rEth_Tx_Test_En_meta <= wEth_Tx_Test_En;
    rEth_Tx_Test_En <= rEth_Tx_Test_En_meta;
  end
  end

  always @(posedge Eth_Clk)
  begin
    if (Eth_Rst)
      rEth_Tx_Test_Start <= 0;
    else
      rEth_Tx_Test_Start <= rEth_Tx_Test_En;
  end

  always @(posedge Eth_Clk)
  begin
  if (Eth_Rst) begin
    rEth_Byte_Valid_Test <= 0;
    rEth_Byte_Test <= 0;
  end
  else begin
    if (rEth_Tx_Test_En && ~rEth_Tx_Test_Start) begin
      rEth_Byte_Valid_Test <= 1;
      rEth_Byte_Test <= rEth_Byte_Test + 1;
    end

    else if (rEth_Tx_Test_En && rEth_Byte_Test > 0 && rEth_Byte_Test < 40) begin
      rEth_Byte_Valid_Test <= 1;
      rEth_Byte_Test <= rEth_Byte_Test + 1;
    end

    else if (rEth_Tx_Test_En && rEth_Byte_Test == 40) begin
      rEth_Byte_Valid_Test <= 0;
      rEth_Byte_Test <= 0;
      rEth_Pkt_Rdy_Test <= 1;
    end

    else begin
      rEth_Byte_Valid_Test <= 0;
      rEth_Byte_Test <= 0;
      rEth_Pkt_Rdy_Test <= 0;
    end
  end
  end

  eth_tx eth_tx_inst (
    .Clk            (Eth_Clk),
    .Rst            (Eth_Rst),
    .Eth_Byte       (rEth_Byte_Test),
    .Eth_Byte_Valid (rEth_Byte_Valid_Test),
    .Eth_Pkt_Rdy    (rEth_Pkt_Rdy_Test),
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

  //==========================================
  // eth_mdio
  //==========================================
  eth_mdio  eth_mdio_inst (
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
    .MDIO_Data              (wMDIO_Data_Recv),
    .MDIO_Busy              (wMDIO_Busy_Recv)
  );

endmodule
