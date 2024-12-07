//====================================================================
// 02_simple_ethernet
// clk_rst_mgr.v
// Obtain 1 MHz MDC clock
// 8/17/24
//====================================================================

module clk_rst_mgr(
  input  wire  Clk,
  input  wire  Rstn,
  output wire  Clk_MDC,
  output wire  Rst_MDC
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
  reg         rClk_MDC = 1;
  wire        wClk_MDC;

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
        rClk_MDC <= ~rClk_MDC;
    end

  assign wClk_MDC = rClk_MDC;
  assign Clk_MDC  = wClk_MDC;

  //==========================================
  // Reset Management
  //==========================================
  reg rRst_MDC;

  always @(posedge wClk_MDC)
  begin
    if (~Rstn) begin
      rRst_MDC <= 1;
    end
    else begin
      rRst_MDC <= 0;
    end
  end
  assign Rst_MDC = rRst_MDC;

endmodule
