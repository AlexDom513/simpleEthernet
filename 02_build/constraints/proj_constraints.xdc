# https://www.01signal.com/constraints/

#====================================================================
# Clock Constraints
#====================================================================

# Input Eth Clock
create_clock -period 20.000 -name eth_clk [get_ports Eth_Clk]

# Output MDC Clock
create_generated_clock -name mdc_clk -source [get_pins eth_top_inst/clk_rst_mgr_inst/CLK] -divide_by 100 [get_pins eth_top_inst/MDC_Clk_OBUF]

#====================================================================
# CDC Constraints
#====================================================================

# NOTE: maybe change to set_max_delay
set_clock_groups -asynchronous -group [get_clocks clk_fpga_0] -group [get_clocks eth_clk]

#====================================================================
# I/O Delay Constraints
#====================================================================

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
connect_debug_port u_ila_0/clk [get_nets [list Eth_Clk_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {eth_top_inst/eth_tx_inst/rdata[0]} {eth_top_inst/eth_tx_inst/rdata[1]} {eth_top_inst/eth_tx_inst/rdata[2]} {eth_top_inst/eth_tx_inst/rdata[3]} {eth_top_inst/eth_tx_inst/rdata[4]} {eth_top_inst/eth_tx_inst/rdata[5]} {eth_top_inst/eth_tx_inst/rdata[6]} {eth_top_inst/eth_tx_inst/rdata[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {eth_top_inst/eth_tx_inst/rCrc_Computed[0]} {eth_top_inst/eth_tx_inst/rCrc_Computed[1]} {eth_top_inst/eth_tx_inst/rCrc_Computed[2]} {eth_top_inst/eth_tx_inst/rCrc_Computed[3]} {eth_top_inst/eth_tx_inst/rCrc_Computed[4]} {eth_top_inst/eth_tx_inst/rCrc_Computed[5]} {eth_top_inst/eth_tx_inst/rCrc_Computed[6]} {eth_top_inst/eth_tx_inst/rCrc_Computed[7]} {eth_top_inst/eth_tx_inst/rCrc_Computed[8]} {eth_top_inst/eth_tx_inst/rCrc_Computed[9]} {eth_top_inst/eth_tx_inst/rCrc_Computed[10]} {eth_top_inst/eth_tx_inst/rCrc_Computed[11]} {eth_top_inst/eth_tx_inst/rCrc_Computed[12]} {eth_top_inst/eth_tx_inst/rCrc_Computed[13]} {eth_top_inst/eth_tx_inst/rCrc_Computed[14]} {eth_top_inst/eth_tx_inst/rCrc_Computed[15]} {eth_top_inst/eth_tx_inst/rCrc_Computed[16]} {eth_top_inst/eth_tx_inst/rCrc_Computed[17]} {eth_top_inst/eth_tx_inst/rCrc_Computed[18]} {eth_top_inst/eth_tx_inst/rCrc_Computed[19]} {eth_top_inst/eth_tx_inst/rCrc_Computed[20]} {eth_top_inst/eth_tx_inst/rCrc_Computed[21]} {eth_top_inst/eth_tx_inst/rCrc_Computed[22]} {eth_top_inst/eth_tx_inst/rCrc_Computed[23]} {eth_top_inst/eth_tx_inst/rCrc_Computed[24]} {eth_top_inst/eth_tx_inst/rCrc_Computed[25]} {eth_top_inst/eth_tx_inst/rCrc_Computed[26]} {eth_top_inst/eth_tx_inst/rCrc_Computed[27]} {eth_top_inst/eth_tx_inst/rCrc_Computed[28]} {eth_top_inst/eth_tx_inst/rCrc_Computed[29]} {eth_top_inst/eth_tx_inst/rCrc_Computed[30]} {eth_top_inst/eth_tx_inst/rCrc_Computed[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 2 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {Txd_OBUF[0]} {Txd_OBUF[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 2 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {Rxd_IBUF[0]} {Rxd_IBUF[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 8 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {eth_top_inst/eth_rx_inst/rByte_d1[0]} {eth_top_inst/eth_rx_inst/rByte_d1[1]} {eth_top_inst/eth_rx_inst/rByte_d1[2]} {eth_top_inst/eth_rx_inst/rByte_d1[3]} {eth_top_inst/eth_rx_inst/rByte_d1[4]} {eth_top_inst/eth_rx_inst/rByte_d1[5]} {eth_top_inst/eth_rx_inst/rByte_d1[6]} {eth_top_inst/eth_rx_inst/rByte_d1[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 32 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[0]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[1]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[2]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[3]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[4]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[5]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[6]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[7]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[8]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[9]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[10]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[11]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[12]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[13]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[14]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[15]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[16]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[17]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[18]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[19]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[20]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[21]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[22]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[23]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[24]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[25]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[26]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[27]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[28]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[29]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[30]} {eth_top_inst/eth_rx_inst/rCrc_Computed_d3[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list Crc_Valid_OBUF]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list Crs_Dv_IBUF]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list eth_top_inst/eth_rx_inst/rByte_Rdy_d1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list Tx_En_OBUF]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list eth_top_inst/eth_tx_inst/wFifo_Rd_Valid]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets Eth_Clk_IBUF_BUFG]
