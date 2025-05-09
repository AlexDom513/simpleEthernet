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
