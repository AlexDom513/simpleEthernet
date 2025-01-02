//====================================================================
// 02_simple_ethernet
// eth_regs.v
// regs module using AXI4-Lite, eth_regs denoted as slave
//====================================================================

// AXI4Lite:
// https://docs.amd.com/r/en-US/pg085-axi4stream-infrastructure/AXI4-Lite-Interface-Signals
// https://docs.amd.com/r/en-US/pg165-cmac/AXI-User-Interface-Ports
// https://www.youtube.com/watch?v=okiTzvihHRA
// https://zipcpu.com/formal/2018/12/28/axilite.html

// Inferring AXI4Lite:
// https://docs.amd.com/r/en-US/ug994-vivado-ip-subsystems/List-of-Supported-X_-Attributes
// https://docs.amd.com/r/en-US/ug994-vivado-ip-subsystems/Inferring-AXI-Interfaces

//====================================================================

// Custom Register Descriptions (eth_mdio)
// (0)  MDIO Control Register
//        - bit(s) {11:7}   - Register Address
//        - bit(s) {6:2}    - PHY Address
//        - bit(s) {1}      - Read (== 0) / Write (== 1)
//        - bit(s) {0}      - Enable
// (1)  MDIO Write Register
//        - bit(s) {15:0}   - Write Data

//====================================================================

// Device Register Descriptions (MDIO - LAN8720A):
// (0)  Basic Control Register                          - Basic
// (1)  Basic Status Register                           - Basic
// (2)  PHY Identifier 1                                - Extended
// (3)  PHY Identifier 2                                - Extended
// (4)  Auto-Negotiation Advertisement Register         - Extended
// (5)  Auto-Negotiation Link Partner Ability Register  - Extended
// (6)  Auto-Negotiation Expansion Register             - Extended
// (17) Mode Control/Status Register                    - Vendor-Specific
// (18) Special Modes                                   - Vendor-Specific
// (26) Symbol Error Counter Register                   - Vendor-Specific
// (27) Control/Status Indication Register              - Vendor-Specific
// (29) Interrupt Source Register                       - Vendor-Specific
// (30) Interrupt Mask Register                         - Vendor-Specific
// (31) PHY Special Control/Status Register             - Vendor-Specific

//====================================================================

module eth_regs (

  input wire AXI_Clk,
  input wire AXI_Rstn,
  input wire MDC_Clk,
  input wire MDC_Rst,

  // AXI write addressing
  input  wire         AXI_Master_awvalid,    // master indicates if the provided address is valid           (s_axi_ctrl_awvalid)
  output reg          AXI_Slave_awready,    // slave indicates if it is ready to accept an address         (s_axi_ctrl_awready)
  input  wire [31:0]  AXI_Master_awaddr,    // write address provided by master                            (s_axi_ctrl_awaddr)

  // AXI write data
  input  wire         AXI_Master_wvalid,    // master indicates if the write data is avaliable             (s_axi_ctrl_wvalid)
  output reg          AXI_Slave_wready,     // slave indicates that it can acccept write data              (s_axi_ctrl_wready)
  input  wire [31:0]  AXI_Master_wdata,     // write data provided to slave                                (s_axi_ctrl_wdata)

  // AXI write response
  output reg          AXI_Slave_bvalid,     // slave indicates it is signaling a valid write response      (s_axi_ctrl_bvalid)
  output reg [1:0]    AXI_Slave_bresp,      // slave's write response to master                            (s_axi_ctrl_bresp)
  input  wire         AXI_Master_bready,    // master indicates that it accepts write response             (s_axi_ctrl_bready)

  // AXI read addressing
  input  wire         AXI_Master_arvalid,   // master indicates if the provided address is valid           (s_axi_ctrl_arvalid)
  output reg          AXI_Slave_arready,    // slave indicates if it is ready to accept an address         (s_axi_ctrl_arready)
  input  wire [31:0]  AXI_Master_araddr,    // read address provided by master                             (s_axi_ctrl_araddr)

  // AXI read data
  input  wire         AXI_Master_rready,    // master indicates that it can accept read data and status    (s_axi_ctrl_rready)
  output reg [31:0]   AXI_Slave_rdata,      // read data provided to master                                (s_axi_ctrl_rdata)
  output reg          AXI_Slave_rvalid,     // slave indicates if the read data is valid                   (s_axi_ctrl_rvalid)
  output reg [1:0]    AXI_Slave_rresp,      // slave indicates status of read transfer                     (s_axi_ctrl_rresp)

  // To MDIO
  output wire [4:0]   MDIO_Phy_Addr_Req,    // phy address
  output wire [4:0]   MDIO_Reg_Addr_Req,    // register address
  output wire         MDIO_Transc_Type_Req, // read or write transaction
  output wire         MDIO_En_Req,          // strobe that kicks-off a transaction
  output wire [15:0]  MDIO_Wr_Dat_Req,      // data for MDIO registers

  // From MDIO
  input  wire [5:0]   MDIO_Reg_Addr_Recv,   // address of register targeted by MDIO DMA
  input  wire         MDIO_Data_Valid_Recv, // indicates when data from MDIO DMA is valid
  input  wire [31:0]  MDIO_Data_Recv        // data from MDIO DMA
);

  // PHY Registers (read-only, match datasheet register map)
  localparam pMDIO_PHY_CTRL_ADDR        = 6'h00;
  localparam pMDIO_PHY_STAT_ADDR        = 6'h01;
  localparam pMDIO_PHY_IDENT_1_ADDR     = 6'h02;
  localparam pMDIO_PHY_IDENT_2_ADDR     = 6'h03;
  localparam pMDIO_PHY_ANA_ADDR         = 6'h04;
  localparam pMDIO_PHY_ANLP_ADDR        = 6'h05;
  localparam pMDIO_PHY_ANE_ADDR         = 6'h06;
  localparam pMDIO_PHY_MODE_ADDR        = 6'h11;
  localparam pMDIO_PHY_SPEC_MD_ADDR     = 6'h12;
  localparam pMDIO_PHY_SYM_ERR_ADDR     = 6'h1A;
  localparam pMDIO_PHY_INDC_ADDR        = 6'h1B;
  localparam pMDIO_PHY_INTR_SRC_ADDR    = 6'h1D;
  localparam pMDIO_PHY_INTR_MSK_ADDR    = 6'h1E;
  localparam pMDIO_PHY_SPEC_CTRL_ADDR   = 6'h1F;

  // USER Registers (read/write)
  localparam pMDIO_USR_CTRL_ADDR        = 6'h20;
  localparam pMDIO_USR_WRITE_ADDR       = 6'h21;

  // rCtrl_Fsm_State
  localparam IDLE   = 4'h0;
  localparam READ   = 4'h1;
  localparam WRITE  = 4'h2;
  localparam ACK    = 4'h3;
  reg [3:0] rCtrl_Fsm_State;

  // control & truncated addresses
  wire [5:0] wWrite_Addr;
  reg  [5:0] rRead_Addr;
  reg        rWrite_Reg;

  // registers
  reg [31:0] rMDIO_PHY_CTRL_REG;
  reg [31:0] rMDIO_PHY_STAT_REG;
  reg [31:0] rMDIO_PHY_IDENT_1_REG;
  reg [31:0] rMDIO_PHY_IDENT_2_REG;
  reg [31:0] rMDIO_PHY_ANA_REG;
  reg [31:0] rMDIO_PHY_ANLP_REG;
  reg [31:0] rMDIO_PHY_ANE_REG;
  reg [31:0] rMDIO_PHY_MODE_REG;
  reg [31:0] rMDIO_PHY_SPEC_MD_REG;
  reg [31:0] rMDIO_PHY_SYM_ERR_REG;
  reg [31:0] rMDIO_PHY_INDC_REG;
  reg [31:0] rMDIO_PHY_INTR_SRC_REG;
  reg [31:0] rMDIO_PHY_INTR_MSK_REG;
  reg [31:0] rMDIO_PHY_SPEC_CTRL_REG;
  
  reg [31:0] rMDIO_USR_CTRL_REG;
  reg [31:0] rMDIO_USR_WRITE_REG;

// Custom Register Descriptions (eth_mdio)
// (0)  MDIO Control Register
//        - bit(s) {11:7}   - Register Address
//        - bit(s) {6:2}    - PHY Address
//        - bit(s) {1}      - Read (== 0) / Write (== 1)
//        - bit(s) {0}      - Enable
// (1)  MDIO Write Register
//        - bit(s) {15:0}   - Write Data

//====================================================================

  //==========================================
  // mdio_assignements
  //==========================================
  assign MDIO_Reg_Addr_Req      = rMDIO_USR_CTRL_REG[11:7];
  assign MDIO_Phy_Addr_Req      = rMDIO_USR_CTRL_REG[6:2];
  assign MDIO_Transc_Type_Req   = rMDIO_USR_CTRL_REG[1];
  assign MDIO_En_Req            = rMDIO_USR_CTRL_REG[0];
  assign MDIO_Wr_Dat_Req        = rMDIO_USR_WRITE_REG[15:0];

  //==========================================
  // address_truncation
  //==========================================

  // zynq can only obtain 1 byte per address
  // thus, we need 4 bytes * (8 bits/byte) to obtain 32 bits
  // so, we will use bits ... 3 & 2 to access our different registers

  // example:
  // if we do Xil_In32(0x40000000) --> [3:2] == "00"
  // if we do Xil_In32(0x40000004) --> [3:2] == "01"
  // ... more bits --> more addresses

  assign wWrite_Addr = AXI_Master_awaddr[7:2];

  //==========================================
  // read_mux
  //==========================================
  // provides data for AXI reads

  always @(*)
  begin
  case(rRead_Addr)
    pMDIO_PHY_CTRL_ADDR      : AXI_Slave_rdata = rMDIO_PHY_CTRL_REG;
    pMDIO_PHY_STAT_ADDR      : AXI_Slave_rdata = rMDIO_PHY_STAT_REG;
    pMDIO_PHY_IDENT_1_ADDR   : AXI_Slave_rdata = rMDIO_PHY_IDENT_1_REG;
    pMDIO_PHY_IDENT_2_ADDR   : AXI_Slave_rdata = rMDIO_PHY_IDENT_2_REG;
    pMDIO_PHY_ANA_ADDR       : AXI_Slave_rdata = rMDIO_PHY_ANA_REG;
    pMDIO_PHY_ANLP_ADDR      : AXI_Slave_rdata = rMDIO_PHY_ANLP_REG;
    pMDIO_PHY_ANE_ADDR       : AXI_Slave_rdata = rMDIO_PHY_ANE_REG;
    pMDIO_PHY_MODE_ADDR      : AXI_Slave_rdata = rMDIO_PHY_MODE_REG;
    pMDIO_PHY_SPEC_MD_ADDR   : AXI_Slave_rdata = rMDIO_PHY_SPEC_MD_REG;
    pMDIO_PHY_SYM_ERR_ADDR   : AXI_Slave_rdata = rMDIO_PHY_SYM_ERR_REG;
    pMDIO_PHY_INDC_ADDR      : AXI_Slave_rdata = rMDIO_PHY_INDC_REG;
    pMDIO_PHY_INTR_SRC_ADDR  : AXI_Slave_rdata = rMDIO_PHY_INTR_SRC_REG;
    pMDIO_PHY_INTR_MSK_ADDR  : AXI_Slave_rdata = rMDIO_PHY_INTR_MSK_REG;
    pMDIO_PHY_SPEC_CTRL_ADDR : AXI_Slave_rdata = rMDIO_PHY_SPEC_CTRL_REG;
    pMDIO_USR_CTRL_ADDR      : AXI_Slave_rdata = rMDIO_USR_CTRL_REG;
    pMDIO_USR_WRITE_ADDR     : AXI_Slave_rdata = rMDIO_USR_WRITE_REG;
    default                  : AXI_Slave_rdata = 32'h00000000;
  endcase
  end

  //==========================================
  // ctrl_fsm
  //==========================================
  // handles AXI Transactions

  // MIGHT BE ABLE TO SIMPLIFY THIS AFTER TESTING WITH THE
  // NEW TB STIMULUS!!!!!

  always @(posedge(AXI_Clk))
  begin
  if (~AXI_Rstn) begin
    rCtrl_Fsm_State <= IDLE;
    rWrite_Reg      <= 0;
    rRead_Addr      <= 0;
  end
  else begin
    case(rCtrl_Fsm_State)
      IDLE:
      begin

        // default: slave is not ready to read/write
        AXI_Slave_arready     <= 0;
        AXI_Slave_awready     <= 0;
        AXI_Slave_wready      <= 0;
        
        // write slave
        if (AXI_Master_awvalid && AXI_Master_wvalid) begin
          AXI_Slave_awready   <= 1;
          AXI_Slave_wready    <= 1;
          rWrite_Reg          <= 1;
          rCtrl_Fsm_State     <= WRITE;
        end

        // read slave
        else if (AXI_Master_arvalid) begin
          rRead_Addr          <= AXI_Master_araddr[7:2];
          AXI_Slave_arready   <= 1;
          rCtrl_Fsm_State     <= READ;
        end
      end

      READ:
      begin
        AXI_Slave_arready     <= 0;
        AXI_Slave_rvalid      <= 1;
        rCtrl_Fsm_State       <= ACK;
      end

      WRITE:
      begin
        AXI_Slave_bvalid     <= 1;
        AXI_Slave_bresp      <= 2'b00;
        AXI_Slave_awready    <= 0;
        AXI_Slave_wready     <= 0;
        rWrite_Reg           <= 0;
        rCtrl_Fsm_State      <= ACK;
      end

      ACK:
      begin

        // master acknowledges write response
        if (AXI_Master_bready) begin
          AXI_Slave_bvalid   <= 0;
          rCtrl_Fsm_State    <= IDLE;
        end

        // master acknowleges read response
        if (AXI_Master_rready) begin
          AXI_Slave_rvalid    <= 0;
          rCtrl_Fsm_State     <= IDLE;
        end;
      end

      default:
      begin
        rCtrl_Fsm_State <= IDLE;
      end
    endcase
  end
  end

  //======================================================================================
  // Registers Configured by PS
  //======================================================================================

  //==========================================
  // MDIO_USR_CTRL_REG
  //==========================================
  // control data for interacting with MDIO
  // can be configured for read/write operations

  always @(posedge(AXI_Clk))
  begin
  if (~AXI_Rstn)
    rMDIO_USR_CTRL_REG <= 32'h00000000;
  else begin
    if (wWrite_Addr == pMDIO_USR_CTRL_ADDR && rWrite_Reg) begin
      rMDIO_USR_CTRL_REG <= AXI_Master_wdata;
    end
  end
  end

  //==========================================
  // MDIO_USR_WRITE_REG
  //==========================================
  // data to write to specific MDIO registers

  always @(posedge(AXI_Clk))
  begin
  if (~AXI_Rstn)
    rMDIO_USR_WRITE_REG <= 32'h00000000;
  else begin
    if (wWrite_Addr == pMDIO_USR_WRITE_ADDR && rWrite_Reg) begin
      rMDIO_USR_WRITE_REG <= AXI_Master_wdata;
    end
  end
  end

  //======================================================================================
  // Registers Configured by MDIO DMA
  //======================================================================================

  //==========================================
  // MDIO_PHY_CTRL_REG
  //==========================================
  always @(posedge(MDC_Clk))
  begin
  if (MDC_Rst)
    rMDIO_PHY_CTRL_REG <= 32'h00000000;
  else begin
    if (MDIO_Reg_Addr_Recv == pMDIO_PHY_CTRL_ADDR && MDIO_Data_Valid_Recv) begin
      rMDIO_PHY_CTRL_REG <= MDIO_Data_Recv;
    end
  end
  end

  //==========================================
  // MDIO_PHY_STAT_REG
  //==========================================
  always @(posedge(MDC_Clk))
  begin
  if (MDC_Rst)
    rMDIO_PHY_STAT_REG <= 32'h00000000;
  else begin
    if (MDIO_Reg_Addr_Recv == pMDIO_PHY_STAT_ADDR && MDIO_Data_Valid_Recv) begin
      rMDIO_PHY_STAT_REG <= MDIO_Data_Recv;
    end
  end
  end

  //==========================================
  // MDIO_PHY_IDENT_1_REG
  //==========================================
  always @(posedge(MDC_Clk))
  begin
  if (MDC_Rst)
    rMDIO_PHY_IDENT_1_REG <= 32'h00000000;
  else begin
    if (MDIO_Reg_Addr_Recv == pMDIO_PHY_IDENT_1_ADDR && MDIO_Data_Valid_Recv) begin
      rMDIO_PHY_IDENT_1_REG <= MDIO_Data_Recv;
    end
  end
  end

  //==========================================
  // MDIO_PHY_IDENT_2_REG
  //==========================================
  always @(posedge(MDC_Clk))
  begin
  if (MDC_Rst)
    rMDIO_PHY_IDENT_2_REG <= 32'h00000000;
  else begin
    if (MDIO_Reg_Addr_Recv == pMDIO_PHY_IDENT_1_ADDR && MDIO_Data_Valid_Recv) begin
      rMDIO_PHY_IDENT_2_REG <= MDIO_Data_Recv;
    end
  end
  end

  //==========================================
  // MDIO_PHY_ANA_REG
  //==========================================
  always @(posedge(MDC_Clk))
  begin
  if (MDC_Rst)
    rMDIO_PHY_ANA_REG <= 32'h00000000;
  else begin
    if (MDIO_Reg_Addr_Recv == pMDIO_PHY_IDENT_1_ADDR && MDIO_Data_Valid_Recv) begin
      rMDIO_PHY_ANA_REG <= MDIO_Data_Recv;
    end
  end
  end

  //==========================================
  // MDIO_PHY_ANLP_REG
  //==========================================
  always @(posedge(MDC_Clk))
  begin
  if (MDC_Rst)
    rMDIO_PHY_ANLP_REG <= 32'h00000000;
  else begin
    if (MDIO_Reg_Addr_Recv == pMDIO_PHY_IDENT_1_ADDR && MDIO_Data_Valid_Recv) begin
      rMDIO_PHY_ANLP_REG<= MDIO_Data_Recv;
    end
  end
  end

  //==========================================
  // MDIO_PHY_ANE_REG
  //==========================================
  always @(posedge(MDC_Clk))
  begin
  if (MDC_Rst)
    rMDIO_PHY_ANE_REG <= 32'h00000000;
  else begin
    if (MDIO_Reg_Addr_Recv == pMDIO_PHY_IDENT_1_ADDR && MDIO_Data_Valid_Recv) begin
      rMDIO_PHY_ANE_REG <= MDIO_Data_Recv;
    end
  end
  end

  //==========================================
  // MDIO_PHY_MODE_REG
  //==========================================
  always @(posedge(MDC_Clk))
  begin
  if (MDC_Rst)
    rMDIO_PHY_MODE_REG <= 32'h00000000;
  else begin
    if (MDIO_Reg_Addr_Recv == pMDIO_PHY_IDENT_1_ADDR && MDIO_Data_Valid_Recv) begin
      rMDIO_PHY_MODE_REG <= MDIO_Data_Recv;
    end
  end
  end

  //==========================================
  // MDIO_PHY_SPEC_MD_REG
  //==========================================
  always @(posedge(MDC_Clk))
  begin
  if (MDC_Rst)
    rMDIO_PHY_SPEC_MD_REG <= 32'h00000000;
  else begin
    if (MDIO_Reg_Addr_Recv == pMDIO_PHY_IDENT_1_ADDR && MDIO_Data_Valid_Recv) begin
      rMDIO_PHY_SPEC_MD_REG <= MDIO_Data_Recv;
    end
  end
  end

  //==========================================
  // MDIO_PHY_SYM_ERR_REG
  //==========================================
  always @(posedge(MDC_Clk))
  begin
  if (MDC_Rst)
    rMDIO_PHY_SYM_ERR_REG <= 32'h00000000;
  else begin
    if (MDIO_Reg_Addr_Recv == pMDIO_PHY_IDENT_1_ADDR && MDIO_Data_Valid_Recv) begin
      rMDIO_PHY_SYM_ERR_REG <= MDIO_Data_Recv;
    end
  end
  end

  //==========================================
  // MDIO_PHY_INDC_REG
  //==========================================
  always @(posedge(MDC_Clk))
  begin
  if (MDC_Rst)
    rMDIO_PHY_INDC_REG <= 32'h00000000;
  else begin
    if (MDIO_Reg_Addr_Recv == pMDIO_PHY_IDENT_1_ADDR && MDIO_Data_Valid_Recv) begin
      rMDIO_PHY_INDC_REG <= MDIO_Data_Recv;
    end
  end
  end

  //==========================================
  // MDIO_PHY_INTR_SRC_REG
  //==========================================
  always @(posedge(MDC_Clk))
  begin
  if (MDC_Rst)
    rMDIO_PHY_INTR_SRC_REG <= 32'h00000000;
  else begin
    if (MDIO_Reg_Addr_Recv == pMDIO_PHY_IDENT_1_ADDR && MDIO_Data_Valid_Recv) begin
      rMDIO_PHY_INTR_SRC_REG <= MDIO_Data_Recv;
    end
  end
  end

  //==========================================
  // MDIO_PHY_INTR_MSK_REG
  //==========================================
  always @(posedge(MDC_Clk))
  begin
  if (MDC_Rst)
    rMDIO_PHY_INTR_MSK_REG <= 32'h00000000;
  else begin
    if (MDIO_Reg_Addr_Recv == pMDIO_PHY_IDENT_1_ADDR && MDIO_Data_Valid_Recv) begin
      rMDIO_PHY_INTR_MSK_REG <= MDIO_Data_Recv;
    end
  end
  end

  //==========================================
  // MDIO_PHY_SPEC_CTRL_REG
  //==========================================
  always @(posedge(MDC_Clk))
  begin
  if (MDC_Rst)
    rMDIO_PHY_SPEC_CTRL_REG <= 32'h00000000;
  else begin
    if (MDIO_Reg_Addr_Recv == pMDIO_PHY_IDENT_1_ADDR && MDIO_Data_Valid_Recv) begin
      rMDIO_PHY_SPEC_CTRL_REG  <= MDIO_Data_Recv;
    end
  end
  end

endmodule
