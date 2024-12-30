#====================================================================
# simpleEthernet
# tb_eth_rx.py
# Top-level testbench for Ethernet RMII module
# 12/30/24
#====================================================================

import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge

@cocotb.test()
async def tb_eth_top(dut):

    # start in reset
    dut.Rst.value = 1

    # start clock
    Clk = Clock(dut.Clk, 20, 'ns')
    cocotb.start_soon(Clk.start())
    for _ in range(5):
        await(RisingEdge(dut.Clk))

    # de-assert reset
    await(RisingEdge(dut.Clk))
    dut.Rst.value = 0
    for _ in range(5):
        await(RisingEdge(dut.Clk))
