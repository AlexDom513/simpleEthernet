//====================================================================
// 02_simple_ethernet
// eth_reg_intf.c
// helper functions to simplify ETH PHY register readout/display
//====================================================================

#include <stdio.h>
#include "xil_io.h"
#include "eth_regs.h"

// delay must be sufficiently long so mdio module can capture correct value -- need to fix HW!
void delay() {
    for (int i = 0; i < DELAY_PERIOD; i++) {
        asm("nop");
    }
}

void READ_PHY_REGS() {
    u32 offsets[] = {
        MDIO_PHY_CTRL_OFFSET_HW,
        MDIO_PHY_STAT_OFFSET_HW,
        MDIO_PHY_IDENT_1_OFFSET_HW,
        MDIO_PHY_IDENT_2_OFFSET_HW
    };
    size_t num_offsets = sizeof(offsets) / sizeof(offsets[0]);

    // Custom Register Descriptions (eth_mdio)
    // (0)  MDIO Control Register
    //        - bit(s) {11:7}   - Register Address
    //        - bit(s) {6:2}    - PHY Address
    //        - bit(s) {1}      - Read (== 0) / Write (== 1)
    //        - bit(s) {0}      - Enable

    // once MDIO transaction is initiated, PHY register value will be transferred to eth_regs,
    // MDIO user control register must be cleared before initiating a new transaction
    for (size_t i = 0; i < num_offsets; i++) {
        Xil_Out32(MDIO_BASE_ADDR + MDIO_USR_CTRL_OFFSET, 0x0);
        delay();

        // bits ---------------------------------------> {phy reg addr}    | {phy addr} | {Read =0}  | {Enable}
        Xil_Out32(MDIO_BASE_ADDR + MDIO_USR_CTRL_OFFSET, (offsets[i] << 7) | (0x1 << 2) | (0x0 << 1) | (0x1));
        delay();
    }
    delay();
    printf("MDIO Transactions Completed!\n");
}

void BASIC_CTRL_REG() {
    u32 regVal = Xil_In32(MDIO_BASE_ADDR + MDIO_PHY_CTRL_OFFSET);

    printf("----------------------------------------------------\n");
    printf("Basic Control Register\n");
    printf("----------------------------------------------------\n");
    printf("(15) Soft Reset                 | {%d}\n", (regVal & (1 << 15)) != 0);
    printf("(14) Loopback                   | {%d}\n", (regVal & (1 << 14)) != 0);
    printf("(13) Speed Select               | {%d}\n", (regVal & (1 << 13)) != 0);
    printf("(12) Auto-Negotiate Enable      | {%d}\n", (regVal & (1 << 12)) != 0);
    printf("(11) Power Down                 | {%d}\n", (regVal & (1 << 11)) != 0);
    printf("(10) Isolate                    | {%d}\n", (regVal & (1 << 10)) != 0);
    printf("(9)  Restart Auto-Negotiate     | {%d}\n", (regVal & (1 << 9))  != 0);
    printf("(8)  Duplex Mode                | {%d}\n", (regVal & (1 << 8))  != 0);
    printf("\n");
}

void BASIC_STAT_REG() {
    u32 regVal = Xil_In32(MDIO_BASE_ADDR + MDIO_PHY_STAT_OFFSET);

    printf("----------------------------------------------------\n");
    printf("Basic Status Register\n");
    printf("----------------------------------------------------\n");
    printf("(15) 100BASE-T4                 | {%d}\n", (regVal & (1 << 15)) != 0);
    printf("(14) 100BASE-TX Full Duplex     | {%d}\n", (regVal & (1 << 14)) != 0);
    printf("(13) 100BASE-TX Half Duplex     | {%d}\n", (regVal & (1 << 13)) != 0);
    printf("(12) 10BASE-T Full Duplex       | {%d}\n", (regVal & (1 << 12)) != 0);
    printf("(11) 10BASE-T Half Duplex       | {%d}\n", (regVal & (1 << 11)) != 0);
    printf("(10) 100BASE-T2 Full Duplex     | {%d}\n", (regVal & (1 << 10)) != 0);
    printf("(9)  100BASE-T2 Half Duplex     | {%d}\n", (regVal & (1 << 9)) != 0);
    printf("(8)  Extended Status            | {%d}\n", (regVal & (1 << 8)) != 0);
    printf("(5)  Auto-Negotiate Complete    | {%d}\n", (regVal & (1 << 5)) != 0);
    printf("(4)  Remote Fault               | {%d}\n", (regVal & (1 << 4)) != 0);
    printf("(3)  Auto-Negotiate Ability     | {%d}\n", (regVal & (1 << 3)) != 0);
    printf("(2)  Link Status                | {%d}\n", (regVal & (1 << 2)) != 0);
    printf("(1)  Jabber Detect              | {%d}\n", (regVal & (1 << 1)) != 0);
    printf("(0)  Extended Capabilities      | {%d}\n", (regVal & (1 << 0)) != 0);
    printf("\n");
}

void PHY_IDENT_1_REG() {
    u32 regVal = Xil_In32(MDIO_BASE_ADDR + MDIO_PHY_IDENT_1_OFFSET);

    printf("----------------------------------------------------\n");
    printf("PHY Identifier 1 Register\n");
    printf("----------------------------------------------------\n");
    printf("(15:0)  PHY ID Number           | {0x%08X}\n", regVal);
    printf("\n");
}

void PHY_IDENT_2_REG() {
    u32 regVal = Xil_In32(MDIO_BASE_ADDR + MDIO_PHY_IDENT_2_OFFSET);
    int bit;

    printf("----------------------------------------------------\n");
    printf("PHY Identifier 2 Register\n");
    printf("----------------------------------------------------\n");
    printf("(15:10) PHY ID Number           | {0b");
    for (int i = 15; i >= 10; i--) {
        bit = ((regVal & (1 << i)) != 0);
        printf("%d", bit);
    }
    printf("}\n");

    printf("(9:4)   Model Number            | {0b");
    for (int i = 9; i >= 4; i--) {
        bit = ((regVal & (1 << i)) != 0);
        printf("%d", bit);
    }
    printf("}\n");

    printf("(3:0)   Revision Number         | {0b");
    for (int i = 3; i >= 0; i--) {
        bit = ((regVal & (1 << i)) != 0);
        printf("%d", bit);
    }
    printf("}\n");
    printf("\n");
}
