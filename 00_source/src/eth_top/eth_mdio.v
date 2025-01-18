//====================================================================
// simpleEthernet
// eth_mdio.v
// MDIO Interface to Ethernet PHY
// 8/2/24
//====================================================================

// **IMPORTANT NOTES**: 
// - The minimum time between edges of the MDC is 160 ns
// - The minimum cycle time (time between two consecutive
//      rising or two consecutive falling edges) is 400 ns.
// - MDIO is a bi-directional data SMI input/output signal that receives serial data
//      (commands) from the controller SMC and sends serial data (status) to the SMC

module eth_mdio #(parameter SIM_MODE = 0) (
  input  wire         Clk,
  input  wire         Rst,
  inout  wire         MDIO,

  // from eth_regs
  input wire [4:0]    MDIO_Phy_Addr_Recv,
  input wire [4:0]    MDIO_Reg_Addr_Recv,
  input wire          MDIO_Transc_Type_Recv,
  input wire          MDIO_En_Recv,
  input wire [15:0]   MDIO_Wr_Dat_Recv,

  // to eth_regs
  output wire [5:0]   MDIO_Reg_Addr,
  output wire         MDIO_Data_Valid, 
  output wire [31:0]  MDIO_Data,
  output reg          MDIO_Busy
);

  // constants
  localparam pPreamble_Len = 5'h1F;
  localparam pAddr_Len     = 5'h04;
  localparam pWait_Len     = 5'h01;
  localparam pData_Len     = 5'h0F;
  localparam pAddr_Top_Bit = 4;
  localparam pDat_Top_Bit  = 15;

  // rCtrl_Fsm_State
  localparam IDLE         = 4'h0;
  localparam PREAMBLE     = 4'h1;
  localparam SOF          = 4'h2;
  localparam OP_CODE_RD   = 4'h3;
  localparam OP_CODE_WR   = 4'h4;
  localparam PHY_ADDR     = 4'h5;
  localparam REG_ADDR     = 4'h6;
  localparam WAIT         = 4'h7;
  localparam DAT_READ     = 4'h8;
  localparam DAT_WRITE    = 4'h9;
  localparam ACK          = 4'hA;

  // Control
  reg [3:0]   rCtrl_Fsm_State;
  reg [4:0]   rFsm_State_Cnt;
  reg         rMDIO_En_Recv_meta;
  reg         rMDIO_En_Recv;
  reg         rMDIO_En_Recv_d1;
  reg         rMDIO_Start;

  // MDIO Transaction Parameters
  reg [4:0]   rPhy_Addr;
  reg [4:0]   rReg_Addr;
  reg [4:0]   rReg_Addr_hold;
  reg         rTransc_Type;
  reg [15:0]  rWr_Dat;

  // Serial MDIO Data Handling
  reg         rMDIO_Output_En;
  reg         rMDIO_Wr;
  wire        wMDIO_Rd;
  wire        wMDIO_In_TB;

  // Read Data Capture
  wire [15:0] wMDIO_Rd_Dat;
  reg  [15:0] rMDIO_Rd_Dat;
  reg         rMDIO_Data_Valid;

  //==========================================
  // mdio_assignments
  //==========================================

  // Serial MDIO Data Handling
  assign MDIO = (rMDIO_Output_En) ? rMDIO_Wr : 1'bz;
  generate
    if (SIM_MODE) begin : sim_gen
      assign wMDIO_Rd = wMDIO_In_TB;
    end
    else begin : synth_gen
      assign wMDIO_Rd = MDIO;
    end
  endgenerate

  // Read Data Capture
  assign wMDIO_Rd_Dat     = {rMDIO_Rd_Dat[15:1], wMDIO_Rd};
  assign MDIO_Data_Valid  = rMDIO_Data_Valid;
  assign MDIO_Reg_Addr    = {1'b0, rReg_Addr_hold};
  assign MDIO_Data        = {16'h0000, rMDIO_Rd_Dat};

  //==========================================
  // mdio_start
  //==========================================

  // **eth_regs is operating in clock domain different from Clk in MDIO module
  // synchronize start signal into domain used in eth_mdio
  // add pulse stretch??
  always @(posedge Clk)
  begin
    if (Rst) begin
      rMDIO_En_Recv_meta <= 0;
      rMDIO_En_Recv <= 0;
      rMDIO_En_Recv_d1 <= 0;
    end
    else begin
      rMDIO_En_Recv_meta <= MDIO_En_Recv;
      rMDIO_En_Recv <= rMDIO_En_Recv_meta;
      rMDIO_En_Recv_d1 <= rMDIO_En_Recv;
    end
  end
  
  // starting a MDIO transfer requires a rising-edge of rMDIO_En_Recv
  always @(posedge Clk)
  begin
    if (Rst) begin
      MDIO_Busy <= 0;
      rMDIO_Start <= 0;
    end
    else begin
      if (rMDIO_En_Recv && ~rMDIO_En_Recv_d1) begin
        MDIO_Busy <= 1;
        rMDIO_Start <= 1;
      end
      else if (rCtrl_Fsm_State == ACK)
        MDIO_Busy <= 0;
      else
        rMDIO_Start <= 0;
    end
  end

  //==========================================
  // ctrl_fsm
  //==========================================
  always @(posedge Clk)
  begin
    if (Rst) begin
      rMDIO_Output_En <= 0;
      rMDIO_Wr        <= 0;
      rFsm_State_Cnt  <= 0;
      rCtrl_Fsm_State <= IDLE;
    end
    else begin
      case(rCtrl_Fsm_State)

      //==========================================
      // IDLE (0)
      //==========================================
        IDLE:
        begin
          rMDIO_Output_En     <= 0;
          rMDIO_Wr            <= 0;
          rFsm_State_Cnt      <= 0;
          rMDIO_Data_Valid    <= 0;

          if (rMDIO_Start) begin
            rPhy_Addr         <= MDIO_Phy_Addr_Recv;
            rReg_Addr         <= MDIO_Reg_Addr_Recv;
            rReg_Addr_hold    <= MDIO_Reg_Addr_Recv;
            rTransc_Type      <= MDIO_Transc_Type_Recv;
            rWr_Dat           <= MDIO_Wr_Dat_Recv;
            rMDIO_Output_En   <= 1;
            rMDIO_Wr          <= 1;
            rCtrl_Fsm_State   <= PREAMBLE;
          end
        end

      //==========================================
      // PREAMBLE (1)
      //==========================================
        PREAMBLE:
        begin
          rFsm_State_Cnt  <= rFsm_State_Cnt + 1;
          if (rFsm_State_Cnt == pPreamble_Len) begin
            rFsm_State_Cnt    <= 0;
            rMDIO_Wr          <= 0;
            rCtrl_Fsm_State   <= SOF;
          end
        end

      //==========================================
      // SOF (2)
      //==========================================
        SOF:
        begin
          rMDIO_Wr <= 1;
          if (rMDIO_Wr) begin
            if (rTransc_Type == 0)
              rCtrl_Fsm_State <= OP_CODE_RD;
            else if (rTransc_Type == 1) begin
              rMDIO_Wr        <= 0;
              rCtrl_Fsm_State <= OP_CODE_WR;
            end
          end
        end
        
      //==========================================
      // OP_CODE_RD (3)
      //==========================================
        OP_CODE_RD:
        begin
          rMDIO_Wr <= 0;
          if (~rMDIO_Wr) begin
            rMDIO_Wr          <= rPhy_Addr[pAddr_Top_Bit];
            rPhy_Addr         <= rPhy_Addr << 1;
            rCtrl_Fsm_State   <= PHY_ADDR;
          end
        end
        
      //==========================================
      // OP_CODE_WR (4)
      //==========================================
        OP_CODE_WR:
        begin
          rMDIO_Wr <= 1;
          if (rMDIO_Wr) begin
            rMDIO_Wr          <= rPhy_Addr[pAddr_Top_Bit];
            rPhy_Addr         <= rPhy_Addr << 1;
            rCtrl_Fsm_State   <= PHY_ADDR;
          end
        end
        
      //==========================================
      // PHY_ADDR (5)
      //==========================================
      // shift out phy address bits

        PHY_ADDR:
        begin
          rFsm_State_Cnt      <= rFsm_State_Cnt + 1;
          rMDIO_Wr            <= rPhy_Addr[pAddr_Top_Bit];
          rPhy_Addr           <= rPhy_Addr << 1;
          if (rFsm_State_Cnt == pAddr_Len) begin
            rFsm_State_Cnt    <= 0;
            rMDIO_Wr          <= rReg_Addr[pAddr_Top_Bit];
            rReg_Addr         <= rReg_Addr << 1;
            rCtrl_Fsm_State   <= REG_ADDR;
          end
        end
        
      //==========================================
      // REG_ADDR (6)
      //==========================================
      // shift out reg address bits

        REG_ADDR:
        begin
          rFsm_State_Cnt      <= rFsm_State_Cnt + 1;
          rMDIO_Wr            <= rReg_Addr[pAddr_Top_Bit];
          rReg_Addr           <= rReg_Addr << 1;
          if (rFsm_State_Cnt == pAddr_Len) begin
            rFsm_State_Cnt    <= 0;
            rCtrl_Fsm_State   <= WAIT;
          end
        end
        
      //==========================================
      // WAIT (7)
      //==========================================
        WAIT:
        begin
          rFsm_State_Cnt        <= rFsm_State_Cnt + 1;
          if (rFsm_State_Cnt == pWait_Len) begin
            if (MDIO_Transc_Type_Recv == 0) begin
              rMDIO_Output_En   <= 0;
              rCtrl_Fsm_State   <= DAT_READ;
            end
            else if (MDIO_Transc_Type_Recv == 1) begin
              rMDIO_Wr          <= rWr_Dat[pDat_Top_Bit];
              rWr_Dat           <= rWr_Dat << 1;
              rCtrl_Fsm_State   <= DAT_WRITE;
            end
            rFsm_State_Cnt      <= 0;
          end
        end
        
      //==========================================
      // DAT_READ (8)
      //==========================================
        DAT_READ:
        begin
          rFsm_State_Cnt      <= rFsm_State_Cnt + 1;
          rMDIO_Rd_Dat        <= wMDIO_Rd_Dat << 1;
          if (rFsm_State_Cnt == pData_Len) begin
            rMDIO_Rd_Dat      <= wMDIO_Rd_Dat;
            rMDIO_Data_Valid  <= 1;
            rFsm_State_Cnt    <= 0;
            rCtrl_Fsm_State   <= ACK;
          end
        end

      //==========================================
      // DAT_WRITE (9)
      //==========================================
        DAT_WRITE:
        begin
          rFsm_State_Cnt      <= rFsm_State_Cnt + 1;
          rMDIO_Wr            <= rWr_Dat[pDat_Top_Bit];
          rWr_Dat             <= rWr_Dat << 1;
          if (rFsm_State_Cnt == pData_Len) begin
            rMDIO_Output_En   <= 0;
            rFsm_State_Cnt    <= 0;
            rCtrl_Fsm_State   <= ACK;
          end
        end

      //==========================================
      // ACK (10)
      //==========================================
        ACK:
        begin
          rMDIO_Data_Valid    <= 0;
          rCtrl_Fsm_State     <= IDLE;
        end

      //==========================================
      // Default
      //==========================================
        default:
        begin
          rCtrl_Fsm_State <= IDLE;
        end
        
      endcase
    end
  end

endmodule
