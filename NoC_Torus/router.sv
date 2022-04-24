`timescale 1ns/100ps

import SystemVerilogCSP::*;

module router (interface up_in, interface down_in, interface left_in, interface right_in, interface local_in,
               interface up_out, interface down_out, interface left_out, interface right_out, interface local_out);
  parameter WIDTH = 39;
  parameter X_LOCAL = 4'b0000;
  parameter Y_LOCAL = 4'b0001;

  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) upintf [3:0] ();
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) downintf [3:0] ();
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) leftintf [3:0] ();
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) rightintf [3:0] ();
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) localintf [3:0] ();

  up_switch     #(.WIDTH(WIDTH), .X_LOCAL(X_LOCAL), .Y_LOCAL(Y_LOCAL)) usw (.R(up_in), .toDown(downintf[0]), .toLeft(leftintf[0]), .toRight(rightintf[0]), .toLocal(localintf[0]));
  down_switch   #(.WIDTH(WIDTH), .X_LOCAL(X_LOCAL), .Y_LOCAL(Y_LOCAL)) dsw (.R(down_in), .toUp(upintf[0]), .toLeft(leftintf[1]), .toRight(rightintf[1]), .toLocal(localintf[1]));
  left_switch   #(.WIDTH(WIDTH), .X_LOCAL(X_LOCAL), .Y_LOCAL(Y_LOCAL)) lsw (.R(left_in), .toDown(downintf[1]), .toUp(upintf[1]), .toRight(rightintf[2]), .toLocal(localintf[2]));
  right_switch  #(.WIDTH(WIDTH), .X_LOCAL(X_LOCAL), .Y_LOCAL(Y_LOCAL)) rsw (.R(right_in), .toDown(downintf[2]), .toLeft(leftintf[2]), .toUp(upintf[2]), .toLocal(localintf[3]));
  local_switch  #(.WIDTH(WIDTH), .X_LOCAL(X_LOCAL), .Y_LOCAL(Y_LOCAL)) csw (.R(local_in), .toDown(downintf[3]), .toLeft(leftintf[3]), .toRight(rightintf[3]), .toUp(upintf[3]));

  arbitermerge_4input #(.WIDTH(WIDTH)) am4i_up    (.R1(upintf[0]), .R2(upintf[1]), .R3(upintf[2]), .R4(upintf[3]), .O(up_out));
  arbitermerge_4input #(.WIDTH(WIDTH)) am4i_down  (.R1(downintf[0]), .R2(downintf[1]), .R3(downintf[2]), .R4(downintf[3]), .O(down_out));
  arbitermerge_4input #(.WIDTH(WIDTH)) am4i_left  (.R1(leftintf[0]), .R2(leftintf[1]), .R3(leftintf[2]), .R4(leftintf[3]), .O(left_out));
  arbitermerge_4input #(.WIDTH(WIDTH)) am4i_right (.R1(rightintf[0]), .R2(rightintf[1]), .R3(rightintf[2]), .R4(rightintf[3]), .O(right_out));
  arbitermerge_4input #(.WIDTH(WIDTH)) am4i_local (.R1(localintf[0]), .R2(localintf[1]), .R3(localintf[2]), .R4(localintf[3]), .O(local_out));



endmodule
