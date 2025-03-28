#--------------------------------------------------------------------
# simpleEthernet
# proj_constraints.xdc
# Clock, CDC, I/O delay constraints
# 2/14/25
#--------------------------------------------------------------------

#---------------------------------------------------------------------
# Clock Constraints
#---------------------------------------------------------------------

# Input Eth Clock
create_clock -period 20.000 -name eth_clk [get_ports Eth_Clk]

# Output MDC Clock
create_generated_clock -name mdc_clk -source [get_pins eth_top_inst/clk_rst_mgr_inst/CLK] -divide_by 100 [get_pins eth_top_inst/MDC_Clk_OBUF]

#---------------------------------------------------------------------
# CDC Constraints
#---------------------------------------------------------------------

# NOTE: maybe change to set_max_delay
set_clock_groups -asynchronous -group clk_fpga_0 -group eth_clk

#---------------------------------------------------------------------
# I/O Delay Constraints
#---------------------------------------------------------------------

# RMII (TX) (REF_CLK OUT MODE)
set_output_delay -clock eth_clk -max 8.000 [get_ports {Txd[*]}]
set_output_delay -clock eth_clk -min -2.000 [get_ports {Txd[*]}]

# RMII (RX) (REF_CLK OUT MODE)
set_input_delay -clock eth_clk -max 6.000 [get_ports {Rxd[*]}]
set_input_delay -clock eth_clk -min 1.400 [get_ports {Rxd[*]}]

# TODO: constrain TX_EN

# Serial Management Interface (SMI)
set_output_delay -clock mdc_clk -max 11.000 [get_ports MDIO]
set_output_delay -clock mdc_clk -min -10.000 [get_ports MDIO]
set_input_delay -clock mdc_clk -min 0.000 [get_ports MDIO]


connect_debug_port u_ila_0/probe1 [get_nets [list {eth_top_inst/eth_tx_inst/rdata[0]} {eth_top_inst/eth_tx_inst/rdata[1]} {eth_top_inst/eth_tx_inst/rdata[2]} {eth_top_inst/eth_tx_inst/rdata[3]} {eth_top_inst/eth_tx_inst/rdata[4]} {eth_top_inst/eth_tx_inst/rdata[5]} {eth_top_inst/eth_tx_inst/rdata[6]} {eth_top_inst/eth_tx_inst/rdata[7]}]]

connect_debug_port u_ila_0/probe3 [get_nets [list eth_top_inst/Crc_Valid_OBUF]]


set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wEth_Byte_Loopback[0]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wEth_Byte_Loopback[1]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wEth_Byte_Loopback[2]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wEth_Byte_Loopback[3]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wEth_Byte_Loopback[4]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wEth_Byte_Loopback[5]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wEth_Byte_Loopback[6]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wEth_Byte_Loopback[7]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wEth_Byte_Loopback[8]}]

connect_debug_port u_ila_0/probe2 [get_nets [list eth_top_inst/Crs_Dv_IBUF]]
connect_debug_port u_ila_0/probe4 [get_nets [list eth_top_inst/eth_rx_inst/eth_rx_ctrl_inst/wPkt_Invalid]]



set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/Recv_Byte[0]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/Recv_Byte[1]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/Recv_Byte[2]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/Recv_Byte[3]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/Recv_Byte[6]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/Recv_Byte[4]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/Recv_Byte[8]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/Recv_Byte[9]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/Recv_Byte[5]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/Recv_Byte[7]}]
set_property MARK_DEBUG false [get_nets eth_top_inst/eth_rx_inst/rByte_Rdy]
set_property MARK_DEBUG false [get_nets eth_top_inst/eth_rx_inst/wCrc_Valid]
set_property MARK_DEBUG false [get_nets eth_top_inst/eth_rx_inst/wEOP]
set_property MARK_DEBUG false [get_nets eth_top_inst/eth_rx_inst/wFifo_Empty]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_Rdy[4]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_d4[0]}]
set_property MARK_DEBUG false [get_nets eth_top_inst/eth_rx_inst/wPkt_Invalid]
set_property MARK_DEBUG false [get_nets eth_top_inst/eth_rx_inst/wSOP]
set_property MARK_DEBUG false [get_nets eth_top_inst/eth_rx_inst/wSOP_Out]
set_property MARK_DEBUG false [get_nets eth_top_inst/eth_rx_inst/wRecv_Byte_Rdy]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_Rdy[1]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_Rdy[2]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_Rdy[3]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wRecv_Byte[7]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wRecv_Byte[8]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_Rdy[5]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_Rdy[6]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_Rdy[7]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_Rdy[16]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_Rdy[9]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_Rdy[8]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rByte[1]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rSOP[12]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_Rdy[14]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rSOP[13]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rSOP[11]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rSOP[7]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rSOP[5]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rSOP[6]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wRecv_Byte[9]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_d4[6]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rByte[4]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rSOP[4]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rByte[5]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rByte[6]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rByte[7]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_d4[1]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_Rdy[0]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wRecv_Byte[4]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wRecv_Byte[6]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_Rdy[10]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_Rdy[12]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_d4[2]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_d4[4]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_d4[5]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rSOP[8]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rSOP[10]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rByte[2]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rByte[3]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_d4[7]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_Rdy[11]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_Rdy[13]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rSOP[0]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wRecv_Byte[2]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rSOP[9]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rSOP[15]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rByte[0]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rSOP[1]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rSOP[2]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rSOP[3]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rSOP[14]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wRecv_Byte[3]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wRecv_Byte[5]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_d4[3]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/rRecv_Byte_Rdy[15]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wRecv_Byte[0]}]
set_property MARK_DEBUG false [get_nets {eth_top_inst/eth_rx_inst/wRecv_Byte[1]}]
set_property MARK_DEBUG false [get_nets eth_top_inst/eth_rx_inst/Crs_Dv]
set_property MARK_DEBUG false [get_nets eth_top_inst/eth_rx_inst/Recv_Byte_Rdy]
set_property MARK_DEBUG false [get_nets eth_top_inst/eth_rx_inst/rCrc_Valid]
set_property MARK_DEBUG false [get_nets eth_top_inst/eth_rx_inst/rFifo_Rd_Valid]
