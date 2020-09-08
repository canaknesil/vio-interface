refresh_hw_vio [get_hw_vios -of_objects [get_hw_devices xc7a100t_0] -filter {CELL_NAME=~"vio_dummy_aes"}]
get_property INPUT_VALUE [get_hw_probes aes_ct_2 -of_objects [get_hw_vios -of_objects [get_hw_devices xc7a100t_0] -filter {CELL_NAME=~"vio_dummy_aes"}]]
