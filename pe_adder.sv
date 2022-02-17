// pe_adder module
// Copyright (C), 2022, Yuqing Guo

`timescale 1ns/100ps
import SystemVerilogCSP::*;

module pe_adder(interface A0, interface A1, interface B0, interface SEL, interface R);
  parameter FL = 4;
  parameter BL = 2;
  parameter WIDTH = 8;
  logic [WIDTH-1:0] a0;
  logic [WIDTH-1:0] a1;
  logic [WIDTH-1:0] b0;
  logic [1:0] select;
  logic [WIDTH + 1:0] r_active;
  logic [WIDTH + 1:0] r_inactive;

  always
  begin
    SEL.Receive(select);

    if (select == 2'b01) begin
      fork
        A0.Receive(a0); 
        B0.Receive(b0);
      join
      #FL;
      r_active = a0 + b0;
      R.Send(r_active);
      $display("adder sent accum %d at %t", r_active, $realtime);
    end

    else if (select == 2'b10) begin
      fork
        A1.Receive(a1); 
        B0.Receive(b0);
      join
      #FL;
      r_inactive = a1 + b0;
      R.Send(r_inactive);
      $display("adder sent psumout %d at %t", r_inactive, $realtime);
      #BL;
    end
  end
endmodule


/*
  always
  begin
    fork
      A0.Receive(a0); 
      A1.Receive(a1);
      B0.Receive(b0);
      SEL.Receive(select);
    join
    $display("pe_adder received");
    $display("pe_adder SEL = %d", select);
    #FL;
    r_inactive = a1 + b0;
    r_active = a0 + b0;
    if (select == 2'b01) begin
      R.Send(r_active);
      $display("adder sent accum %d at %t", r_active, $realtime);
    end
    else if (select == 2'b10) begin
      R.Send(r_inactive);
      $display("adder sent psumout %d at %t", r_inactive, $realtime);
    end
    #BL;
  end
*/