# https://www.01signal.com/constraints/

#====================================================================
# Clock Constraints
#====================================================================

# Input Eth Clock
create_clock -name eth_clk -period 20.0 [get_ports { Eth_Clk }];

# Output MDC Clock
create_generated_clock -name mdc_clk \
                        -source [get_pins eth_top_inst/clk_rst_mgr_inst/CLK] \
                        -divide_by 100 \
                        [get_pins eth_top_inst/MDC_Clk_OBUF]

#====================================================================
# I/O Delay Constraints
#====================================================================
set trce_dly_max  1.000;  # Maximum board trace delay
set trce_dly_min  0.000;  # Minimum board trace delay

# RMII (TX) (REF_CLK OUT MODE)
set tsu           7.000;  # Destination device setup time requirement
set thd           2.000;  # Destination device hold time requirement
set_output_delay -clock eth_clk -max [expr $trce_dly_max + $tsu] [get_ports {Txd[*]}];
set_output_delay -clock eth_clk -min [expr $trce_dly_min - $thd] [get_ports {Txd[*]}];

# RMII (RX) (REF_CLK OUT MODE)
set tco_max       5.000;  # Maximum delay after reference clock edge for external device's output to be valid
set tco_min       1.400;  # Minimum time required for signal to remain stable after clock edge
set_input_delay -clock eth_clk -max [expr $tco_max + $trce_dly_max] [get_ports {Rxd[*]}];
set_input_delay -clock eth_clk -min [expr $tco_min + $trce_dly_min] [get_ports {Rxd[*]}];

# TODO: constrain TX_EN

# Serial Management Interface (SMI)
set tsu           10.0;   # Destination device setup time requirement
set thd           10.0;   # Destination device hold time requirement
set tco_min       0.000;  # Minimum clock to out delay (external device)
set_output_delay -clock mdc_clk -max [expr $trce_dly_max + $tsu] [get_ports MDIO];
set_output_delay -clock mdc_clk -min [expr $trce_dly_min - $thd] [get_ports MDIO];
set_input_delay -clock mdc_clk -min [expr $tco_min + $trce_dly_min] [get_ports MDIO];
