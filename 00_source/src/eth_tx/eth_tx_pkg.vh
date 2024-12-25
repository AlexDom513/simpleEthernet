//====================================================================
// 02_simple_ethernet
// eth_tx_pkg.vh
// Ethernet RMII transmit module constants
// 12/23/24
//====================================================================

`ifndef _eth_tx_pkg_
`define _eth_tx_pkg_

// number of parallel data lines to PHY
`define pMII_WIDTH          2

// shift to convert bytes to bits
`define pBytes_To_Bits      3

// eth_tx_ctrl_fsm
`define IDLE                4'h0
`define PREAMBLE            4'h1
`define SFD                 4'h2
`define DEST_ADDR           4'h3
`define SRC_ADDR            4'h4
`define LEN_TYPE            4'h5
`define DATA                4'h6
`define PAD                 4'h7
`define FCS                 4'h8

// byte counts
`define pPreamble_Bytes     10'h7
`define pSFD_Bytes          10'h1
`define pMAC_Addr_Bytes     10'h6
`define pLen_Type_Bytes     10'h2
`define pPayload_Bytes      10'h48 // 72 bytes left for payload after all headers
`define pFCS_Bytes          10'h4

// bit counts
`define pPreamble_Bits      (`pPreamble_Bytes   << `pBytes_To_Bits)
`define pSFD_Bits           (`pSFD_Bytes        << `pBytes_To_Bits)
`define pMAC_Addr_Bits      (`pMAC_Addr_Bytes   << `pBytes_To_Bits)
`define pLen_Type_Bits      (`pLen_Type_Bytes   << `pBytes_To_Bits)
`define pFCS_Bits           (`pFCS_Bytes        << `pBytes_To_Bits)

// serial counts (# iterations to process data given some MII width)
`define pPreamble_Cnt       (`pPreamble_Bits    >> (`pMII_WIDTH >> 1))
`define pSFD_Cnt            (`pSFD_Bits         >> (`pMII_WIDTH >> 1))
`define pMAC_Addr_Cnt       (`pMAC_Addr_Bits    >> (`pMII_WIDTH >> 1))
`define pLen_Type_Cnt       (`pLen_Type_Bits    >> (`pMII_WIDTH >> 1))
`define pFCS_Cnt            (`pFCS_Bits         >> (`pMII_WIDTH >> 1))

`endif
