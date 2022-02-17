/* 
   pe_tb.sv
   Moises Herrera
   herrerab@usc.edu
*/

`timescale 1ns/100ps

import SystemVerilogCSP::*;

//pe testbench
module pe_tb(interface filter_in, interface filter_addr, interface ifmap_in, interface ifmap_addr, interface psum_in, interface start, interface done, interface psum_out);

 parameter WIDTH = 8;
 parameter DEPTH_I = 5;
 parameter ADDR_I = 3; 
 parameter DEPTH_F = 3;
 parameter ADDR_F = 2;
 
 logic d;
 logic [(WIDTH/2)-1:0] data_ifmap, data_filter;
 logic [ADDR_F-1:0] addr_filter = 0;
 logic [ADDR_I-1:0] addr_ifmap = 0;
 logic [WIDTH-1:0] psum_o;
 integer fpo, fpi_f, fpi_i, status, don_e = 0;
 
// watchdog timer
 initial begin
 #1000;
 $display("*** Stopped by watchdog timer ***");
 $stop;
 end
 
// main execution
 initial begin
// loading memories
   fpi_f = $fopen("filter.txt","r");
   fpi_i = $fopen("ifmap.txt","r");
   fpo = $fopen("pe_tb.dump");
   if(!fpi_f || !fpi_i)
   begin
       $display("A file cannot be opened!");
       $stop;
   end
	   for(integer i=0; i<DEPTH_F; i++) begin
	    if(!$feof(fpi_f)) begin
	     status = $fscanf(fpi_f,"%d\n", data_filter);
	     $display("fpf data read:%d", data_filter);
	     filter_addr.Send(addr_filter);
	     filter_in.Send(data_filter); 
	     $display("filter memory: mem[%d]= %d",addr_filter,data_filter);
	     addr_filter++;
	     $display("addr_filter=%d",addr_filter);
	   end end
	   
	   for(integer i=0; i<DEPTH_I; i++) begin
	    if (!$feof(fpi_i)) begin
	     status = $fscanf(fpi_i,"%d\n", data_ifmap);
	     $display("fpi data read:%d", data_ifmap);
	     ifmap_addr.Send(addr_ifmap);
	     ifmap_in.Send(data_ifmap); 
	     $display("ifmap memory: mem[%d]= %d",addr_ifmap, data_ifmap);
	     addr_ifmap++;
	   end end
	   
// starting control
  start.Send(0); 
  
// waiting for psum_out values
 for(integer i=0; i<DEPTH_F; i++) begin
  psum_out.Receive(psum_o);
  $fdisplay(fpo,"psum_out O1%d: %d",i+1,psum_o); 
  $display("%m psum O1%0d: %d received at %t",i, psum_o, $time);
 end
// waiting for done
  done.Receive(don_e);
  $display("%m done received. ending simulation at %t",$time);
  $stop;
 end
 
// psum_in DG
 always begin
  psum_in.Send(0);
  $display("psum_in sent 0");
 end
endmodule

//testbench
module testbench;
 Channel #(.hsProtocol(P4PhaseBD), .WIDTH(10)) intf [7:0] (); 

 parameter WIDTH = 8;
 parameter DEPTH_I = 5;
 parameter ADDR_I = 3; 
 parameter DEPTH_F = 3;
 parameter ADDR_F = 2;
 
//pe_tb
pe_tb #(.WIDTH(WIDTH), .DEPTH_I(DEPTH_I), .ADDR_I(ADDR_I), .DEPTH_F(DEPTH_F), .ADDR_F(ADDR_F))
petb(.filter_in(intf[7]), .filter_addr(intf[6]), .ifmap_in(intf[5]),
  .ifmap_addr(intf[4]), .psum_in(intf[3]), .start(intf[0]), .done(intf[1]), .psum_out(intf[2]));

//DUT (pe)
 pe_convolution_1d #(.WIDTH(WIDTH), .DEPTH_I(DEPTH_I), .ADDR_I(ADDR_I), .DEPTH_F(DEPTH_F), .ADDR_F(ADDR_F))
 pe_i(.filter_in(intf[7]), .filter_addr(intf[6]), .ifmap_in(intf[5]),
  .ifmap_addr(intf[4]), .psum_in(intf[3]), .start(intf[0]), .done(intf[1]), .psum_out(intf[2]));
 
endmodule
 

