#--------------------------------------------------------------------
# simpleEthernet
# tb_eth_tx.py
# Testbench for Ethernet RMII transmit module
# 12/23/24
#--------------------------------------------------------------------

import tb_eth_tx_frame_gen as frame_gen
import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge

NUM_FRAMES = 1

async def tx_capture(dut):
  record = []
  await(RisingEdge(dut.Tx_En))
  await(RisingEdge(dut.Clk))
  while(dut.Tx_En.value == 1):
    binstr = list(dut.Txd.value.binstr)
    record.append(binstr[1]) # Txd[0] (lsb of duet, but later in list)
    record.append(binstr[0]) # Txd[1] (msb of duet, but earlier in list)
    await(RisingEdge(dut.Clk))

  with open('1_bit_capture.txt', 'w') as f:
    for bit in record:
      f.write(bit + '\n')


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

  # begin capture
  cocotb.start_soon(tx_capture(dut))

  # apply input stimulus
  for _ in range(NUM_FRAMES):
    input_vec = frame_gen.frame_gen()
    for i in range(len(input_vec)):
      await(RisingEdge(dut.Clk))
      if (i == len(input_vec)-1):
        dut.Eth_Byte.value = input_vec[i] + 2**8 # EOP
      else:
        dut.Eth_Byte.value = input_vec[i]
      dut.Eth_Byte_Valid.value = 1

    # disable input stimulus
    await(RisingEdge(dut.Clk))
    dut.Eth_Byte.value = BinaryValue(0, n_bits=10)
    dut.Eth_Byte_Valid.value = 0

    # strobe frame ready
    await(RisingEdge(dut.Clk))
    dut.Eth_Pkt_Rdy.value = 1
    await(RisingEdge(dut.Clk))
    dut.Eth_Pkt_Rdy.value = 0

    # # capture transmit data
    # await(RisingEdge(dut.Tx_En))
    # await(RisingEdge(dut.Clk))
    # while(dut.Tx_En.value == 1):
    #   binstr = list(dut.Txd.value.binstr)
    #   record.append(binstr[1]) # Txd[0] (lsb of duet, but later in list)
    #   record.append(binstr[0]) # Txd[1] (msb of duet, but earlier in list)
    #   await(RisingEdge(dut.Clk))

    # buffer time
    await(Timer(10, 'us'))

  # with open('1_bit_capture.txt', 'w') as f:
  #   for bit in record:
  #     f.write(bit + '\n')
    