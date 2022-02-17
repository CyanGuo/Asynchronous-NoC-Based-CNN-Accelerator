// Copyright (C), 2022, Yuqing Guo

`timescale 1ns/100ps
import SystemVerilogCSP::*;

module memory(interface DATA_IN, interface ADDR_IN, interface ADDR_OUT, interface DATA_OUT);
  parameter FL = 4;
  parameter BL = 2;
  parameter WIDTH = 8;
  parameter DEPTH = 8;
  parameter ADDR = 2;
  logic [WIDTH-1:0] memoryarray [DEPTH:0];
  logic [WIDTH-1:0] datain;
  logic [WIDTH-1:0] addrin;
  logic [WIDTH-1:0] addrout;

  always
  begin

    fork

      begin // Write
        ADDR_IN.Receive(addrin);
        DATA_IN.Receive(datain);
        memoryarray[addrin] = datain;
        $display("****** %m receive data %d in location %d at %t ", datain, addrin, $realtime);
        #FL;
      end

      begin // Read
        ADDR_OUT.Receive(addrout);
        DATA_OUT.Send(memoryarray[addrout]);
        $display("%m sent data %d at %t ", memoryarray[addrout], $realtime);
        #BL;
      end

    join_any

  end

  



endmodule