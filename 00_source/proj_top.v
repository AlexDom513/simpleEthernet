//====================================================================
// 02_simple_ethernet
// proj_top.v
// 8/9/24
//====================================================================

module proj_top(

  // Block Design
  inout [14:0]DDR_addr,
  inout [2:0]DDR_ba,
  inout DDR_cas_n,
  inout DDR_ck_n,
  inout DDR_ck_p,
  inout DDR_cke,
  inout DDR_cs_n,
  inout [3:0]DDR_dm,
  inout [31:0]DDR_dq,
  inout [3:0]DDR_dqs_n,
  inout [3:0]DDR_dqs_p,
  inout DDR_odt,
  inout DDR_ras_n,
  inout DDR_reset_n,
  inout DDR_we_n,
  inout FIXED_IO_ddr_vrn,
  inout FIXED_IO_ddr_vrp,
  inout [53:0]FIXED_IO_mio,
  inout FIXED_IO_ps_clk,
  inout FIXED_IO_ps_porb,
  inout FIXED_IO_ps_srstb,

  // Ethernet PHY
  input  Clk_Eth,
  output Tx_En,
  output Tx0,
  output Tx1,
  output Clk_MDC,
  inout  MDIO
);

  // Block Design
  wire AXI_Clk;
  wire AXI_Rstn;
  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0] DDR_dm;
  wire [31:0] DDR_dq;
  wire [3:0] DDR_dqs_n;
  wire [3:0] DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0] FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire [7:0]M_AXIS_0_tdata;
  wire M_AXIS_0_tlast;
  wire M_AXIS_0_tready;
  wire M_AXIS_0_tvalid;
  wire [31:0] M_AXI_0_araddr;
  wire [2:0] M_AXI_0_arprot;
  wire M_AXI_0_arready;
  wire M_AXI_0_arvalid;
  wire [31:0] M_AXI_0_awaddr;
  wire [2:0] M_AXI_0_awprot;
  wire M_AXI_0_awready;
  wire M_AXI_0_awvalid;
  wire M_AXI_0_bready;
  wire [1:0] M_AXI_0_bresp;
  wire M_AXI_0_bvalid;
  wire [31:0] M_AXI_0_rdata;
  wire M_AXI_0_rready;
  wire [1:0] M_AXI_0_rresp;
  wire M_AXI_0_rvalid;
  wire [31:0] M_AXI_0_wdata;
  wire M_AXI_0_wready;
  wire [3:0] M_AXI_0_wstrb;
  wire M_AXI_0_wvalid;

  // Ethernet PHY
  wire Clk_Eth;
  wire Rst_Eth;
  wire Eth_En;
  wire [1:0] Tx_Data;
  wire Tx_En;

  // Debug LED
  wire Led;

  assign Tx0 = Tx_Data[0];
  assign Tx1 = Tx_Data[1];

  bd_wrapper  bd_wrapper_inst (
    .AXI_Clk              (AXI_Clk),
    .AXI_Rstn             (AXI_Rstn),
    .DDR_addr             (DDR_addr),
    .DDR_ba               (DDR_ba),
    .DDR_cas_n            (DDR_cas_n),
    .DDR_ck_n             (DDR_ck_n),
    .DDR_ck_p             (DDR_ck_p),
    .DDR_cke              (DDR_cke),
    .DDR_cs_n             (DDR_cs_n),
    .DDR_dm               (DDR_dm),
    .DDR_dq               (DDR_dq),
    .DDR_dqs_n            (DDR_dqs_n),
    .DDR_dqs_p            (DDR_dqs_p),
    .DDR_odt              (DDR_odt),
    .DDR_ras_n            (DDR_ras_n),
    .DDR_reset_n          (DDR_reset_n),
    .DDR_we_n             (DDR_we_n),
    .FIXED_IO_ddr_vrn     (FIXED_IO_ddr_vrn),
    .FIXED_IO_ddr_vrp     (FIXED_IO_ddr_vrp),
    .FIXED_IO_mio         (FIXED_IO_mio),
    .FIXED_IO_ps_clk      (FIXED_IO_ps_clk),
    .FIXED_IO_ps_porb     (FIXED_IO_ps_porb),
    .FIXED_IO_ps_srstb    (FIXED_IO_ps_srstb),
    .M_AXIS_0_tdata       (M_AXIS_0_tdata),
    .M_AXIS_0_tlast       (M_AXIS_0_tlast),
    .M_AXIS_0_tready      (M_AXIS_0_tready),
    .M_AXIS_0_tvalid      (M_AXIS_0_tvalid),
    .M_AXI_0_araddr       (M_AXI_0_araddr),
    .M_AXI_0_arprot       (M_AXI_0_arprot),
    .M_AXI_0_arready      (M_AXI_0_arready),
    .M_AXI_0_arvalid      (M_AXI_0_arvalid),
    .M_AXI_0_awaddr       (M_AXI_0_awaddr),
    .M_AXI_0_awprot       (M_AXI_0_awprot),
    .M_AXI_0_awready      (M_AXI_0_awready),
    .M_AXI_0_awvalid      (M_AXI_0_awvalid),
    .M_AXI_0_bready       (M_AXI_0_bready),
    .M_AXI_0_bresp        (M_AXI_0_bresp),
    .M_AXI_0_bvalid       (M_AXI_0_bvalid),
    .M_AXI_0_rdata        (M_AXI_0_rdata),
    .M_AXI_0_rready       (M_AXI_0_rready),
    .M_AXI_0_rresp        (M_AXI_0_rresp),
    .M_AXI_0_rvalid       (M_AXI_0_rvalid),
    .M_AXI_0_wdata        (M_AXI_0_wdata),
    .M_AXI_0_wready       (M_AXI_0_wready),
    .M_AXI_0_wstrb        (M_AXI_0_wstrb),
    .M_AXI_0_wvalid       (M_AXI_0_wvalid)
  );

  eth_top  eth_top_inst (

    // Block Design
    .Clk_AXI              (AXI_Clk),
    .Rstn_AXI             (AXI_Rstn),
    .AXI_Master_awalid    (M_AXI_0_awvalid),
    .AXI_Slave_awready    (M_AXI_0_awready),
    .AXI_Master_awaddr    (M_AXI_0_awaddr),
    .AXI_Master_wvalid    (M_AXI_0_awvalid),
    .AXI_Slave_wready     (M_AXI_0_wready),
    .AXI_Master_wdata     (M_AXI_0_wdata),
    .AXI_Slave_bvalid     (M_AXI_0_bvalid),
    .AXI_Slave_bresp      (M_AXI_0_bresp),
    .AXI_Master_bready    (M_AXI_0_bready),
    .AXI_Master_arvalid   (M_AXI_0_arvalid),
    .AXI_Slave_arready    (M_AXI_0_arready),
    .AXI_Master_araddr    (M_AXI_0_araddr),
    .AXI_Master_rready    (M_AXI_0_rready),
    .AXI_Slave_rdata      (M_AXI_0_rdata),
    .AXI_Slave_rvalid     (M_AXI_0_rvalid),
    .AXI_Slave_rresp      (M_AXI_0_rresp),
    .AXIS_Master_tdata    (M_AXIS_0_tdata),
    .AXIS_Master_tlast    (M_AXIS_0_tlast),
    .AXIS_Slave_tready    (M_AXIS_0_tready),
    .AXIS_Master_tvalid   (M_AXIS_0_tvalid),
    
    // MDIO Interface
    .Clk_MDC              (Clk_MDC),
    .MDIO                 (MDIO),

    // Ethernet Interface
    .Clk_Eth              (Clk_Eth),          // TODO: NEED TO ADD CDC FOR AXI DATA!!!
    .Rst_Eth              (Rst_Eth),          // need to tie this to something, maybe reset issued by zynq?
    .Tx_Data              (Tx_Data),
    .Tx_En                (Tx_En),

    // Debug LED
    .Led                  (Led)
  );

endmodule
