#====================================================================
# simpleEthernet
# eth_rx.v
# Testbench for Ethernet RMII receive module
# 12/10/24
#====================================================================

# NOTE: Rxd[1:0] in eth_rx.gtkw has bit order reversed
# http://ebook.pldworld.com/_eBook/-Telecommunications,Networks-/TCPIP/RMII/rmii_rev12.pdf

import tb_eth_frame_gen as frame_gen
import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge

CLK_PERIOD = 20
CLK_UNITS = 'ns'

@cocotb.test()
async def tb_eth_rx(dut):

    # start in reset
    dut.Rst.value = 1

    # start clock
    Clk = Clock(dut.Clk, CLK_PERIOD, CLK_UNITS)
    cocotb.start_soon(Clk.start())
    for _ in range(5):
        await(RisingEdge(dut.Clk))

    # de-assert reset
    await(RisingEdge(dut.Clk))
    dut.Rst.value = 0
    for _ in range(5):
        await(RisingEdge(dut.Clk))

    # apply input stimulus
    input_vec = frame_gen.frame_gen()
    vec = BinaryValue()
    for rx in input_vec:
        await(RisingEdge(dut.Clk))
        binstr = str(rx[1]) + str(rx[0])
        vec.binstr = binstr
        dut.Rxd.value = vec
    await(Timer(1, 'us'))




  
  


