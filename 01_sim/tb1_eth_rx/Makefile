SIM = verilator
TOPLEVEL_LANG = verilog
GTKWAVE = gtkwave

VERILOG_SOURCE_DIR = $(PWD)/../../00_source/src/eth_rx
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/eth_rx.v
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/eth_rx_ctrl.v
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/eth_crc_gen2.v

VERILATOR_FLAGS = -j 0 -Wall
COMPILE_ARGS += $(VERILATOR_FLAGS)
EXTRA_ARGS += --trace --trace-structs

include $(shell cocotb-config --makefiles)/Makefile.sim

build:
	echo "Building the project..."

run: clean
	$(MAKE) TOPLEVEL=eth_rx MODULE=tb_eth_rx

wave: run
	$(GTKWAVE) dump.fst $(CURDIR)/eth_rx.gtkw
