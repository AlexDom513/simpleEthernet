# example: https://gist.github.com/davidzwa/ef1eafc6cd23e613af612e27eddb054b

# axi ports
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

gtkwave::/Edit/Insert_Blank
gtkwave::addSignalsFromList $axi_ports
gtkwave::/Edit/Create_Group "AXI_Ports" $axi_ports