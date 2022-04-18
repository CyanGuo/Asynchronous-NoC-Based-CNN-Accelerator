`timescale 1ns/100ps

import SystemVerilogCSP::*;

module arbiter (interface R1, interface R2, interface S);
  parameter WIDTH = 8;
  logic [WIDTH-1:0] data;
  always begin
		forever begin
	    wait((R1.status != idle) || (R2.status != idle));
	    if ((R1.status != idle) && (R2.status != idle)) begin
	      if ({$random} % 2 == 0) begin    
          S.Send(1);         
          R1.Receive(data);
	      end
	      else  begin
          S.Send(2);
          R2.Receive(data);
	      end
	    end
	    else if (R1.status != idle) begin 
        S.Send(1);
        R1.Receive(data); 
	      end
	    else begin 
        S.Send(2);
        R2.Receive(data);
	    end
		end
  end
endmodule

module copy (interface L1, interface R1, interface R2);
  parameter FL = 4;
  parameter BL = 2;
  parameter WIDTH = 8;
  logic [WIDTH - 1 : 0] data;

  always
  begin
    L1.Receive(data);
    #FL;
    fork
      R1.Send(data);
      R2.Send(data);
    join
    #BL;
  end
endmodule

module merge (interface L1, interface L2, interface S, interface R);
  parameter FL = 2;
  parameter BL = 2;
  parameter WIDTH = 8;
  logic [WIDTH - 1:0] data;
  logic [1:0] sel;

  always
  begin
    S.Receive(sel);
    #FL;
    if(sel == 1)
    begin
        L1.Receive(data);
        #FL;
        R.Send(data);
        #BL;       
    end
    else if(sel == 2)
    begin
        L2.Receive(data);
        #FL;
        R.Send(data);
        #BL;
    end
  end
endmodule

module arbitermerge (interface A, interface B, interface out);
  parameter FL = 2;
  parameter BL = 4;
  parameter WIDTH = 39;
  Channel #(.WIDTH(39),.hsProtocol(P4PhaseBD)) intf [4:0] ();
  copy #(.WIDTH(39)) cp0 (.L1(A), .R1(intf[0]), .R2(intf[1]));
  copy #(.WIDTH(39)) cp1 (.L1(B), .R1(intf[2]), .R2(intf[3]));
  arbiter #(.WIDTH(39)) arb (.R1(intf[1]), .R2(intf[3]), .S(intf[4]));
  merge #(.WIDTH(39)) mer (.L1(intf[0]), .L2(intf[2]), .S(intf[4]), .R(out));
endmodule
