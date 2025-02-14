#--------------------------------------------------------------------
# simpleEthernet
# tb_stim_gen_mdio.py
# MDIO stimulus generator for Ethernet regs module
# 1/3/25
#--------------------------------------------------------------------

import cocotb
from cocotb.triggers import RisingEdge

class Stim_Gen_Mdio:

    def __init__(self, dut):
        self.dut = dut

    # monitor for SOF and read OP code, return sample data after turn-around
    async def mdio_read_response(self):

        # check preamble
        await RisingEdge(self.dut.MDIO)
        for _ in range(32):
            assert self.dut.MDIO == 1
            await RisingEdge(self.dut.MDC_Clk)

        # check SOF
        assert self.dut.MDIO == 0
        await RisingEdge(self.dut.MDC_Clk)
        assert self.dut.MDIO == 1
        await RisingEdge(self.dut.MDC_Clk)

        # check OP code (matches read)
        assert self.dut.MDIO == 1
        await RisingEdge(self.dut.MDC_Clk)
        assert self.dut.MDIO == 0
        await RisingEdge(self.dut.MDC_Clk)

        # skip over addresses and turn-around
        for _ in range(12):
            await RisingEdge(self.dut.MDC_Clk)

        # set all data bits to 1
        self.dut.eth_mdio_inst.wMDIO_In_TB.value = 1
        for _ in range(16):
            await RisingEdge(self.dut.MDC_Clk)

        # return MDIO line to 0
        self.dut.eth_mdio_inst.wMDIO_In_TB.value = 0

    # monitor for SOF and write OP code, accept sample data after turn-around
    async def mdio_write_check(self):
        
        # check preamble
        await RisingEdge(self.dut.MDIO)
        for _ in range(32):
            assert self.dut.MDIO == 1
            await RisingEdge(self.dut.MDC_Clk)

        # check SOF
        assert self.dut.MDIO == 0
        await RisingEdge(self.dut.MDC_Clk)
        assert self.dut.MDIO == 1
        await RisingEdge(self.dut.MDC_Clk)

        # check OP code (matches write)
        assert self.dut.MDIO == 0
        await RisingEdge(self.dut.MDC_Clk)
        assert self.dut.MDIO == 1
        await RisingEdge(self.dut.MDC_Clk)

        # skip over addresses and turn-around
        for _ in range(12):
            await RisingEdge(self.dut.MDC_Clk)

        # check all data bits are 1
        for _ in range(16):
            assert self.dut.MDIO == 1
            await RisingEdge(self.dut.MDC_Clk)
            