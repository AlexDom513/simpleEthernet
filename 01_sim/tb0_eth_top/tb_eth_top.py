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

    await(Timer(10, 'us'))
