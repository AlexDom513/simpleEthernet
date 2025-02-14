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
set_clock_groups -asynchronous -group [get_clocks clk_fpga_0] -group [get_clocks eth_clk]

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
