#!/bin/bash

#--------------------------------------------------------------------
# simpleEthernet
# proj_init.sh
# Handles project creation using .tcl generated in Vivado
# 2/14/25
#--------------------------------------------------------------------

# NOTE:
# when working with block diagrams, take the following actions for source control
# 1) update 00_source/src/bd_wrapper.v with most recent ports
# 2) associate the desired state of the project with a tcl script --> {write_project_tcl rebuild}
# 3) compare current full_build.tcl with rebuild.tcl and verify differences before accepting new version

# prompt user
echo "Select build mode:"
echo "1: Build in batch mode (no GUI)"
echo "2: Build with GUI"
read -p "Enter your choice (1 or 2): " choice

# monitor
if [ "$choice" == "1" ]; then
    rm rebuild.tcl
    rm -rf project_1
    vivado -nolog -nojournal -mode batch -source full_build.tcl
elif [ "$choice" == "2" ]; then
    rm rebuild.tcl
    rm -rf project_1
    vivado -nolog -nojournal -source full_build.tcl
else
    echo "Invalid choice. Re-run script w/ 1 or 2!"
    exit 1
fi

# add some extensions that allow us to run synthesis, implementation,
# bitstream, and export hardware

# add some extension that allows us to copy .ltx (debug) and .bit from project directory to top-level
# to be included with source control