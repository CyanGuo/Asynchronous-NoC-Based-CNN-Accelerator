// Copyright (C), 2022, Yuqing Guo

`timescale 1ns/100ps
import SystemVerilogCSP::*;

module pe_logic (
          interface filter_in, 
          interface filter_addr, 
          interface ifmap_in, 
          interface ifmap_addr, 
          interface psum_in, 
          interface start, 
          interface done, 
          interface psum_out
          );

  parameter WIDTH = 8;
  parameter DEPTH_I = 5;
  parameter DEPTH_F = 3;

  Channel #(.hsProtocol(P4PhaseBD), .WIDTH(10)) intf  [20:0] (); 

  memory #(.FL(2), .BL(2)) filter_mem (.DATA_IN(filter_in), .ADDR_IN(filter_addr), .ADDR_OUT(intf[0]), .DATA_OUT(intf[1]));
  memory #(.FL(2), .BL(2)) ifmap_mem (.DATA_IN(ifmap_in), .ADDR_IN(ifmap_addr), .ADDR_OUT(intf[2]), .DATA_OUT(intf[3]));
  multiplier #(.FL(2), .BL(2)) mul0 (.L1(intf[1]), .L2(intf[3]), .R(intf[4]));
  pe_adder #(.FL(2), .BL(2)) pe_adder0 (.A1(psum_in), .A0(intf[4]), .B0(intf[5]), .SEL(intf[7]), .R(intf[6])); //result 6 to split
  split #(.FL(2), .BL(2)) sp0 (.L(intf[6]), .S(intf[8]), .R1(intf[10]), .R2(psum_out)); // 10 back to acc or output to psum_out
  accumulator #(.FL(2), .BL(2)) acc0 (.IN(intf[10]), .OUT(intf[5]), .ACC_CLEAR(intf[9])); // out 5 to adder.b0

  control #(.FL(2), .BL(2)) ctrl0 (.S(start), .D(done), .filter_out_addr(intf[0]), .ifmap_out_addr(intf[2]), .add_sel(intf[7]), .split_sel(intf[8]), .clear_acc(intf[9]));
endmodule

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
      //$display("clear_acc %d at %t", clear, $realtime);
      if (clear == 1) begin
        
        OUT.Send(0);
        #BL; 
      end

      else begin
        IN.Receive(data);
        //$display("accum receive %d at %t", data, $realtime);
        #FL;
        
        OUT.Send(data);
        //$display("accum sent %d at %t", data, $realtime);
        #BL;        
      end

  end

endmodule

module memory(interface DATA_IN, interface ADDR_IN, interface ADDR_OUT, interface DATA_OUT);
  parameter FL = 4;
  parameter BL = 2;
  parameter WIDTH = 8;
  parameter DEPTH = 8;
  parameter ADDR = 2;
  logic [WIDTH-1:0] memoryarray [DEPTH-1:0];
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
        //$display("****** %m receive data %d in location %d at %t ", datain, addrin, $realtime);
        #FL;
      end

      begin // Read
        ADDR_OUT.Receive(addrout);
        DATA_OUT.Send(memoryarray[addrout]);
        //$display("%m sent data %d at %t ", memoryarray[addrout], $realtime);
        #BL;
      end

    join_any

  end

endmodule

module multiplier(interface L1, interface L2, interface R);
  parameter FL = 4;
  parameter BL = 2;
  parameter WIDTH = 8;
  logic [WIDTH-1:0] data1;
  logic [WIDTH-1:0] data2;
  logic [WIDTH+1:0] datao;

  always
  begin
    fork
      L1.Receive(data1);
      L2.Receive(data2);
    join
    //$display("mul received data at %t", $time);
    #FL;
    datao = data1 * data2;
    R.Send(datao);
    //$display("mul send result %d", datao);
    #BL;
  end
endmodule

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
      //$display("adder sent accum %d at %t", r_active, $realtime);
    end

    else if (select == 2'b10) begin
      fork
        A1.Receive(a1); 
        B0.Receive(b0);
      join
      #FL;
      r_inactive = a1 + b0;
      R.Send(r_inactive);
      //$display("adder sent psumout %d at %t", r_inactive, $realtime);
      #BL;
    end
  end
endmodule

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

module control(
              interface S, // start 1 or 0
              interface D, 
              interface filter_out_addr, 
              interface ifmap_out_addr, 
              interface add_sel,
              interface split_sel,
              interface clear_acc
              );

  parameter FL = 4;
  parameter BL = 2;
  parameter WIDTH = 8;
  parameter ifmap_length = 5;
  parameter filter_length = 3;
  logic start;
  logic [2:0] no_iterations = ifmap_length - filter_length; //2
  logic [WIDTH-1:0] i;
  logic [WIDTH-1:0] j;


  always
  begin

    S.Receive(start);
    #FL;
    if (start == 0) begin
      //$display("CONTROL START");
      for (i = 0; i <= no_iterations; i ++) 
      begin
        //#1;
        //$display("i = %d", i);
        clear_acc.Send(1);
        #FL;
        for (j = 0; j < filter_length; j ++) 
        begin
          //#1;
          //$display("j = %d", j);
          fork
            clear_acc.Send(0);
            split_sel.Send(2'b01);
            add_sel.Send(2'b01);
            filter_out_addr.Send(j);
            ifmap_out_addr.Send(i + j);
          join
          #BL;
          //$display("****** 5 control signals sent");
        end

        fork
          split_sel.Send(2'b10);
          add_sel.Send(2'b10);                   
        join
        //$display("start set add_sel & split_sel to 2'b10");
        #BL; 
      end
      D.Send(1);
      #BL;
    end
    
  end
endmodule