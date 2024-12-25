SIM = verilator
TOPLEVEL_LANG = verilog
GTKWAVE = gtkwave

VERILOG_INCLUDE_DIR = $(PWD)/../../00_source/src/eth_tx
VERILOG_SOURCE_DIR = $(PWD)/../../00_source/src/eth_tx
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/eth_tx_pkg.vh
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/eth_tx_ctrl.v
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/eth_tx.v
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/crc_gen.v
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/sync_reset_fifo.v

VERILATOR_FLAGS = -j 0 -Wall -I$(VERILOG_INCLUDE_DIR)
COMPILE_ARGS += $(VERILATOR_FLAGS)
EXTRA_ARGS += --trace --trace-structs

include $(shell cocotb-config --makefiles)/Makefile.sim

build:
	echo "Building the project..."

run: clean
	$(MAKE) TOPLEVEL=eth_tx MODULE=tb_eth_tx

wave: run
	$(GTKWAVE) dump.vcd $(CURDIR)/eth_tx.gtkw
