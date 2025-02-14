#--------------------------------------------------------------------
# simpleEthernet
# tb_eth_rx.py
# Testbench for Ethernet RMII receive module
# 12/10/24
#--------------------------------------------------------------------

import tb_eth_rx_frame_gen as frame_gen
import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge

NUM_FRAMES = 2

@cocotb.test()
async def tb_eth_rx(dut):

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

    # apply input stimulus
    for _ in range(NUM_FRAMES):
        input_vec = frame_gen.frame_gen()
        vec = BinaryValue()
        for rx in input_vec:
            await(RisingEdge(dut.Clk))
            binstr = str(rx[1]) + str(rx[0])
            vec.binstr = binstr
            dut.Rxd.value = vec
            dut.Crs_Dv.value = 1

        await(RisingEdge(dut.Clk))
        dut.Rxd.value = 0
        dut.Crs_Dv.value = 0
        await(Timer(5, 'us'))
