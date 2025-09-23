//--------------------------------------------------------------------
// simpleEthernet
// eth_tx_pkg.sv
// Ethernet RMII transmit module constants
// 12/23/24
//--------------------------------------------------------------------

package eth_tx_pkg;

  localparam pMII_WIDTH      = 2;  // # parallel data lines to PHY
  localparam pBYTES_TO_BITS  = 3;  // shift to convert bytes to bits

  // byte counts
  localparam pMIN_PKT_BYTES  = 60; // not including CRC
  localparam pPREAMBLE_BYTES = 7;
  localparam pSFD_BYTES      = 1;
  localparam pMAC_ADDR_BYTES = 6;
  localparam pLEN_TYPE_BYTES = 2;
  localparam pFCS_BYTES      = 4;
  localparam pIPG_BYTES      = 12;

  // bit counts
  localparam pPREAMBLE_BITS  = (pPREAMBLE_BYTES << pBYTES_TO_BITS);
  localparam pSFD_BITS       = (pSFD_BYTES      << pBYTES_TO_BITS);
  localparam pMAC_ADDR_BITS  = (pMAC_ADDR_BYTES << pBYTES_TO_BITS);
  localparam pLEN_TYPE_BITS  = (pLEN_TYPE_BYTES << pBYTES_TO_BITS);
  localparam pFCS_BITS       = (pFCS_BYTES      << pBYTES_TO_BITS);
  localparam pIPG_BITS       = (pIPG_BYTES      << pBYTES_TO_BITS);

  // serial counts (# iterations to process data given some MII width)
  localparam pPREAMBLE_CNT   = (pPREAMBLE_BITS  >> (pMII_WIDTH >> 1));
  localparam pSFD_CNT        = (pSFD_BITS       >> (pMII_WIDTH >> 1));
  localparam pMAC_ADDR_CNT   = (pMAC_ADDR_BITS  >> (pMII_WIDTH >> 1));
  localparam pLen_TYPE_CNT   = (pLEN_TYPE_BITS  >> (pMII_WIDTH >> 1));
  localparam pFCS_CNT        = (pFCS_BITS       >> (pMII_WIDTH >> 1));
  localparam pIPG_CNT        = (pIPG_BITS       >> (pMII_WIDTH >> 1));

  // eth_rx_ctrl_fsm
  typedef enum logic [3:0] {
    IDLE      = 4'h0,
    PREAMBLE  = 4'h1,
    SFD       = 4'h2,
    DEST_ADDR = 4'h3,
    SRC_ADDR  = 4'h4,
    LEN_TYPE  = 4'h5,
    DATA      = 4'h6,
    PAD       = 4'h7,
    FCS       = 4'h8,
    IPG       = 4'h9
  } eth_tx_ctrl_state_t;

endpackage: eth_tx_pkg
