//====================================================================
// 02_simple_ethernet
// clk_rst_mgr.v
// Obtain 1 MHz MDC clock
// 8/17/24
//====================================================================

module clk_rst_mgr (
  input  wire  Clk,
  input  wire  Rstn,
  output wire  MDC_Clk,
  output wire  MDC_Rst
);

  // NOTE: 
  //    - not ideal to use a generated clock, but PLL cannot support 1 MHz
  //    - additionally, cannot solely rely on clock enbable because
  //      MDC needs to be passed to PHY that is external to FPGA

  //==========================================
  // Clock Management
  //==========================================
  localparam  CLK_DIV_CNT = 50;
  reg   [6:0] rClk_Cnt;
  reg         rMDC_Clk = 1;
  wire        wMDC_Clk;

  always @(posedge Clk)
  begin
    if (~Rstn)
      rClk_Cnt <= 0;
    else begin
      rClk_Cnt <= rClk_Cnt + 1;
      if (rClk_Cnt == CLK_DIV_CNT-1)
        rClk_Cnt <= 0;
    end
  end

  always @(posedge Clk)
    begin
      if (rClk_Cnt == CLK_DIV_CNT-1)
        rMDC_Clk <= ~rMDC_Clk;
    end

  assign wMDC_Clk = rMDC_Clk;
  assign MDC_Clk  = wMDC_Clk;

  //==========================================
  // Reset Management
  //==========================================
  reg rMDC_Rst;

  always @(posedge wMDC_Clk)
  begin
    if (~Rstn) begin
      rMDC_Rst <= 1;
    end
    else begin
      rMDC_Rst <= 0;
    end
  end
  assign MDC_Rst = rMDC_Rst;

endmodule
