// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Fri Aug 16 13:04:01 2024
// Host        : LAPTOP-476JT8H0 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top mult_gen_0 -prefix
//               mult_gen_0_ mult_gen_0_stub.v
// Design      : mult_gen_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "mult_gen_v12_0_16,Vivado 2019.2" *)
module mult_gen_0(A, B, P)
/* synthesis syn_black_box black_box_pad_pin="A[31:0],B[31:0],P[31:0]" */;
  input [31:0]A;
  input [31:0]B;
  output [31:0]P;
endmodule
