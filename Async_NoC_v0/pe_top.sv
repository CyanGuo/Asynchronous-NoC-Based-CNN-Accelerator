`timescale 1ns/100ps

import SystemVerilogCSP::*;

//pe_control
module pe_control(
              interface pkt_in, 
              interface pkt_out, 
              interface filter_in, 
              interface filter_addr, 
              interface ifmap_in, 
              interface ifmap_addr, 
              interface psum_in, 
              interface start, 
              interface done, 
              interface psum_out);

 parameter WIDTH = 39;
 parameter WIDTH_I = 1;
 parameter WIDTH_F = 8;
 
 parameter DEPTH_I = 5;
 parameter DEPTH_F = 3;

 parameter FL = 2;
 parameter BL = 2;

 parameter ADDR_F = 2;
 parameter ADDR_I = 3;

 parameter TARGET_ADDR = 8'b0000_0000;
 parameter OUT_ROW = 2'b01;
 
 logic [WIDTH-1:0] packet_in, packet_out;
 logic [WIDTH_I-1:0] data_ifmap [DEPTH_I-1:0]; 
 logic [WIDTH_F-1:0] data_filter [DEPTH_F-1:0];

 logic [ADDR_F-1:0] addr_filter = 0;
 logic [ADDR_I-1:0] addr_ifmap = 0;

 logic [7:0] psum_o;
 logic don_e = 0; 
 logic [3:0] i = 0;
 logic [1:0] col;
// main execution

always 
begin
// packet 01_0001_0000_11101_00001110_00000101_00001000
//        38 36   35   28    23       15       7       0
  pkt_in.Receive(packet_in);
  #FL;
  data_filter [0] = packet_in [23:16];
  data_filter [1] = packet_in [15:8];
  data_filter [2] = packet_in [7:0];
  data_ifmap [0] = packet_in [28];
  data_ifmap [1] = packet_in [27];
  data_ifmap [2] = packet_in [26];
  data_ifmap [3] = packet_in [25];
  data_ifmap [4] = packet_in [24];
  #FL;

// loading memories  
  for (i = 0; i < DEPTH_F; i ++) begin
    filter_addr.Send(addr_filter);
    filter_in.Send(data_filter[i]); 
    $display("filter memory: mem[%d]= %d", addr_filter, data_filter[i]);
    addr_filter ++;
    #BL;
  end
	   
	for (i = 0; i < DEPTH_I; i ++) begin
	  ifmap_addr.Send(addr_ifmap);
	  ifmap_in.Send(data_ifmap[i]); 
	  $display("ifmap memory: mem[%d]= %d",addr_ifmap, data_ifmap[i]);
	  addr_ifmap ++;
    #BL;
	end
	   
// starting control
  start.Send(0); 
  //$display("START");

// waiting for psum_out values
  for (i = 0; i < DEPTH_F; i ++) begin
    psum_out.Receive(psum_o);
    $display("%m psum %0d: %d received at %t",i, psum_o, $time);
    #FL;
    // packet_out generating
    col = i + 1;
    packet_out [38:37] = 2'b10;
    packet_out [36:29] = TARGET_ADDR;
    packet_out [28:24] = {1'b0, OUT_ROW, col};
    packet_out [23:16] = 8'b0000_0000;
    packet_out [15:8]  = 8'b0000_0000;
    packet_out [7:0]   = psum_o;

    // pkt_out sending
    pkt_out.Send(packet_out);
    //$display("Sent pkt at %t",$time);
    #BL;
  end



// waiting for done
  done.Receive(don_e);
  //$display("%m done received. ending pe at %t",$time);
  addr_filter = 0;
  addr_ifmap = 0;
 end
 
// psum_in DG
always 
begin
 psum_in.Send(0);
end

endmodule

// pe_top
module pe_top (interface pkt_in, interface pkt_out);

 Channel #(.hsProtocol(P4PhaseBD), .WIDTH(8)) intf [7:0] (); 

 parameter WIDTH = 39;
 parameter DEPTH_I = 5; 
 parameter DEPTH_F = 3;
 parameter TARGET_ADDR = 8'b0000_0100;
 parameter OUT_ROW = 2'b01;
 
//pe_tb
  pe_control #(.WIDTH(WIDTH), .DEPTH_I(DEPTH_I), .DEPTH_F(DEPTH_F), .TARGET_ADDR(TARGET_ADDR), .OUT_ROW(OUT_ROW))
  pe_control (.pkt_in(pkt_in), .pkt_out(pkt_out),
              .filter_in(intf[7]), .filter_addr(intf[6]), .ifmap_in(intf[5]), .ifmap_addr(intf[4]),
              .psum_in(intf[3]), .start(intf[0]), .done(intf[1]), .psum_out(intf[2]));

//DUT (pe)
  pe_logic #(.WIDTH(WIDTH), .DEPTH_I(DEPTH_I), .DEPTH_F(DEPTH_F))
  pe_i (.filter_in(intf[7]), .filter_addr(intf[6]), .ifmap_in(intf[5]), .ifmap_addr(intf[4]), 
        .psum_in(intf[3]), .start(intf[0]), .done(intf[1]), .psum_out(intf[2]));
 
endmodule
 

