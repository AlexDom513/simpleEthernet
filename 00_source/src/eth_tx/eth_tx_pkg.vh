//====================================================================
// 02_simple_ethernet
// eth_tx_pkg.vh
// Ethernet RMII transmit module constants
// 12/23/24
//====================================================================

// number of parallel data lines to PHY
localparam pMII_WIDTH = 2;

// shift to convert bytes to bits
localparam pBytes_To_Bits = 3;

// eth_tx_ctrl_fsm
localparam  IDLE            = 4'h0;
localparam  PREAMBLE        = 4'h1;
localparam  SFD             = 4'h2;
localparam  DEST_ADDR       = 4'h3;
localparam  SRC_ADDR        = 4'h4;
localparam  LEN_TYPE        = 4'h5;
localparam  DATA            = 4'h6;
localparam  PAD             = 4'h7;
localparam  FCS             = 4'h8;

// byte counts
localparam pPreamble_Bytes  = 10'h7;
localparam pSFD_Bytes       = 10'h1;
localparam pMAC_Addr_Bytes  = 10'h6;
localparam pLen_Type_Bytes  = 10'h2;
localparam pPayload_Bytes   = 10'h48; // 72 bytes left for payload after all headers
localparam pFCS_Bytes       = 10'h4;

// bit counts
localparam pPreamble_Bits   = pPreamble_Bytes << pBytes_To_Bits;
localparam pSFD_Bits        = pSFD_Bytes << pBytes_To_Bits;
localparam pMAC_Addr_Bits   = pMAC_Addr_Bytes << pBytes_To_Bits;
localparam pLen_Type_Bits   = pLen_Type_Bytes << pBytes_To_Bits;
localparam pFCS_Bits        = pFCS_Bytes << pBytes_To_Bits;

// serial counts (# iterations to process data given some MII width)
localparam pPreamble_Cnt    = pPreamble_Bits >> (pMII_WIDTH >> 1);
localparam pSFD_Cnt         = pSFD_Bits >> (pMII_WIDTH >> 1);
localparam pMAC_Addr_Cnt    = pMAC_Addr_Bits >> (pMII_WIDTH >> 1);
localparam pLen_Type_Cnt    = pLen_Type_Bits >> (pMII_WIDTH >> 1);
localparam pFCS_Cnt         = pFCS_Bits >> (pMII_WIDTH >> 1);