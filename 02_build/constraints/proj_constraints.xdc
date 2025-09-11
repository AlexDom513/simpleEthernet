#--------------------------------------------------------------------
# simpleEthernet
# proj_constraints.xdc
# Clock, CDC, I/O delay constraints
# 2/14/25
#--------------------------------------------------------------------

# +----------------+
# |     Design     |
# +----------------+
#         |
#         +-- Ports        (Top-level I/O, external view)
#         |
#         +-- Cells        (Instances of modules, LUTs, FFs, etc.)
#         |     |
#         |     +-- Pins   (Ports of cells, internal connections)
#         |
#         +-- Nets         (Connect pins together)


#---------------------------------------------------------------------
# Clock Constraints
#---------------------------------------------------------------------

# Input Eth Clock
create_clock -period 20.000 -name Eth_Clk [get_ports Eth_Clk]

# Output MDC Clock (if not present Vivado CW - "* is not reachable by a timing clock")
create_generated_clock -name MDC_Clk -source [get_pins -hierarchical rMDC_Clk_reg/C] -divide_by 100 [get_pins -hierarchical rMDC_Clk_reg/Q]

# CDC constraints
# ...

# #---------------------------------------------------------------------
# I/O Delay Constraints
#---------------------------------------------------------------------

# Rising Edge System Synchronous Inputs

# A Single Data Rate (SDR) System Synchronous interface is
# an interface where the external device and the FPGA use
# the same clock, and a new data is captured one clock cycle
# after being launched

# input      __________            __________
# clock   __|          |__________|          |__
#           |
#           |------> (tco_min+trce_dly_min)
#           |------------> (tco_max+trce_dly_max)
#         __________      ________________
# data    __________XXXXXX_____ Data _____XXXXXXX

# set input_clock     <clock_name>;   # Name of input clock
# set tco_max         0.000;          # Maximum clock to out delay (external device)
# set tco_min         0.000;          # Minimum clock to out delay (external device)
# set trce_dly_max    0.000;          # Maximum board trace delay
# set trce_dly_min    0.000;          # Minimum board trace delay
# set input_ports     <input_ports>;  # List of input ports

# Input Delay Constraint
# set_input_delay -clock $input_clock -max [expr $tco_max + $trce_dly_max] [get_ports $input_ports];
# set_input_delay -clock $input_clock -min [expr $tco_min + $trce_dly_min] [get_ports $input_ports];

#---------------------------------------------------------------------

# Rising Edge System Synchronous Outputs
#
# A System Synchronous design interface is a clocking technique in which the same
# active-edge of a system clock is used for both the source and destination device.
#
# dest        __________            __________
# clk    ____|          |__________|
#                                  |
#     (trce_dly_max+tsu) <---------|
#             (trce_dly_min-thd) <-|
#                        __    __
# data   XXXXXXXXXXXXXXXX__DATA__XXXXXXXXXXXXX

# set destination_clock <clock_name>;     # Name of destination clock
# set tsu               0.000;            # Destination device setup time requirement
# set thd               0.000;            # Destination device hold time requirement
# set trce_dly_max      0.000;            # Maximum board trace delay
# set trce_dly_min      0.000;            # Minimum board trace delay
# set output_ports      <output_ports>;   # List of output ports

# Output Delay Constraint
# set_output_delay -clock $destination_clock -max [expr $trce_dly_max + $tsu] [get_ports $output_ports];
# set_output_delay -clock $destination_clock -min [expr $trce_dly_min - $thd] [get_ports $output_ports];

#---------------------------------------------------------------------

# NOTE: constraints 1 ns delay to account for wire lengths

#---------------------------------------------------------------------
# Input Delays:

# LAN8720A Datasheet: t_oval --> MIN: 0 ns, MAX 5 ns

# RMII (CRS_DV)
set_input_delay -clock Eth_Clk -max 6.000 [get_ports Crs_Dv]
set_input_delay -clock Eth_Clk -min 0.000 [get_ports Crs_Dv]

# RMII (RX)
set_input_delay -clock Eth_Clk -max 6.000 [get_ports {Rxd[*]}]
set_input_delay -clock Eth_Clk -min 0.000 [get_ports {Rxd[*]}]

# SMI (RX)
set_input_delay -clock MDC_Clk -max 301.000 [get_ports MDIO]
set_input_delay -clock MDC_Clk -min 0.000 [get_ports MDIO]

#---------------------------------------------------------------------
# Output Delays:

# RMII (TX_EN) (REF_CLK OUT MODE)
set_output_delay -clock Eth_Clk -max 5.000 [get_ports Tx_En]
set_output_delay -clock Eth_Clk -min -1.500 [get_ports Tx_En]

# RMII (TX)
set_output_delay -clock Eth_Clk -max 5.000 [get_ports {Txd[*]}]
set_output_delay -clock Eth_Clk -min -1.500 [get_ports {Txd[*]}]

# SMI (TX)
set_output_delay -clock MDC_Clk -max 11.000 [get_ports MDIO]
set_output_delay -clock MDC_Clk -min -10.000 [get_ports MDIO]

set_property MARK_DEBUG true [get_nets {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State[0]}]
set_property MARK_DEBUG true [get_nets {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State[1]}]
set_property MARK_DEBUG true [get_nets {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State[2]}]
set_property MARK_DEBUG true [get_nets {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State[3]}]






connect_debug_port u_ila_0/probe3 [get_nets [list {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[0]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[1]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[2]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[3]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[4]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[5]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[6]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[7]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[8]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[9]}]]
connect_debug_port u_ila_0/probe4 [get_nets [list {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[0]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[1]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[2]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[3]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[4]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[5]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[6]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[7]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[8]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[9]}]]
connect_debug_port u_ila_0/probe7 [get_nets [list {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State[0]} {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State[1]} {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State[2]} {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State[3]}]]
connect_debug_port u_ila_0/probe8 [get_nets [list {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State_d1[0]} {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State_d1[1]} {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State_d1[2]} {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State_d1[3]}]]
connect_debug_port u_ila_0/probe11 [get_nets [list eth_top_inst/eth_tx_inst/rEOP]]
connect_debug_port u_ila_0/probe12 [get_nets [list eth_top_inst/eth_tx_inst/tx_buf_full]]
connect_debug_port u_ila_0/probe17 [get_nets [list eth_top_inst/eth_tx_inst/wFifo_Rd_Valid]]


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list Eth_Clk_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 3 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {eth_top_inst/eth_rx_inst/eth_rx_ctrl_inst/sByte_Ctrl_State[0]} {eth_top_inst/eth_rx_inst/eth_rx_ctrl_inst/sByte_Ctrl_State[1]} {eth_top_inst/eth_rx_inst/eth_rx_ctrl_inst/sByte_Ctrl_State[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 2 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {eth_top_inst/eth_rx_inst/eth_rx_ctrl_inst/sRx_Ctrl_State[0]} {eth_top_inst/eth_rx_inst/eth_rx_ctrl_inst/sRx_Ctrl_State[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 4 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State_d1[0]} {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State_d1[1]} {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State_d1[2]} {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State_d1[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 10 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {eth_top_inst/wEth_Byte_Tx[0]} {eth_top_inst/wEth_Byte_Tx[1]} {eth_top_inst/wEth_Byte_Tx[2]} {eth_top_inst/wEth_Byte_Tx[3]} {eth_top_inst/wEth_Byte_Tx[4]} {eth_top_inst/wEth_Byte_Tx[5]} {eth_top_inst/wEth_Byte_Tx[6]} {eth_top_inst/wEth_Byte_Tx[7]} {eth_top_inst/wEth_Byte_Tx[8]} {eth_top_inst/wEth_Byte_Tx[9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 4 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State[0]} {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State[1]} {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State[2]} {eth_top_inst/eth_tx_inst/sTx_Ctrl_FSM_State[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 10 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {eth_top_inst/wEth_Byte_Rx[0]} {eth_top_inst/wEth_Byte_Rx[1]} {eth_top_inst/wEth_Byte_Rx[2]} {eth_top_inst/wEth_Byte_Rx[3]} {eth_top_inst/wEth_Byte_Rx[4]} {eth_top_inst/wEth_Byte_Rx[5]} {eth_top_inst/wEth_Byte_Rx[6]} {eth_top_inst/wEth_Byte_Rx[7]} {eth_top_inst/wEth_Byte_Rx[8]} {eth_top_inst/wEth_Byte_Rx[9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 10 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[0]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[1]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[2]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[3]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[4]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[5]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[6]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[7]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[8]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rByte_Cnt[9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 10 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[0]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[1]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[2]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[3]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[4]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[5]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[6]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[7]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[8]} {eth_top_inst/eth_tx_inst/eth_tx_ctrl_inst/rTx_Ctrl_Cnt[9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 2 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {eth_top_inst/Rxd[0]} {eth_top_inst/Rxd[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 2 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {eth_top_inst/Txd[0]} {eth_top_inst/Txd[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list eth_top_inst/Crs_Dv]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list eth_top_inst/eth_tx_inst/rEOP]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list eth_top_inst/eth_tx_inst/tx_buf_full]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list eth_top_inst/Tx_En]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list eth_top_inst/wEth_Byte_Valid_Rx]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list eth_top_inst/wEth_Byte_Valid_Tx]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list eth_top_inst/eth_rx_inst/wFifo_Empty]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list eth_top_inst/eth_tx_inst/wFifo_Rd_Valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list eth_top_inst/eth_rx_inst/wPkt_Invalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list eth_top_inst/eth_rx_inst/wSOP_Out]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets Eth_Clk_IBUF_BUFG]
