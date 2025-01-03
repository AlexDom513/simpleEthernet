# example: https://gist.github.com/davidzwa/ef1eafc6cd23e613af612e27eddb054b

# axi ports
gtkwave::/Edit/Insert_Blank
set axi_ports [list]
lappend axi_ports eth_top.AXI_Clk
lappend axi_ports eth_top.AXI_Rstn
lappend axi_ports eth_top.AXI_awvalid
lappend axi_ports eth_top.AXI_awready
lappend axi_ports eth_top.AXI_awaddr
lappend axi_ports eth_top.AXI_wvalid
lappend axi_ports eth_top.AXI_wready
lappend axi_ports eth_top.AXI_wdata
lappend axi_ports eth_top.AXI_bvalid
lappend axi_ports eth_top.AXI_bresp
lappend axi_ports eth_top.AXI_bready
lappend axi_ports eth_top.AXI_arvalid
lappend axi_ports eth_top.AXI_arready
lappend axi_ports eth_top.AXI_araddr
lappend axi_ports eth_top.AXI_rdata
lappend axi_ports eth_top.AXI_rvalid
lappend axi_ports eth_top.AXI_rresp
gtkwave::addSignalsFromList $axi_ports
gtkwave::/Edit/Create_Group "AXI_Ports" $axi_ports
#gtkwave::/Edit/Toggle_Group_Open|Close "AXI_Ports"

# eth ports
gtkwave::/Edit/Insert_Blank
set eth_ports [list]
lappend eth_ports eth_top.Eth_Clk
lappend eth_ports eth_top.Eth_Rst
lappend eth_ports eth_top.Rxd
lappend eth_ports eth_top.Txd
lappend eth_ports eth_top.Tx_En
gtkwave::addSignalsFromList $eth_ports
gtkwave::/Edit/Create_Group "ETH_Ports" $eth_ports
gtkwave::/Edit/Toggle_Group_Open|Close "ETH_Ports"

# eth regs
gtkwave::/Edit/Insert_Blank
set eth_regs [list]
lappend eth_regs eth_top.eth_regs_inst.AXI_Clk
lappend eth_regs eth_top.eth_regs_inst.AXI_Rstn
lappend eth_regs eth_top.eth_regs_inst.rCtrl_Fsm_State
lappend eth_regs eth_top.eth_regs_inst.rRead_Addr
lappend eth_regs eth_top.eth_regs_inst.AXI_Slave_rdata
lappend eth_regs eth_top.eth_regs_inst.wWrite_Addr
lappend eth_regs eth_top.eth_regs_inst.rWrite_Reg
lappend eth_regs eth_top.eth_regs_inst.rMDIO_USR_CTRL_REG
lappend eth_regs eth_top.eth_regs_inst.rMDIO_USR_WRITE_REG
lappend eth_regs eth_top.eth_regs_inst.rMDIO_PHY_CTRL_REG
lappend eth_regs eth_top.eth_regs_inst.rMDIO_PHY_STAT_REG
gtkwave::addSignalsFromList $eth_regs
gtkwave::/Edit/Create_Group "ETH_Regs" $eth_regs
#gtkwave::/Edit/Toggle_Group_Open|Close "ETH_Regs"

# eth mdio
gtkwave::/Edit/Insert_Blank
set eth_mdio [list]
lappend eth_mdio eth_top.eth_mdio_inst.Clk
lappend eth_mdio eth_top.eth_mdio_inst.Rst
lappend eth_mdio eth_top.eth_mdio_inst.MDIO
lappend eth_mdio eth_top.eth_mdio_inst.MDIO_Phy_Addr_Recv
lappend eth_mdio eth_top.eth_mdio_inst.MDIO_Reg_Addr_Recv
lappend eth_mdio eth_top.eth_mdio_inst.MDIO_En_Recv
lappend eth_mdio eth_top.eth_mdio_inst.MDIO_Wr_Dat_Recv

lappend eth_mdio eth_top.eth_mdio_inst.rMDIO_En_Recv_meta
lappend eth_mdio eth_top.eth_mdio_inst.rMDIO_En_Recv
lappend eth_mdio eth_top.eth_mdio_inst.rMDIO_En_Recv_d1
lappend eth_mdio eth_top.eth_mdio_inst.rMDIO_Start
lappend eth_mdio eth_top.eth_mdio_inst.rCtrl_Fsm_State

lappend eth_mdio eth_top.eth_mdio_inst.rPhy_Addr
lappend eth_mdio eth_top.eth_mdio_inst.rReg_Addr
lappend eth_mdio eth_top.eth_mdio_inst.rReg_Addr_hold
lappend eth_mdio eth_top.eth_mdio_inst.rTransc_Type
lappend eth_mdio eth_top.eth_mdio_inst.rWr_Dat
lappend eth_mdio eth_top.eth_mdio_inst.rMDIO_Output_En
lappend eth_mdio eth_top.eth_mdio_inst.rMDIO_Wr

lappend eth_mdio eth_top.eth_mdio_inst.MDIO_Reg_Addr
lappend eth_mdio eth_top.eth_mdio_inst.MDIO_Data_Valid
lappend eth_mdio eth_top.eth_mdio_inst.MDIO_Data
gtkwave::addSignalsFromList $eth_mdio
gtkwave::/Edit/Create_Group "ETH_MDIO" $eth_mdio
#gtkwave::/Edit/Toggle_Group_Open|Close "ETH_MDIO"
