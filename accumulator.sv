// Copyright (C), 2022, Yuqing Guo

`timescale 1ns/100ps
import SystemVerilogCSP::*;

module accumulator(interface IN, interface OUT, interface ACC_CLEAR);
  parameter FL = 4;
  parameter BL = 2;
  parameter WIDTH = 8;
  logic clear;
  logic [WIDTH-1:0] data;

  //initial OUT.Send(0);

  always
  begin
    
      ACC_CLEAR.Receive(clear);
      $display("clear_acc %d at %t", clear, $realtime);
      if (clear == 1) begin
        
        OUT.Send(0);
        #BL; 
      end

      else begin
        IN.Receive(data);
        $display("accum receive %d at %t", data, $realtime);
        #FL;
        
        OUT.Send(data);
        $display("accum sent %d at %t", data, $realtime);
        #BL;        
      end

  end

endmodule