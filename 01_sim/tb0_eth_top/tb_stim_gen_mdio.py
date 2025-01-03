#====================================================================
# simpleEthernet
# tb_stim_gen_mdio.py
# MDIO stimulus generator for Ethernet regs module
# 1/3/25
#====================================================================

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge

class Stim_Gen_Mdio:

    def __init__(self, dut):
        self.dut = dut