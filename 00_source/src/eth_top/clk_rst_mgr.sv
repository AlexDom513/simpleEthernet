//--------------------------------------------------------------------
// simpleEthernet
// clk_rst_mgr.sv
// Obtain 1 MHz MDC clock
// 8/17/24
//--------------------------------------------------------------------

module clk_rst_mgr (
  input  logic Clk,
  input  logic Rstn,
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

  always_ff @(posedge Clk)
  begin
    if (~Rstn)
      rClk_Cnt <= 0;
    else begin
      rClk_Cnt <= rClk_Cnt + 1;
      if (rClk_Cnt == CLK_DIV_CNT-1)
        rClk_Cnt <= 0;
    end
  end

  always_ff @(posedge Clk)
  begin
    if (rClk_Cnt == CLK_DIV_CNT-1)
      rMDC_Clk <= ~rMDC_Clk;
  end

  assign wMDC_Clk = rMDC_Clk;
  assign MDC_Clk  = wMDC_Clk;

  //------------------------------------------
  // Reset Management
  //------------------------------------------
  reg rMDC_Rst;

  always_ff @(posedge wMDC_Clk)
  begin
  if (~Rstn)
    rMDC_Rst <= 1;
  else
      rMDC_Rst <= 0;
    end
  assign MDC_Rst = rMDC_Rst;

endmodule
