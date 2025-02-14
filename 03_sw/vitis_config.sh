#!/bin/bash

#--------------------------------------------------------------------
# simpleEthernet
# vitis_config.sh
# Script builds Vitis platform + application using .xsa file generated in Vivado
# 8/11/24
#--------------------------------------------------------------------

WORKSPACE_PATH="/tmp/wrk/workspace"
SRC_PATH="./src"
XSA_FILE="../02_build/proj_top.xsa"
MODE="gui"

rm -rf /tmp/wrk
xsct rebuild_sw.tcl $WORKSPACE_PATH $XSA_FILE $SRC_PATH
vitis -classic -workspace $WORKSPACE_PATH
