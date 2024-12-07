# ====================================================================
# Clock Constraints
# ====================================================================

# Input ETH Clock
create_clock -add -name Clk_Eth -period 20.0 [get_ports { Clk_Eth }];

# Output MDC Clock
create_generated_clock -name eth_top_inst/clk_rst_mgr_inst/Clk_MDC \
  -source [get_pins {eth_top_inst/clk_rst_mgr_inst/rClk_MDC_reg/C}] -divide_by 100 \
          [get_pins eth_top_inst/clk_rst_mgr_inst/rClk_MDC_reg/Q]


# create_clock -period 1000.000 -name VIRTUAL_eth_top_inst/clk_rst_mgr_inst/Clk_MDC_OBUF

# # ====================================================================
# # Input Delay Constraints
# # ====================================================================
# set_input_delay -clock [get_clocks VIRTUAL_eth_top_inst/clk_rst_mgr_inst/Clk_MDC_OBUF] -min 0.000 [get_ports MDIO]
# set_input_delay -clock [get_clocks VIRTUAL_eth_top_inst/clk_rst_mgr_inst/Clk_MDC_OBUF] -max 200.000 [get_ports MDIO]

# # ====================================================================
# # Output Delay Constraints
# # ====================================================================
# set_output_delay -clock [get_clocks VIRTUAL_eth_top_inst/clk_rst_mgr_inst/Clk_MDC_OBUF] -min -10.000 [get_ports MDIO]
# set_output_delay -clock [get_clocks VIRTUAL_eth_top_inst/clk_rst_mgr_inst/Clk_MDC_OBUF] -max 10.000 [get_ports MDIO]