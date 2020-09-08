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
