#!/bin/bash

##############################################################
# vitis_config.sh
# 8/11/24
# Script builds Vitis platform + application using .xsa file
# generated in Vivado
##############################################################

# running tcl scripts (using xsct): https://docs.amd.com/r/en-US/ug1400-vitis-embedded/Running-Tcl-Scripts
# Vitis launch options:             https://docs.amd.com/r/en-US/ug1400-vitis-embedded/Vitis-Unified-IDE-Launch-Options
# Vitis automation examples:        https://docs.amd.com/r/en-US/ug1400-vitis-embedded/Common-Use-Cases
# Vitis XSCT commands:              https://docs.amd.com/r/en-US/ug1400-vitis-embedded/Vitis-Projects

WORKSPACE_PATH="/tmp/wrk/workspace"
SRC_PATH="./src"
XSA_FILE="../02_build/eth.xsa"
MODE="gui"

rm -rf /tmp/wrk
xsct rebuild_sw.tcl $WORKSPACE_PATH $XSA_FILE $SRC_PATH
vitis -classic -workspace $WORKSPACE_PATH

# next: expand to include options to build project after modifying source code
