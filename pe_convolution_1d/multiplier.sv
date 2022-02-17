// Copyright (C), 2022, Yuqing Guo

`timescale 1ns/100ps
import SystemVerilogCSP::*;

module multiplier(interface L1, interface L2, interface R);
  parameter FL = 4;
  parameter BL = 2;
  parameter WIDTH = 8;
  logic [WIDTH-1:0] data1;
  logic [WIDTH-1:0] data2;
  logic [WIDTH+1:0] datao;

  always
  begin
    fork
      L1.Receive(data1);
      L2.Receive(data2);
    join
    $display("mul received data at %t", $time);
    #FL;
    datao = data1 * data2;
    R.Send(datao);
    $display("mul send result %d", datao);
    #BL;
  end
endmodule
