#include <stdio.h>
#include "xil_io.h"
#include "eth_dat_gen.h"

// https://docs.amd.com/v/u/en-US/ds806_axi_fifo_mm_s

void WRITE_DAT_FIFO() {

    // write to clear reset done interrupt bits
    Xil_Out32(DAT_FIFO_BASE_ADDR + DAT_FIFO_ISR_OFFSET, 0xFFFFFFFF);

    // write packet data
    // (IPV4)
    Xil_Out32(DAT_FIFO_BASE_ADDR + DAT_FIFO_WP_OFFSET, 0x45000064);
    Xil_Out32(DAT_FIFO_BASE_ADDR + DAT_FIFO_WP_OFFSET, 0x1C464000);
    Xil_Out32(DAT_FIFO_BASE_ADDR + DAT_FIFO_WP_OFFSET, 0x4011BE16);
    Xil_Out32(DAT_FIFO_BASE_ADDR + DAT_FIFO_WP_OFFSET, 0xC0A80168); // source ip
    Xil_Out32(DAT_FIFO_BASE_ADDR + DAT_FIFO_WP_OFFSET, 0xC0A80101); // destination ip

    // (UDP)
    Xil_Out32(DAT_FIFO_BASE_ADDR + DAT_FIFO_WP_OFFSET, 0x1F901F91); // source & destination port
    Xil_Out32(DAT_FIFO_BASE_ADDR + DAT_FIFO_WP_OFFSET, 0x00500000); // length and checksum

    // (Data) "hello world"
    Xil_Out32(DAT_FIFO_BASE_ADDR + DAT_FIFO_WP_OFFSET, 0x68656c6c);
    Xil_Out32(DAT_FIFO_BASE_ADDR + DAT_FIFO_WP_OFFSET, 0x6f20776f);
    Xil_Out32(DAT_FIFO_BASE_ADDR + DAT_FIFO_WP_OFFSET, 0x726c6400);

    // set transmit length (starting transmission)
    Xil_Out32(DAT_FIFO_BASE_ADDR + DAT_FIFO_TLR_OFFSET, 0x28); // 40 bytes
}