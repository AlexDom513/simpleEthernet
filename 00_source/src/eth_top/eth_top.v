//====================================================================
// 02_simple_ethernet
// eth_top.v
// Experiment implementing simple ethernet communication
// 6/30/24
//====================================================================

module eth_top(

  // AXI-Lite Interface
  input  wire         Clk_AXI,
  input  wire         Rstn_AXI,
  input  wire         AXI_Master_awalid,
  output wire         AXI_Slave_awready,
  input  wire [31:0]  AXI_Master_awaddr,
  input  wire         AXI_Master_wvalid,
  output wire         AXI_Slave_wready, 
  input  wire [31:0]  AXI_Master_wdata,
  output wire         AXI_Slave_bvalid,
  output wire [1:0]   AXI_Slave_bresp,
  input  wire         AXI_Master_bready,
  input  wire         AXI_Master_arvalid,
  output wire         AXI_Slave_arready,
  input  wire [31:0]  AXI_Master_araddr,
  input  wire         AXI_Master_rready,
  output wire [31:0]  AXI_Slave_rdata,
  output wire         AXI_Slave_rvalid,
  output wire [1:0]   AXI_Slave_rresp,

  // AXI Stream Interface
  input  wire [7:0]   AXIS_Master_tdata,
  input  wire         AXIS_Master_tlast,
  output wire         AXIS_Slave_tready,
  input  wire         AXIS_Master_tvalid,

  // MDIO Interface
  output wire         Clk_MDC,
  inout  wire         MDIO,

  // Ethernet Interface
  input  wire         Clk_Eth,
  input  wire         Rst_Eth,
  output wire [1:0]   Tx_Data,
  output wire         Tx_En,

  // Debug LED
  output reg [3:0]    Led
);

  //==========================================
  // Constants
  //==========================================
  parameter LED_PERIOD  = 30'h2FAF080;

  //==========================================
  // Wires/Registers
  //==========================================

  // Clock Enable (for 1 MHz MDC Clock)
  wire wClk_MDC;
  wire wRst_MDC;

  // MDIO DMA
  wire [4:0]  wMDIO_Phy_Addr_Req;
  wire [4:0]  wMDIO_Reg_Addr_Req;
  wire        wMDIO_Transc_Type_Req;
  wire        wMDIO_En_Req;
  wire [15:0] wMDIO_Wr_Dat_Req;
  wire [5:0]  wMDIO_Reg_Addr_Recv;
  wire        wMDIO_Data_Valid_Recv;
  wire [31:0] wMDIO_Data_Recv;

  // led monitor
  reg  [3:0]  rLed_d1;
  reg  [29:0] rLed_Cnt;

  //==========================================
  // clk_rst_mgr
  //==========================================
  clk_rst_mgr  clk_rst_mgr_inst (
    .Clk        (Clk_AXI),
    .Rstn       (Rstn_AXI),
    .Clk_MDC    (wClk_MDC),
    .Rst_MDC    (wRst_MDC)
  );
  assign Clk_MDC = wClk_MDC;

  //==========================================
  // eth_packet_former
  //==========================================
  eth_packet_former eth_packet_former(
    .Clk        (Clk_Eth),
    .Rst        (Rst_Eth),
    .Dat_Rdy    (AXIS_Slave_tready),
    .Dat_En     (AXIS_Master_tvalid), // valid signal for data, currently coming from Zynq
    .Data       (AXIS_Master_tdata),  // data we want to send, currently coming from Zynq
    .Data_Last  (AXIS_Master_tlast),
    .Tx_Data    (Tx_Data),
    .Tx_En      (Tx_En)
  );

  //==========================================
  // eth_regs
  //==========================================
  eth_regs eth_regs(
    .Clk_Usr              (Clk_AXI),
    .Rstn_Usr             (Rstn_AXI),
    .Clk_MDC              (wClk_MDC),
    .Rst_MDC              (wRst_MDC),
    .AXI_Master_awalid    (AXI_Master_awalid), 
    .AXI_Slave_awready    (AXI_Slave_awready),
    .AXI_Master_awaddr    (AXI_Master_awaddr), 
    .AXI_Master_wvalid    (AXI_Master_wvalid), 
    .AXI_Slave_wready     (AXI_Slave_wready), 
    .AXI_Master_wdata     (AXI_Master_wdata),  
    .AXI_Slave_bvalid     (AXI_Slave_bvalid), 
    .AXI_Slave_bresp      (AXI_Slave_bresp),
    .AXI_Master_bready    (AXI_Master_bready),
    .AXI_Master_arvalid   (AXI_Master_arvalid),
    .AXI_Slave_arready    (AXI_Slave_arready),
    .AXI_Master_araddr    (AXI_Master_araddr),
    .AXI_Master_rready    (AXI_Master_rready),
    .AXI_Slave_rdata      (AXI_Slave_rdata),
    .AXI_Slave_rvalid     (AXI_Slave_rvalid),
    .AXI_Slave_rresp      (AXI_Slave_rresp),
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
    .Clk                    (wClk_MDC),
    .Rst                    (wRst_MDC),
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

  //==========================================
  // debug_led
  //==========================================
  // after first packet is sent, all following
  // packets will be sent when we blink led

  always @(posedge Clk_Eth)
  begin
    if (Rst_Eth) begin
      Led <= 0;
      rLed_Cnt <= 0;
    end
    else begin
      rLed_Cnt <= rLed_Cnt + 1;
      if (rLed_Cnt == LED_PERIOD-1) begin
        Led[0] <= ~Led[0];
        rLed_Cnt <= 0;
      end
    end
  end

endmodule
