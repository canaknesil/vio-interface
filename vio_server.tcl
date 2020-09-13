set mode test
#set mode vivado

#
# Utilities
#

proc print_info {msg} {
    puts "VIO Server Info: $msg"
    flush stdout
}

#
# VIO Server Commands
#

switch $mode {
    test {
	
	proc vio_cmd_test {} {
	    print_info "Test command received."
	    return "Test successfull."
	}
	proc vio_cmd_read {name} {
	    print_info "Read command received. Reading $name."
	    return "0"
	}
	proc vio_cmd_write {name value} {
	    print_info "Write command received. Writing $name $value."
	    return ""
	}
	
    }
    vivado {
	
	proc vio_cmd_test {} {
	    print_info "Test command received."
	    return "Test successfull."
	}
	proc vio_cmd_read {name} {
	    refresh_hw_vio [get_hw_vios -of_objects [get_hw_devices xc7a100t_0] -filter {CELL_NAME=~"vio_dummy_aes"}]
	    get_property INPUT_VALUE [get_hw_probes aes_ct_2 -of_objects [get_hw_vios -of_objects [get_hw_devices xc7a100t_0] -filter {CELL_NAME=~"vio_dummy_aes"}]]
	}
	proc vio_cmd_write {name value} {
	    set_property OUTPUT_VALUE 00000000000000000000000000000001 [get_hw_probes aes_pt_2 -of_objects [get_hw_vios -of_objects [get_hw_devices xc7a100t_0] -filter {CELL_NAME=~"vio_dummy_aes"}]]
	    commit_hw_vio [get_hw_probes {aes_pt_2} -of_objects [get_hw_vios -of_objects [get_hw_devices xc7a100t_0] -filter {CELL_NAME=~"vio_dummy_aes"}]]
	}
	
    }
}

#
# Server
#

proc vio_server_open {channel addr port} {
    print_info "VIO channel openning..."
    print_info "Channel: $channel"
    print_info "Address: $addr"
    print_info "Port   : $port"
    
    fileevent $channel readable "vio_read_command $channel"

    print_info "VIO channel openned."
}

proc vio_answer {channel msg} {
    puts $channel $msg
    flush $channel
}

proc vio_read_command {channel} {
    if { [gets $channel line] < 0} {
	print_info "Channel closed by client."
        fileevent $channel readable {}
    } else {
	set command [lindex $line 0]
	set parameters [lreplace $line 0 0]
	switch $command {
	    exit {
		vio_answer $channel "1"
		after idle "close $channel;set out 1"
	    }
	    test  {vio_answer $channel "1[vio_cmd_test  {*}$parameters]"}
	    read  {vio_answer $channel "1[vio_cmd_read  {*}$parameters]"}
	    write {vio_answer $channel "1[vio_cmd_write {*}$parameters]"}
	    default {vio_answer $channel "0"}
	}
    }
}

#
# MAIN
#

# Read command line inputs
set port [lindex $argv 0]
if {![string is integer $port]} {
    print_info "Provided port: $port"
    print_info "Port must be an integer, exiting."
    exit
}

# Prepare vivado
if {[string match $mode vivado]} {
    open_project /home/canaknesil/Documents/workspace/aes-vio_project/aes128_verilog.xpr
    #update_compile_order -fileset sources_1
    open_hw_manager
    connect_hw_server -allow_non_jtag
    open_hw_target
    set_property PROGRAM.FILE {/home/canaknesil/Documents/workspace/aes-vio_project/aes128_verilog.runs/impl_100t/cw305_top.bit} [get_hw_devices xc7a100t_0]
    set_property PROBES.FILE {/home/canaknesil/Documents/workspace/aes-vio_project/aes128_verilog.runs/impl_100t/cw305_top.ltx} [get_hw_devices xc7a100t_0]
    set_property FULL_PROBES.FILE {/home/canaknesil/Documents/workspace/aes-vio_project/aes128_verilog.runs/impl_100t/cw305_top.ltx} [get_hw_devices xc7a100t_0]
    current_hw_device [get_hw_devices xc7a100t_0]
    refresh_hw_device [lindex [get_hw_devices xc7a100t_0] 0]
}

# Start server
set vio_server [socket -server vio_server_open $port]
after 100 update
print_info "VIO server started."

# Close server
vwait out
close $vio_server
print_info "VIO server stopped."
