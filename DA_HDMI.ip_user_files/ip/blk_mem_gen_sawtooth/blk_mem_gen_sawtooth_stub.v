// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Fri Feb 18 18:06:25 2022
// Host        : DESKTOP-K1F7J3C running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/BaiduNetdiskDownload/DA_HDMI/DA_HDMI.srcs/sources_1/ip/blk_mem_gen_sawtooth/blk_mem_gen_sawtooth_stub.v
// Design      : blk_mem_gen_sawtooth
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tfgg484-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3" *)
module blk_mem_gen_sawtooth(clka, addra, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,addra[8:0],douta[7:0]" */;
  input clka;
  input [8:0]addra;
  output [7:0]douta;
endmodule
