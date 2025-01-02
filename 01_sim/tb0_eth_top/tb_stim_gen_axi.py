#====================================================================
# simpleEthernet
# tb_stim_gen_axi.py
# AXI Lite stimulus generator for Ethernet regs module
# 1/1/25
#====================================================================

import cocotb
from cocotb.clock import Clock
from cocotbext.axi import AxiLiteBus, AxiLiteMaster

class Stim_Gen_Axi:

  def __init__(self, dut):
    self.dut = dut

    # start AXI clock
    cocotb.start_soon(Clock(dut.AXI_Clk, 10, 'ns').start())


    #self.Axi_Lite_Bus = AxiLiteBus.from_prefix(dut, "AXI")
    self.Axi_Lite_Master = AxiLiteMaster(AxiLiteBus.from_prefix(dut, "AXI"), dut.AXI_Clk, dut.AXI_Rstn, False)