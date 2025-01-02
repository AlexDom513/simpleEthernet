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

    # # start in reset
    # dut.Eth_Rst.value = 1

    # # start clocks
    # Eth_Clk = Clock(dut.Eth_Clk, 20, 'ns')
    # cocotb.start_soon(Eth_Clk.start())
    # for _ in range(5):
    #     await(RisingEdge(dut.Eth_Clk))

    # # de-assert reset
    # await(RisingEdge(dut.Eth_Clk))
    # dut.Eth_Rst.value = 0
    # for _ in range(5):
    #     await(RisingEdge(dut.Eth_Clk))

    await(Timer(10, 'us'))
