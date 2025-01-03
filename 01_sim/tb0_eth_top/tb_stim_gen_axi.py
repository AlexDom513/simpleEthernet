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

    async def axi_wait_cycles(self, cycles):
        for i in range(cycles):
            await RisingEdge(self.dut.AXI_Clk)

    async def axi_reg_read(self, addr):
        await RisingEdge(self.dut.AXI_Clk)
        data = await self.Axi_Lite_Master.read_dword(addr)

    async def axi_reg_write(self, addr, data):
        await RisingEdge(self.dut.AXI_Clk)
        await self.Axi_Lite_Master.write_dword(addr, data)

    # issue command via axi write to read phy regs via MDIO
    async def phy_regs_read_sim(self):

        # reference eth_regs.h for HW offsets
        # bits ------ -> {phy reg addr}    | {phy addr} | {Rd/Wr =0/1}  | {Enable}
        # value = ("MDIO_PHY_REG_HW" << 7) | (0x1 << 2) | (0x0 << 1)    | 0x1

        # issue axi command to read phy ctrl reg
        value = (0x00 << 7) | (0x1 << 2) | (0x0 << 1) | 0x1
        await self.axi_reg_write(0x0, value)
        await self.axi_wait_cycles(5)

        # issue axi command to read phy status reg
        value = (0x01 << 7) | (0x1 << 2) | (0x0 << 1) | 0x1
        await self.axi_reg_write(0x4, value)
        await self.axi_wait_cycles(5)
        