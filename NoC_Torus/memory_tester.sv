/* 

   Matt Conn
   connmatt@usc.edu
   
   Modified by
   Yuqing Guo
   yuqing.guo@usc.edu

*/

`timescale 1ns/1ps
import SystemVerilogCSP::*;

module memory_tester(); 

  Channel #(.hsProtocol(P4PhaseBD)) intf[9:0] (); 
  Channel #(.WIDTH(39), .hsProtocol(P4PhaseBD)) nocintf[2:0] (); 

  memory mem_DUT (.read(intf[1]), .write(intf[2]), .T(intf[3]), 
		.x(intf[4]), .y(intf[5]), .data_in(intf[6]), .data_out(intf[7]));

  
  sample_memory_wrapper smw_DUT (.toMemRead(intf[1]), .toMemWrite(intf[2]), .toMemT(intf[3]), 
	.toMemX(intf[4]), .toMemY(intf[5]), .toMemSendData(intf[6]), .fromMemGetData(intf[7]), 
	.toNOC(nocintf[0]), .fromNOC(nocintf[1]));  

	NoC DUT (.IN(nocintf[0]), .OUT(nocintf[1]));

  
initial begin 
    #15000;			

	$stop;

  end // initial block
endmodule