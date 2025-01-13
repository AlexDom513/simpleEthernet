#====================================================================
# simpleEthernet
# tb_eth_top.py
# Top-level testbench for Ethernet RMII module
# 12/30/24
#====================================================================

import cocotb
from cocotb.triggers import Timer
from tb_stim_gen_axi import Stim_Gen_Axi
from tb_stim_gen_mdio import Stim_Gen_Mdio

@cocotb.test()
async def tb_eth_top(dut):

    #==========================================
    # setup
    #==========================================

    # instantiate stim generators
    stim_gen_axi = Stim_Gen_Axi(dut)
    stim_gen_mdio = Stim_Gen_Mdio(dut)

    # sync reset
    await stim_gen_axi.axi_sync_reset()
    await(Timer(1, 'us'))

    #==========================================
    # register tests
    #==========================================

    # mdio read test
    cocotb.start_soon(stim_gen_axi.phy_regs_read_sim())
    await stim_gen_mdio.mdio_read_response()
    await(Timer(100, 'us'))

    # mdio write test
    cocotb.start_soon(stim_gen_axi.phy_regs_write_sim())
    await stim_gen_mdio.mdio_write_check()
    await(Timer(100, 'us'))
