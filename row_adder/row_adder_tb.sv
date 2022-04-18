//row_adder_tb
//Copyright @ Yuqing Guo 2022

`timescale 1ns/1ns
//NOTE: you need to compile SystemVerilogCSP.sv as well
import SystemVerilogCSP::*;


module data_generator (interface r);
  parameter WIDTH = 39;
  parameter FL = 0; //ideal environment
  logic [WIDTH-1:0] SendValue;

  initial
  begin
    #FL;
    SendValue = 39'b01_0001_0000_11101_00001110_00000101_00001000;
    r.Send(SendValue);
    $display("SendValue = %b", SendValue);
    SendValue = 39'b01_0001_0000_01110_00000100_00001000_00000111;
    r.Send(SendValue);
    $display("SendValue = %b", SendValue);
    SendValue = 39'b01_0001_0000_10111_00001010_00001001_00001010;
    r.Send(SendValue);
    $display("SendValue = %b", SendValue);
  end
endmodule


module data_bucket (interface r);
  parameter WIDTH = 39;
  parameter BL = 0; //ideal environment
  logic [WIDTH-1:0] ReceiveValue = 0;

  always
  begin
// packet 01_0001_0000_00101_00001110_00000101_00001000
//        38 36   35   28    23       15       7       0    
    r.Receive(ReceiveValue);
    #BL;
    
    $display("ReceiveValue = %b", ReceiveValue);
    $display("Result1 = %d, spike1 = %b", ReceiveValue[23:16], ReceiveValue[26]);
    $display("Result2 = %d, spike2 = %b", ReceiveValue[15:8], ReceiveValue[25]);
    $display("Result3 = %d, spike3 = %b", ReceiveValue[7:0], ReceiveValue[24]);

    $stop;

  end

endmodule

//top level module instantiating data_generator, reciever, and the interface
module row_adder_tb;

  Channel #(.WIDTH(39), .hsProtocol(P4PhaseBD)) intf  [5:0] (); 
  
  //instantiating the test circuit
  
  data_generator  #(.WIDTH(39), .FL(0)) dg (intf[0]);
  pe_top pe0 (intf[0], intf[2]);
  row_adder ra (intf[2], intf[3]);
  data_bucket #(.WIDTH(39)) db(intf[3]);

endmodule
