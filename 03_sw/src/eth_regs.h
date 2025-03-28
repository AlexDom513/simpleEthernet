//--------------------------------------------------------------------
// simpleEthernet
// eth_regs.h
// Offsets for ethernet configuration registers
// 9/20/24
//--------------------------------------------------------------------

#ifndef ETH_REGS_H
#define ETH_REGS_H

#include "xil_types.h"

#define DELAY_PERIOD                    10000

#define ETH_BASE_ADDR                   0x43C00000
#define ETH_TX_TEST_OFFSET              0x88

// byte address offsets (read/write w/ zynq)
#define MDIO_BASE_ADDR                  0x43C00000
#define MDIO_PHY_CTRL_OFFSET            0x00
#define MDIO_PHY_STAT_OFFSET            0x04
#define MDIO_PHY_IDENT_1_OFFSET         0x08
#define MDIO_PHY_IDENT_2_OFFSET         0x0C
#define MDIO_PHY_ANA_OFFSET             0x10
#define MDIO_PHY_ANLP_OFFSET            0x14
#define MDIO_PHY_ANE_OFFSET             0x18
#define MDIO_PHY_MODE_OFFSET            0x44
#define MDIO_PHY_SPEC_MD_OFFSET         0x48
#define MDIO_PHY_SYM_ERR_OFFSET         0x68
#define MDIO_PHY_INDC_OFFSET            0x6C
#define MDIO_PHY_INTR_SRC_OFFSET        0x74
#define MDIO_PHY_INTR_MSK_OFFSET        0x78
#define MDIO_PHY_SPEC_CTRL_OFFSET       0x7C
#define MDIO_USR_CTRL_OFFSET            0x80
#define MDIO_USR_WRITE_OFFSET           0x84

// phy address offsets (MDIO read/write w/ PHY)
#define MDIO_PHY_CTRL_OFFSET_HW         (MDIO_PHY_CTRL_OFFSET      >> 2)
#define MDIO_PHY_STAT_OFFSET_HW         (MDIO_PHY_STAT_OFFSET      >> 2)
#define MDIO_PHY_IDENT_1_OFFSET_HW      (MDIO_PHY_IDENT_1_OFFSET   >> 2)
#define MDIO_PHY_IDENT_2_OFFSET_HW      (MDIO_PHY_IDENT_2_OFFSET   >> 2)
#define MDIO_PHY_ANA_OFFSET_HW          (MDIO_PHY_ANA_OFFSET       >> 2)
#define MDIO_PHY_ANLP_OFFSET_HW         (MDIO_PHY_ANLP_OFFSET      >> 2)
#define MDIO_PHY_ANE_OFFSET_HW          (MDIO_PHY_ANE_OFFSET       >> 2)
#define MDIO_PHY_MODE_OFFSET_HW         (MDIO_PHY_MODE_OFFSET      >> 2)
#define MDIO_PHY_SPEC_MD_OFFSET_HW      (MDIO_PHY_SPEC_MD_OFFSET   >> 2)
#define MDIO_PHY_SYM_ERR_OFFSET_HW      (MDIO_PHY_SYM_ERR_OFFSET   >> 2)
#define MDIO_PHY_INDC_OFFSET_HW         (MDIO_PHY_INDC_OFFSET      >> 2)
#define MDIO_PHY_INTR_SRC_OFFSET_HW     (MDIO_PHY_INTR_SRC_OFFSET  >> 2)
#define MDIO_PHY_INTR_MSK_OFFSET_HW     (MDIO_PHY_INTR_MSK_OFFSET  >> 2)
#define MDIO_PHY_SPEC_CTRL_OFFSET_HW    (MDIO_PHY_SPEC_CTRL_OFFSET >> 2)

void delay();
void READ_PHY_REGS();
void BASIC_CTRL_REG();
void BASIC_STAT_REG();
void PHY_IDENT_1_REG();
void PHY_IDENT_2_REG();
void ETH_TX_TEST_EN();
void ETH_TX_TEST_DIS();

#endif // ETH_REGS_H