##############################################################
# rebuild_sw.tcl
# 8/11/24
##############################################################

# Check the number of arguments
if { $argc < 1 } {
  puts "Usage: rebuild_sw.tcl <arg1> <arg2> ..."
  exit 1
}

# set workspace (local to machine)
setws [lindex $argv 0]

# create platform/domain
platform create -name sw_platform -hw [lindex $argv 1]
domain create -name sw_domain -os standalone -proc ps7_cortexa9_0
domain active sw_domain
platform generate

# create application
app create -name sw_app -platform sw_platform -template "Empty Application(C)" -lang c
importsources -name sw_app -path [lindex $argv 2]
app build -name sw_app
