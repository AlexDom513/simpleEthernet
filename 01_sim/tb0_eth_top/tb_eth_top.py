#====================================================================
# simpleEthernet
# tb_eth_top.py
# Top-level testbench for Ethernet RMII module
# 12/30/24
#====================================================================

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge
from tb_stim_gen_axi import Stim_Gen_Axi
from tb_stim_gen_mdio import Stim_Gen_Mdio

@cocotb.test()
async def tb_eth_top(dut):

    # instantiate stim generators
    stim_gen_axi = Stim_Gen_Axi(dut)
    stim_gen_mdio = Stim_Gen_Mdio(dut)

    # sync reset
    await stim_gen_axi.axi_sync_reset()
    await(Timer(1, 'us'))

    # eth_regs tests
    cocotb.start_soon(stim_gen_axi.phy_regs_read_sim())
    await stim_gen_mdio.mdio_read_response()

    # wait
    await(Timer(1, 'ms'))
