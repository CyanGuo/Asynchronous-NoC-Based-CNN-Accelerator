//Split Module
//Copyright @ Yuqing Guo 2022

`timescale 1ns/1ns
//NOTE: you need to compile SystemVerilogCSP.sv as well
import SystemVerilogCSP::*;

// split module
module split (interface L, interface S, interface R1, interface R2);
  parameter FL = 4;
  parameter BL = 2;
  parameter WIDTH = 8;
  logic [WIDTH - 1:0] data;
  logic [1:0] sel;

  always
  begin
    fork
      S.Receive(sel);
      L.Receive(data);
    join
    //$display("split received and sel = %d", sel);
    #FL;

    if(sel == 2'b01)
    begin
        R1.Send(data);
        //$display("split sent data when sel = 1");
        #BL;       
    end
    else if(sel == 2'b10)
    begin
        R2.Send(data);
        //$display("split sent data when sel = 2");
        #BL;
    end
  end
endmodule

