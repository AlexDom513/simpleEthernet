//--------------------------------------------------------------------
// simpleEthernet
// proj_top.v
// Project top-level
// 8/9/24
//--------------------------------------------------------------------

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
  input  Eth_Clk,
  input  Eth_Rst,
  input  Eth_Tx_Test_En,
  input  Crs_Dv,
  input  Rxd,
  output Tx_En,
  output Txd,
  output MDC_Clk,
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
  wire Eth_Clk;
  wire Eth_Rst;
  wire Eth_Tx_Test_En;
  wire Crs_Dv;
  wire [1:0] Rxd;
  wire [1:0] Txd;
  wire Tx_En;

  // NOTE: PS must boot for reset to be released
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

  eth_top eth_top_inst (

    // Block Design
    .AXI_Clk              (AXI_Clk),
    .AXI_Rstn             (AXI_Rstn),
    .AXI_awvalid          (M_AXI_0_awvalid),
    .AXI_awready          (M_AXI_0_awready),
    .AXI_awaddr           (M_AXI_0_awaddr),
    .AXI_wvalid           (M_AXI_0_awvalid),
    .AXI_wready           (M_AXI_0_wready),
    .AXI_wdata            (M_AXI_0_wdata),
    .AXI_bvalid           (M_AXI_0_bvalid),
    .AXI_bresp            (M_AXI_0_bresp),
    .AXI_bready           (M_AXI_0_bready),
    .AXI_arvalid          (M_AXI_0_arvalid),
    .AXI_arready          (M_AXI_0_arready),
    .AXI_araddr           (M_AXI_0_araddr),
    .AXI_rready           (M_AXI_0_rready),
    .AXI_rdata            (M_AXI_0_rdata),
    .AXI_rvalid           (M_AXI_0_rvalid),
    .AXI_rresp            (M_AXI_0_rresp),

    // Data Interface
    .Eth_Byte_Rx          (),
    .Eth_Byte_Valid_Rx    (),
    .Eth_Byte_Tx          (),
    .Eth_Byte_Valid_Tx    (),

    // MDIO Interface
    .MDC_Clk              (MDC_Clk),
    .MDIO                 (MDIO),

    // Ethernet Interface
    .Eth_Clk              (Eth_Clk),
    .Eth_Rst              (Eth_Rst),
    .Eth_Tx_Test_En       (Eth_Tx_Test_En),
    .Crs_Dv               (Crs_Dv),
    .Rxd                  (Rxd),
    .Txd                  (Txd),
    .Tx_En                (Tx_En)
  );

endmodule
