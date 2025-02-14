#--------------------------------------------------------------------
# simpleEthernet
# tb_eth_top.py
# Top-level testbench for Ethernet RMII module
# 12/30/24
#--------------------------------------------------------------------

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge
from tb_stim_gen_axi import Stim_Gen_Axi
from tb_stim_gen_mdio import Stim_Gen_Mdio

@cocotb.test()
async def tb_eth_top(dut):

    #------------------------------------------
    # setup
    #------------------------------------------

    # instantiate stim generators
    stim_gen_axi = Stim_Gen_Axi(dut)
    stim_gen_mdio = Stim_Gen_Mdio(dut)

    # ethernet startup
    cocotb.start_soon(Clock(dut.Eth_Clk, 20, 'ns').start())
    await RisingEdge(dut.Eth_Clk)
    dut.Eth_Rst.value = 1
    await RisingEdge(dut.Eth_Clk)
    dut.Eth_Rst.value = 0

    # sync reset
    await stim_gen_axi.axi_sync_reset()
    await(Timer(1, 'us'))

    #------------------------------------------
    # register tests
    #------------------------------------------

    # mdio read test
    cocotb.start_soon(stim_gen_axi.phy_regs_read_sim())
    await stim_gen_mdio.mdio_read_response()
    await(Timer(100, 'us'))

    # mdio write test
    cocotb.start_soon(stim_gen_axi.phy_regs_write_sim())
    await stim_gen_mdio.mdio_write_check()
    await(Timer(100, 'us'))

    #------------------------------------------
    # ethernet tests
    #------------------------------------------

    # ethernet tx test
    await RisingEdge(dut.Eth_Clk)
    dut.Eth_Tx_Test_En.value = 1
    await(Timer(100, 'us'))
    await RisingEdge(dut.Eth_Clk)
    dut.Eth_Tx_Test_En.value = 0
    await(Timer(100, 'us'))

    await RisingEdge(dut.Eth_Clk)
    dut.Eth_Tx_Test_En.value = 1
    await(Timer(100, 'us'))
    await RisingEdge(dut.Eth_Clk)
    dut.Eth_Tx_Test_En.value = 0

    # await stim_gen_axi.ethernet_tx_sim()
    # await(Timer(100, 'us'))

    await(Timer(1, 'ms'))
