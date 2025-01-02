#====================================================================
# simpleEthernet
# tb_eth_top.py
# Top-level testbench for Ethernet RMII module
# 12/30/24
#====================================================================

from tb_stim_gen_axi import Stim_Gen_Axi

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge

@cocotb.test()
async def tb_eth_top(dut):

    # instantiate stim generators
    stim_gen_axi = Stim_Gen_Axi(dut)

    # sync reset
    await stim_gen_axi.axi_sync_reset()

    await(Timer(1, 'us'))
    await stim_gen_axi.axi_reg_read(0x0)

    await(Timer(10, 'us'))
