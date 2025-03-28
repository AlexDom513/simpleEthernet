//--------------------------------------------------------------------
// simpleEthernet
// eth_tx_tpg.sv
// Generates incrementing bytes to test ethernet tx
// 2/14/25
//--------------------------------------------------------------------

module eth_tx_tpg (
  input  logic       Clk,
  input  logic       Rst,
  input  logic       Eth_Tx_Test_En,
  output logic [7:0] Eth_Byte_Test,
  output logic       Eth_Byte_Valid_Test
);

  //------------------------------------------
  // Constants
  //------------------------------------------
  localparam MAX_CNT = 100;

  //------------------------------------------
  // Logic
  //------------------------------------------
  logic rEth_Tx_Test_En_meta;
  logic rEth_Tx_Test_En;
  logic rEth_Tx_Test_En_d1;

  // synchronize Eth_Tx_Test_En, obtain rEth_Tx_Test_En(_d1)
  always_ff @(posedge Clk)
  begin
    if (Rst) begin
      rEth_Tx_Test_En_meta <= 0;
      rEth_Tx_Test_En <= 0;
      rEth_Tx_Test_En_d1 <= 0;
    end
    else begin
      rEth_Tx_Test_En_meta <= Eth_Tx_Test_En;
      rEth_Tx_Test_En <= rEth_Tx_Test_En_meta;
      rEth_Tx_Test_En_d1 <= rEth_Tx_Test_En;
    end
  end

  // implement count pattern
  always_ff @(posedge Clk)
  begin
    if (Rst) begin
      Eth_Byte_Valid_Test <= 0;
      Eth_Byte_Test <= 0;
    end
    else begin

      // enable tpg on rising-edge of Eth_Tx_Test_En
      if (rEth_Tx_Test_En && ~rEth_Tx_Test_En_d1) begin
        Eth_Byte_Valid_Test <= 1;
        Eth_Byte_Test <= Eth_Byte_Test + 1;
      end
      else if (Eth_Byte_Test > 0 & Eth_Byte_Test < MAX_CNT) begin
        Eth_Byte_Valid_Test <= 1;
        Eth_Byte_Test <= Eth_Byte_Test + 1;
      end
      else if (Eth_Byte_Test == MAX_CNT) begin
        Eth_Byte_Valid_Test <= 0;
        Eth_Byte_Test <= 0;
      end
      else begin
        Eth_Byte_Valid_Test <= 0;
        Eth_Byte_Test <= 0;
      end

    end
  end

endmodule
