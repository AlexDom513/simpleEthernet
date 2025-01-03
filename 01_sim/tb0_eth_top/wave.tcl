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
gtkwave::/Edit/Toggle_Group_Open|Close "AXI_Ports"

# mdio ports
gtkwave::/Edit/Insert_Blank
set mdio_ports [list]
lappend mdio_ports eth_top.MDC_Clk
lappend mdio_ports eth_top.MDIO
gtkwave::addSignalsFromList $mdio_ports
gtkwave::/Edit/Create_Group "MDIO_Ports" $mdio_ports
gtkwave::/Edit/Toggle_Group_Open|Close "MDIO_Ports"

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
gtkwave::/Edit/Toggle_Group_Open|Close "ETH_Regs"

