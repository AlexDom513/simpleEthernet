#--------------------------------------------------------------------
# simpleEthernet
# tb_eth_loopback.py
# Loopback (PC --> FPGA --> PC) test
# 3/22/25
#--------------------------------------------------------------------

import tb_eth_loopback_frame_gen as frame_gen
import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge

NUM_FRAMES = 3

@cocotb.test()
async def tb_eth_loopback(dut):

    # start in reset
    dut.Eth_Rst.value = 1

    # start clock
    Eth_Clk = Clock(dut.Eth_Clk, 20, 'ns')
    cocotb.start_soon(Eth_Clk.start())
    for _ in range(5):
        await(RisingEdge(dut.Eth_Clk))

    # de-assert reset
    await(RisingEdge(dut.Eth_Clk))
    dut.Eth_Rst.value = 0
    for _ in range(5):
        await(RisingEdge(dut.Eth_Clk))

    # apply input stimulus
    # need to discard packets we don't care about

    custom_etherpkt = False
    for _ in range(NUM_FRAMES):
        input_vec = frame_gen.frame_gen(custom_etherpkt)
        vec = BinaryValue()
        for rx in input_vec:
            await(RisingEdge(dut.Eth_Clk))
            binstr = str(rx[1]) + str(rx[0])
            vec.binstr = binstr
            dut.Rxd.value = vec
            dut.Crs_Dv.value = 1

        await(RisingEdge(dut.Eth_Clk))
        dut.Rxd.value = 0
        dut.Crs_Dv.value = 0
        await(Timer(10, 'us'))

    custom_etherpkt = True
    for _ in range(NUM_FRAMES):
        input_vec = frame_gen.frame_gen(custom_etherpkt)
        vec = BinaryValue()
        for rx in input_vec:
            await(RisingEdge(dut.Eth_Clk))
            binstr = str(rx[1]) + str(rx[0])
            vec.binstr = binstr
            dut.Rxd.value = vec
            dut.Crs_Dv.value = 1

        await(RisingEdge(dut.Eth_Clk))
        dut.Rxd.value = 0
        dut.Crs_Dv.value = 0
        await(Timer(10, 'us'))