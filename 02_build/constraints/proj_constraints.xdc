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
# Input Delay Constraints
#====================================================================
# set_input_delay -clock [get_clocks VIRTUAL_eth_top_inst/clk_rst_mgr_inst/Clk_MDC_OBUF] -min 0.000 [get_ports MDIO]
# set_input_delay -clock [get_clocks VIRTUAL_eth_top_inst/clk_rst_mgr_inst/Clk_MDC_OBUF] -max 200.000 [get_ports MDIO]

#====================================================================
# Output Delay Constraints
#====================================================================
# set_output_delay -clock [get_clocks VIRTUAL_eth_top_inst/clk_rst_mgr_inst/Clk_MDC_OBUF] -min -10.000 [get_ports MDIO]
# set_output_delay -clock [get_clocks VIRTUAL_eth_top_inst/clk_rst_mgr_inst/Clk_MDC_OBUF] -max 10.000 [get_ports MDIO]