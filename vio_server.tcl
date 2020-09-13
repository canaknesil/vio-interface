

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

proc vio_cmd_test {} {
    print_info "Test command received."
    return "Test successfull."
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
	if {[string match $line exit]} {
	    vio_answer $channel "1"
	    after idle "close $channel;set out 1"
	} elseif {[string match $line test]} {
	    set result [vio_cmd_test]
	    vio_answer $channel "1$result"
	} else {
	    vio_answer $channel "0"
	}
    }
}

#
# MAIN
#

# Read command line inputs
set port [lindex $argv 0]
if {$port == ""} {
    set port 33000
    print_info "Port is not specified, using $port."
} elseif {![string is integer $port]} {
    print_info "Provided port: $port"
    print_info "Port must be an integer, exiting."
    exit
}

# Start server
set vio_server [socket -server vio_server_open $port]
after 100 update
print_info "VIO server started."

# Close server
vwait out
close $vio_server
print_info "VIO server stopped."
