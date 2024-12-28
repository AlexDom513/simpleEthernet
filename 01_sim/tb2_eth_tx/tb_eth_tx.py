#====================================================================
# simpleEthernet
# tb_eth_tx.py
# Testbench for Ethernet RMII transmit module
# 12/23/24
#====================================================================

import tb_eth_packet_gen as packet_gen
import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge

NUM_PACKETS = 2

@cocotb.test()
async def tb_eth_tx(dut):

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
  for _ in range(NUM_PACKETS):
    input_vec = packet_gen.packet_gen()
    for byte in input_vec:
      await(RisingEdge(dut.Clk))
      dut.Eth_Byte.value = byte
      dut.Eth_Byte_Valid.value = 1

    # disable input stimulus
    await(RisingEdge(dut.Clk))
    dut.Eth_Byte.value = BinaryValue(0, n_bits=8)
    dut.Eth_Byte_Valid.value = 0

    # strobe packet ready
    await(RisingEdge(dut.Clk))
    dut.Eth_Pkt_Rdy.value = 1
    await(RisingEdge(dut.Clk))
    dut.Eth_Pkt_Rdy.value = 0
    await(Timer(10, 'us'))
    