// Copyright (C), 2022, Yuqing Guo

`timescale 1ns/100ps
import SystemVerilogCSP::*;

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
      $display("CONTROL START");
      for (i = 0; i <= no_iterations; i ++) 
      begin
        #1;
        $display("i = %d", i);
        clear_acc.Send(1);
        #FL;
        for (j = 0; j < filter_length; j ++) 
        begin
          #1;
          $display("j = %d", j);
          fork
            clear_acc.Send(0);
            split_sel.Send(2'b01);
            add_sel.Send(2'b01);
            filter_out_addr.Send(j);
            ifmap_out_addr.Send(i + j);
          join
          #BL;
          $display("****** 5 control signals sent");
        end

        fork
          split_sel.Send(2'b10);
          add_sel.Send(2'b10);                   
        join
        $display("start set add_sel & split_sel to 2'b10");
        #BL; 
      end
      D.Send(1);
      #BL;
    end
    
  end
endmodule
