// row_adder module
// Copyright (C), 2022, Yuqing Guo

`timescale 1ns/100ps
import SystemVerilogCSP::*;

module row_adder (interface r, interface pkt_out);
  parameter FL = 2;
  parameter BL = 2;
  parameter WIDTH = 39;
  parameter WIDTH_D = 8;
  parameter ROW = 2'b01;

  logic [WIDTH-1:0] data;
  logic [WIDTH_D-1:0] partial;
  logic [2:0] spike = 3'b000;
  logic [WIDTH-1:0] packet = 0;

  logic [WIDTH_D-1:0] sum1 = 0;  
  logic [WIDTH_D-1:0] sum2 = 0;
  logic [WIDTH_D-1:0] sum3 = 0;

  logic [1:0] i1 = 0;
  logic [1:0] i2 = 0;
  logic [1:0] i3 = 0;

  always begin
// packet 01_0001_0000_00101_00001110_00000101_00001000
//        38 36   35   28    23       15       7       0    
    r.Receive(data);
    //$display("Receive data = %b", data);
    partial = data[7:0];
    #FL;

    case(data[25:24])
      2'b01: begin
        sum1 = sum1 + partial; 
        i1 = i1 + 1;
      end
      2'b10: begin
        sum2 = sum2 + partial; 
        i2 = i2 + 1;
      end
      2'b11: begin
        sum3 = sum3 + partial; 
        i3 = i3 + 1;
      end
    endcase

    if (i1 == 3 && i2 == 3 && i3 == 3)
    begin
      $display("Receive Original sum1 = %d", sum1);
      $display("Receive Original sum2 = %d", sum2);
      $display("Receive Original sum3 = %d", sum3);

      if (sum1 >= 64) begin
        sum1 = sum1 - 64; 
        spike[2] = 1;
      end
      else spike[2] = 0;

      if (sum2 >= 64) begin
        sum2 = sum2 - 64; 
        spike[1] = 1;
      end
      else spike[1] = 0;

      if (sum3 >= 64) begin
        sum3 = sum3 - 64; 
        spike[0] = 1;
      end
      else spike[0] = 0;
      
      $display("Result1 = %d, spike1 = %b", sum1, spike[2]);
      $display("Result2 = %d, spike2 = %b", sum2, spike[1]);
      $display("Result3 = %d, spike3 = %b", sum3, spike[0]);
      i1 = 0;
      i2 = 0;
      i3 = 0;
      packet = {2'b11, 8'b0000_0000, ROW, spike, sum1, sum2, sum3};
      pkt_out.Send(packet);
      #BL;
    end
    
  end

endmodule
