#  simpleEthernet
The purpose of this project is to learn about ethernet by developing a simple MAC that interfaces with the LAN8270 PHY via RMII.
This will support future projects in which test data can be easily generated on a PC, sent to the FPGA for processing, and sent back to a PC for analysis.

## Infrastructure
- Zynq processor interacts with registers module via AXI4-Lite interface
- ethernet PHY can be read/configured by setting MDIO data/control registers
- testbenches for RX, TX, and system using Cocotb
- Vivado project build scripts
- Vitis project build scripts

## Transmit
- user writes to data FIFO, packet ready strobe kicks off TX process
- current implementation handles Preamble, SFD, MAC Destination, MAC source, Ethertype, and CRC
- included TPG can be used to test Payload

<img src="/04_docs/media/wireshark_tx.png" style="width:600px; height:auto;">

## Receive
- forms/processes bytes from PHY's output stream
- computes and validates CRC
