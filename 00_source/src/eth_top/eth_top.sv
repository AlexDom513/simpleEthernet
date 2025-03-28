//--------------------------------------------------------------------
// simpleEthernet
// eth_top.sv
// Experiment implementing simple ethernet communication
// 6/30/24
//--------------------------------------------------------------------

module eth_top #(
  parameter gLoopback_En=1) (

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
  localparam TX_TEST = 0;
  localparam LOOPBACK_TEST = 1;

  //------------------------------------------
  // Logic
  //------------------------------------------

  // Clock Enable (for 1 MHz MDC Clock)
  logic wMDC_Clk;
  logic wMDC_Rst;

  // Test TX Data
  logic [7:0] wEth_Byte_Test;
  logic       wEth_Byte_Valid_Test;

  // Loopback (RX) to TX Data
  logic [9:0] wEth_Byte_Loopback;
  logic       wEth_Byte_Valid_Loopback;

  // Selected TX Data
  logic [9:0] wEth_Byte;
  logic       wEth_Byte_Valid;

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
    .Recv_Byte     (wEth_Byte_Loopback),
    .Recv_Byte_Rdy (wEth_Byte_Valid_Loopback)
  );

  //------------------------------------------
  // eth_tx
  //------------------------------------------
  // automatically inserts Preamble, SFD, MAC destination,
  // MAC source, Ethertype, and CRC. User is responsible
  // for providing all other Payload bytes
  //
  // to TX, write 1 byte (Eth_Byte) per CC while
  // asserting (Eth_Byte_Valid), once all desired bytes are
  // written, assert (Eth_Pkt_Rdy) to kickoff send

  eth_tx_tpg  eth_tx_tpg_inst (
    .Clk                 (Eth_Clk),
    .Rst                 (Eth_Rst),
    .Eth_Tx_Test_En      (Eth_Tx_Test_En),
    .Eth_Byte_Test       (wEth_Byte_Test),
    .Eth_Byte_Valid_Test (wEth_Byte_Valid_Test)
  );

  // mux test or loopback data depending on generic
  case(gLoopback_En)
    TX_TEST:
    begin
      assign wEth_Byte       = wEth_Byte_Test;
      assign wEth_Byte_Valid = wEth_Byte_Valid_Test;
    end

    LOOPBACK_TEST:
    begin
      assign wEth_Byte       = wEth_Byte_Loopback;
      assign wEth_Byte_Valid = wEth_Byte_Valid_Loopback;
    end

    default:
    begin
      assign wEth_Byte       = wEth_Byte_Test;
      assign wEth_Byte_Valid = wEth_Byte_Valid_Test;
    end
  endcase

  eth_tx eth_tx_inst (
    .Clk            (Eth_Clk),
    .Rst            (Eth_Rst),
    .Eth_Byte       (wEth_Byte),
    .Eth_Byte_Valid (wEth_Byte_Valid),
    .Txd            (Txd),
    .Tx_En          (Tx_En)
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
