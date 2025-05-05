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

# NOTE: finding pins
#   - get_cells -hierarchical *rMDC_Clk_reg*                                            (rMDC was found in Netlist, command returns full path)
#   - get_pins -of_objects [get_cells -hierarchical rMDC_Clk_reg]                       (use the specific cell from previous command)
#   - get_pins -of_objects [get_cells -hierarchical rMDC_Clk_reg] -filter {NAME =~ */Q} (can filter for specific pins)

# NOTE: finding nets
#   - get_cells -hierarchical *rMDC_Clk_reg* 
#   - get_nets -of_objects [get_cells -hierarchical rMDC_Clk_reg] 

# Input Eth Clock
create_clock -period 20.000 -name Eth_Clk [get_ports Eth_Clk]

# Output MDC Clock (if not present Vivado CW - "* is not reachable by a timing clock")
create_generated_clock \
    -name MDC_Clk \
    -source [get_pins -hierarchical -filter {NAME =~ */C} *rMDC_Clk_reg*] \
    -divide_by 100 \
    [get_pins -hierarchical -filter {NAME =~ */Q} *rMDC_Clk_reg*]

# False-Path Reset Inputs
set_false_path -from [get_cells -hierarchical *rMDC_Rst_meta_reg*] \
    -to [get_cells -hierarchical *rMDC_Rst_reg*]

# (update to specific path)
set_clock_groups -asynchronous -group [get_clocks clk_fpga_0] \
    -group [get_clocks Eth_Clk]

set_false_path -from [get_cells -hierarchical *rEth_Rst_meta_reg*] \
    -to [get_cells -hierarchical *rEth_Rst_reg*]

#---------------------------------------------------------------------
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
set trce_dly_max    1.000;
set trce_dly_min    0.000;

#---------------------------------------------------------------------
# Input Delays:

# LAN8720A Datasheet: t_oval --> MIN: 0 ns, MAX 5 ns

# RMII (CRS_DV)
set tco_max 5.000
set tco_min 0.000
set_input_delay -clock Eth_Clk -max [expr $tco_max + $trce_dly_max] [get_ports Crs_Dv]
set_input_delay -clock Eth_Clk -min [expr $tco_min + $trce_dly_min] [get_ports Crs_Dv]

# RMII (RX)
set tco_max 5.000
set tco_min 0.000
set_input_delay -clock Eth_Clk -max [expr $tco_max + $trce_dly_max] [get_ports {Rxd[*]}]
set_input_delay -clock Eth_Clk -min [expr $tco_min + $trce_dly_min] [get_ports {Rxd[*]}]

# SMI (RX)
set tco_max 300.000
set tco_min 0.000
set_input_delay -clock MDC_Clk -max [expr $tco_max + $trce_dly_max] [get_ports MDIO]
set_input_delay -clock MDC_Clk -min [expr $tco_min + $trce_dly_min] [get_ports MDIO]

#---------------------------------------------------------------------
# Output Delays:

# RMII (TX_EN) (REF_CLK OUT MODE)
set tsu 4.000;
set thd 1.500;
set_output_delay -clock Eth_Clk -max [expr $trce_dly_max + $tsu] [get_ports Tx_En]
set_output_delay -clock Eth_Clk -min [expr $trce_dly_min - $thd] [get_ports Tx_En]

# RMII (TX)
set tsu 4.000;
set thd 1.500;
set_output_delay -clock Eth_Clk -max [expr $trce_dly_max + $tsu] [get_ports {Txd[*]}]
set_output_delay -clock Eth_Clk -min [expr $trce_dly_min - $thd] [get_ports {Txd[*]}]

# SMI (TX)
set tsu 10.000;
set thd 10.000;
set_output_delay -clock MDC_Clk -max [expr $trce_dly_max + $tsu] [get_ports MDIO]
set_output_delay -clock MDC_Clk -min [expr $trce_dly_min - $thd] [get_ports MDIO]
