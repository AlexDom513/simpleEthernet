# ====================================================================
# Clock Constraints
# ====================================================================

# Input ETH Clock
create_clock -period 20.000 -name sysclk -add [get_ports Clk]




create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list Clk_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {rByte[0]} {rByte[1]} {rByte[2]} {rByte[3]} {rByte[4]} {rByte[5]} {rByte[6]} {rByte[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {eth_rx_ctrl_inst/rCrc_Recv[0]} {eth_rx_ctrl_inst/rCrc_Recv[1]} {eth_rx_ctrl_inst/rCrc_Recv[2]} {eth_rx_ctrl_inst/rCrc_Recv[3]} {eth_rx_ctrl_inst/rCrc_Recv[4]} {eth_rx_ctrl_inst/rCrc_Recv[5]} {eth_rx_ctrl_inst/rCrc_Recv[6]} {eth_rx_ctrl_inst/rCrc_Recv[7]} {eth_rx_ctrl_inst/rCrc_Recv[8]} {eth_rx_ctrl_inst/rCrc_Recv[9]} {eth_rx_ctrl_inst/rCrc_Recv[10]} {eth_rx_ctrl_inst/rCrc_Recv[11]} {eth_rx_ctrl_inst/rCrc_Recv[12]} {eth_rx_ctrl_inst/rCrc_Recv[13]} {eth_rx_ctrl_inst/rCrc_Recv[14]} {eth_rx_ctrl_inst/rCrc_Recv[15]} {eth_rx_ctrl_inst/rCrc_Recv[16]} {eth_rx_ctrl_inst/rCrc_Recv[17]} {eth_rx_ctrl_inst/rCrc_Recv[18]} {eth_rx_ctrl_inst/rCrc_Recv[19]} {eth_rx_ctrl_inst/rCrc_Recv[20]} {eth_rx_ctrl_inst/rCrc_Recv[21]} {eth_rx_ctrl_inst/rCrc_Recv[22]} {eth_rx_ctrl_inst/rCrc_Recv[23]} {eth_rx_ctrl_inst/rCrc_Recv[24]} {eth_rx_ctrl_inst/rCrc_Recv[25]} {eth_rx_ctrl_inst/rCrc_Recv[26]} {eth_rx_ctrl_inst/rCrc_Recv[27]} {eth_rx_ctrl_inst/rCrc_Recv[28]} {eth_rx_ctrl_inst/rCrc_Recv[29]} {eth_rx_ctrl_inst/rCrc_Recv[30]} {eth_rx_ctrl_inst/rCrc_Recv[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 2 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {eth_rx_ctrl_inst/Rxd_IBUF[0]} {eth_rx_ctrl_inst/Rxd_IBUF[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 3 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {eth_rx_ctrl_inst/rByte_Ctrl_FSM_State__0[0]} {eth_rx_ctrl_inst/rByte_Ctrl_FSM_State__0[1]} {eth_rx_ctrl_inst/rByte_Ctrl_FSM_State__0[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 32 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {rCrc_Computed[0]} {rCrc_Computed[1]} {rCrc_Computed[2]} {rCrc_Computed[3]} {rCrc_Computed[4]} {rCrc_Computed[5]} {rCrc_Computed[6]} {rCrc_Computed[7]} {rCrc_Computed[8]} {rCrc_Computed[9]} {rCrc_Computed[10]} {rCrc_Computed[11]} {rCrc_Computed[12]} {rCrc_Computed[13]} {rCrc_Computed[14]} {rCrc_Computed[15]} {rCrc_Computed[16]} {rCrc_Computed[17]} {rCrc_Computed[18]} {rCrc_Computed[19]} {rCrc_Computed[20]} {rCrc_Computed[21]} {rCrc_Computed[22]} {rCrc_Computed[23]} {rCrc_Computed[24]} {rCrc_Computed[25]} {rCrc_Computed[26]} {rCrc_Computed[27]} {rCrc_Computed[28]} {rCrc_Computed[29]} {rCrc_Computed[30]} {rCrc_Computed[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list eth_rx_ctrl_inst/Crc_Valid0]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list rByte_Rdy]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list eth_rx_ctrl_inst/Rx_En_i_1_n_0]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets Clk_IBUF_BUFG]
