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
set_property C_DATA_DEPTH 4096 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list Eth_Clk_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 2 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {eth_top_inst/eth_rx_inst/Rxd_IBUF[0]} {eth_top_inst/eth_rx_inst/Rxd_IBUF[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 8 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {eth_top_inst/eth_rx_inst/rByte_d1[0]} {eth_top_inst/eth_rx_inst/rByte_d1[1]} {eth_top_inst/eth_rx_inst/rByte_d1[2]} {eth_top_inst/eth_rx_inst/rByte_d1[3]} {eth_top_inst/eth_rx_inst/rByte_d1[4]} {eth_top_inst/eth_rx_inst/rByte_d1[5]} {eth_top_inst/eth_rx_inst/rByte_d1[6]} {eth_top_inst/eth_rx_inst/rByte_d1[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 8 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {eth_top_inst/eth_tx_inst/async_fifo_inst/fifomem/rdata[0]} {eth_top_inst/eth_tx_inst/async_fifo_inst/fifomem/rdata[1]} {eth_top_inst/eth_tx_inst/async_fifo_inst/fifomem/rdata[2]} {eth_top_inst/eth_tx_inst/async_fifo_inst/fifomem/rdata[3]} {eth_top_inst/eth_tx_inst/async_fifo_inst/fifomem/rdata[4]} {eth_top_inst/eth_tx_inst/async_fifo_inst/fifomem/rdata[5]} {eth_top_inst/eth_tx_inst/async_fifo_inst/fifomem/rdata[6]} {eth_top_inst/eth_tx_inst/async_fifo_inst/fifomem/rdata[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 3 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {eth_top_inst/eth_tx_inst/wTx_Ctrl_FSM_State[0]} {eth_top_inst/eth_tx_inst/wTx_Ctrl_FSM_State[1]} {eth_top_inst/eth_tx_inst/wTx_Ctrl_FSM_State[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 2 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {eth_top_inst/eth_tx_inst/rTx_Data_d1_reg[1]_0[0]} {eth_top_inst/eth_tx_inst/rTx_Data_d1_reg[1]_0[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list eth_top_inst/eth_rx_inst/Crc_Valid_OBUF]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list eth_top_inst/eth_rx_inst/rByte_Rdy]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list eth_top_inst/Tx_En_OBUF]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list eth_top_inst/eth_tx_inst/wFifo_Rd_Valid]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets Eth_Clk_IBUF_BUFG]
