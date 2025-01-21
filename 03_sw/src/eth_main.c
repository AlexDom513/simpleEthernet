//====================================================================
// simpleEthernet
// eth_main.c
// 9/20/24
//====================================================================

#include <stdio.h>
#include "platform.h"
#include "xil_io.h"
#include "xil_types.h"
#include "eth_regs.h"
#include "eth_dat_gen.h"

int main() {
    init_platform();

    // loads local registers with configs from phy
    READ_PHY_REGS();

    // display local reg contents
    BASIC_CTRL_REG();
    BASIC_STAT_REG();
    PHY_IDENT_1_REG();
    PHY_IDENT_2_REG();

    // send sample packet
    ETH_TX_TEST_EN();

    cleanup_platform();
    return 0;
}
