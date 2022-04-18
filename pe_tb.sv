//pe_tb
//Copyright @ Yuqing Guo 2022

`timescale 1ns/1ns
//NOTE: you need to compile SystemVerilogCSP.sv as well
import SystemVerilogCSP::*;


module data_generator (interface r);
  parameter WIDTH = 39;
  parameter FL = 0; //ideal environment
  logic [WIDTH-1:0] SendValue=0;

  initial
  begin
    SendValue = 39'b01_0001_0000_11101_00001110_00000101_00001000;
    #FL;
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

    r.Receive(ReceiveValue);
    $display("ReceiveValue = %b", ReceiveValue);
    r.Receive(ReceiveValue);
    $display("ReceiveValue = %b", ReceiveValue);
    r.Receive(ReceiveValue);
    $display("ReceiveValue = %b", ReceiveValue);

    $stop;

  end

endmodule

//top level module instantiating data_generator, reciever, and the interface
module pe_tb;

  Channel #(.WIDTH(39), .hsProtocol(P4PhaseBD)) intf  [1:0] (); 
  
  //instantiating the test circuit
  
  data_generator  #(.WIDTH(39)) dg(intf[0]);
  pe_top PE (intf[0], intf[1]);
  data_bucket #(.WIDTH(39)) db(intf[1]);

endmodule
