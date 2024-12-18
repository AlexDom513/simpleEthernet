# ====================================================================
# Clock Constraints
# ====================================================================

# Input ETH Clock
create_clock -add -name sysclk -period 20.0 [get_ports { Clk }];
