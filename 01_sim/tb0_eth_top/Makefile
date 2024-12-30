SIM = verilator
TOPLEVEL_LANG = verilog
GTKWAVE = gtkwave

VERILOG_SOURCE_DIR = $(PWD)/../../00_source/src/
VERILOG_COMMON_DIR = $(PWD)/../../00_source/src/common
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/eth_tx/eth_tx_pkg.vh
VERILOG_SOURCES += $(wildcard $(VERILOG_SOURCE_DIR)/**/*.vh)
VERILOG_SOURCES += $(wildcard $(VERILOG_SOURCE_DIR)/**/**/*.vh)
VERILOG_SOURCES += $(wildcard $(VERILOG_SOURCE_DIR)/**/*.v)
VERILOG_SOURCES += $(wildcard $(VERILOG_SOURCE_DIR)/**/**/*.v)

#VERILATOR_FLAGS = -j 0 -Wall -I$(VERILOG_SOURCE_DIR)
VERILATOR_FLAGS = -j 0 -I$(wildcard $(VERILOG_SOURCE_DIR)) -I$(VERILOG_COMMON_DIR)
COMPILE_ARGS += $(VERILATOR_FLAGS)
EXTRA_ARGS += --trace --trace-structs

include $(shell cocotb-config --makefiles)/Makefile.sim

build:
	echo "Building the project..."

run: clean
	$(MAKE) TOPLEVEL=eth_top MODULE=tb_eth_top

wave: run
	$(GTKWAVE) dump.vcd $(CURDIR)/eth_top.gtkw
