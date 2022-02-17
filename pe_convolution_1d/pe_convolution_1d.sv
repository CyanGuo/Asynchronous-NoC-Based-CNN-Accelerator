// Copyright (C), 2022, Yuqing Guo

`timescale 1ns/100ps
import SystemVerilogCSP::*;

module pe_convolution_1d (
          interface filter_in, 
          interface filter_addr, 
          interface ifmap_in, 
          interface ifmap_addr, 
          interface psum_in, 
          interface start, 
          interface done, 
          interface psum_out
          );

  parameter WIDTH = 8;
  parameter DEPTH_I = 5;
  parameter ADDR_I = 3; 
  parameter DEPTH_F = 3;
  parameter ADDR_F = 2;

  Channel #(.hsProtocol(P4PhaseBD), .WIDTH(10)) intf  [20:0] (); 

  memory #(.FL(5), .BL(8)) filter_mem (.DATA_IN(filter_in), .ADDR_IN(filter_addr), .ADDR_OUT(intf[0]), .DATA_OUT(intf[1]));
  memory #(.FL(5), .BL(8)) ifmap_mem (.DATA_IN(ifmap_in), .ADDR_IN(ifmap_addr), .ADDR_OUT(intf[2]), .DATA_OUT(intf[3]));
  multiplier #(.FL(5), .BL(8)) mul0 (.L1(intf[1]), .L2(intf[3]), .R(intf[4]));
  pe_adder #(.FL(5), .BL(8)) pe_adder0 (.A1(psum_in), .A0(intf[4]), .B0(intf[5]), .SEL(intf[7]), .R(intf[6])); //result 6 to split
  split #(.FL(5), .BL(8)) sp0 (.L(intf[6]), .S(intf[8]), .R1(intf[10]), .R2(psum_out)); // 10 back to acc or output to psum_out
  accumulator #(.FL(5), .BL(8)) acc0 (.IN(intf[10]), .OUT(intf[5]), .ACC_CLEAR(intf[9])); // out 5 to adder.b0

  control #(.FL(5), .BL(8)) ctrl0 (.S(start), .D(done), .filter_out_addr(intf[0]), .ifmap_out_addr(intf[2]), .add_sel(intf[7]), .split_sel(intf[8]), .clear_acc(intf[9]));
endmodule
