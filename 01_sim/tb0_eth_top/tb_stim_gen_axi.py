#====================================================================
# simpleEthernet
# tb_stim_gen_axi.py
# AXI Lite stimulus generator for Ethernet regs module, utilizes
# functionality in https://github.com/alexforencich/cocotbext-axi
# 1/1/25
#====================================================================

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge
from cocotbext.axi import AxiLiteBus, AxiLiteMaster

class Stim_Gen_Axi:

    def __init__(self, dut):
        self.dut = dut
        cocotb.start_soon(Clock(dut.AXI_Clk, 10, 'ns').start())
        self.Axi_Lite_Bus = AxiLiteBus.from_prefix(dut, "AXI")
        self.Axi_Lite_Master = AxiLiteMaster(self.Axi_Lite_Bus, dut.AXI_Clk, dut.AXI_Rstn, False)

    async def axi_sync_reset(self):
        await RisingEdge(self.dut.AXI_Clk)
        self.dut.AXI_Rstn.value = 0
        await RisingEdge(self.dut.AXI_Clk)
        await RisingEdge(self.dut.AXI_Clk)
        self.dut.AXI_Rstn.value = 1

    async def axi_reg_read(self, addr):
        await RisingEdge(self.dut.AXI_Clk)
        data = await self.Axi_Lite_Master.read(addr, 1)
