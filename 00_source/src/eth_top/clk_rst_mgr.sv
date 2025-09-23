//--------------------------------------------------------------------
// simpleEthernet
// clk_rst_mgr.sv
// Obtain 1 MHz MDC clock
// 8/17/24
//--------------------------------------------------------------------

module clk_rst_mgr (
  input  logic AXI_Clk,
  input  logic AXI_Rstn,
  output logic MDC_Clk,
  output logic MDC_Rst
);

  // NOTE: 
  //    - not ideal to use a generated clock, but PLL cannot support 1 MHz
  //    - additionally, cannot solely rely on clock enbable because
  //      MDC needs to be passed to PHY that is external to FPGA

  //------------------------------------------
  // Clock Management
  //------------------------------------------
  localparam  CLK_DIV_CNT = 50;
  logic [6:0] rClk_Cnt;
  logic       rMDC_Clk = 1;
  logic       wMDC_Clk;

  always_ff @(posedge AXI_Clk)
  begin
    if (~AXI_Rstn)
      rClk_Cnt <= 0;
    else begin
      rClk_Cnt <= rClk_Cnt + 1;
      if (rClk_Cnt == CLK_DIV_CNT-1)
        rClk_Cnt <= 0;
    end
  end

  always_ff @(posedge AXI_Clk)
  begin
    if (rClk_Cnt == CLK_DIV_CNT-1)
      rMDC_Clk <= ~rMDC_Clk;
  end

  assign wMDC_Clk = rMDC_Clk;
  assign MDC_Clk  = wMDC_Clk;

  //------------------------------------------
  // Reset Management
  //------------------------------------------
  logic rMDC_Rst_meta;
  logic rMDC_Rst;

  // MDC_Rst
  always_ff @(posedge wMDC_Clk)
  begin
    rMDC_Rst_meta <= ~AXI_Rstn;
    rMDC_Rst <= rMDC_Rst_meta;
  end 
  assign MDC_Rst = rMDC_Rst;

endmodule
