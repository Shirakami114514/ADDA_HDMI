vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 -incr \
"../../../../DA_HDMI.srcs/sources_1/ip/blk_mem_gen_sawtooth/sim/blk_mem_gen_sawtooth.v" \


vlog -work xil_defaultlib \
"glbl.v"

