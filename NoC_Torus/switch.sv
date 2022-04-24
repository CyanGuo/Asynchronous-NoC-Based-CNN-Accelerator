`timescale 1ns/100ps

import SystemVerilogCSP::*;

module up_switch (interface R, interface toDown, interface toLeft, interface toRight, interface toLocal);
  parameter WIDTH = 39;
  parameter FL = 2;
  parameter BL = 1;
  parameter [3:0] X_LOCAL = 4'b0000;
  parameter [3:0] Y_LOCAL = 4'b0001;
  parameter [3:0] Y_MAX = 4'b0100;
  logic [WIDTH-1:0] packet;
  logic [3:0] x;
  logic [3:0] y;
// packet 01_0001_0001_00000_00001110_00000101_00001000
//        38 36   32   28    23       15       7       0   
  always begin
    R.Receive(packet);
    x = packet [36:33];
    y = packet [32:29];
    #FL;
    if (y == 4'b0000 && Y_LOCAL == Y_MAX) toDown.Send(packet);
    else if (x == X_LOCAL && y == Y_LOCAL) toLocal.Send(packet);
    else if (y > Y_LOCAL) toDown.Send(packet);
    else if (x > X_LOCAL) begin
      if (x-X_LOCAL < 2) toRight.Send(packet);
      else toLeft.Send(packet);
    end
    else if (x < X_LOCAL) begin
      if (X_LOCAL-x < 2) toLeft.Send(packet);
      else toRight.Send(packet);
    end
    #BL;
  end
endmodule

module down_switch (interface R, interface toUp, interface toLeft, interface toRight, interface toLocal);
  parameter WIDTH = 39;
  parameter FL = 2;
  parameter BL = 1;
  parameter [3:0] X_LOCAL = 4'b0000;
  parameter [3:0] Y_LOCAL = 4'b0001;
  parameter [3:0] Y_MAX = 4'b0100;
  logic [WIDTH-1:0] packet;
  logic [3:0] x;
  logic [3:0] y;
// packet 01_0001_0001_00000_00001110_00000101_00001000
//        38 36   32   28    23       15       7       0   
  always begin
    R.Receive(packet);
    x = packet [36:33];
    y = packet [32:29];
    #FL;
    if (y == Y_MAX && Y_LOCAL == 0) toUp.Send(packet);
    else if (x == X_LOCAL && y == Y_LOCAL) toLocal.Send(packet);
    else if (y < Y_LOCAL) toUp.Send(packet);
    else if (x > X_LOCAL) begin
      if (x-X_LOCAL < 2) toRight.Send(packet);
      else toLeft.Send(packet);
    end
    else if (x < X_LOCAL) begin
      if (X_LOCAL-x < 2) toLeft.Send(packet);
      else toRight.Send(packet);
    end
    #BL;
  end
endmodule

module left_switch (interface R, interface toDown, interface toUp, interface toRight, interface toLocal);
  parameter WIDTH = 39;
  parameter FL = 2;
  parameter BL = 1;
  parameter [3:0] X_LOCAL = 4'b0000;
  parameter [3:0] Y_LOCAL = 4'b0001;
  parameter [3:0] Y_MAX = 4'b0100;
  logic [WIDTH-1:0] packet;
  logic [3:0] x;
  logic [3:0] y;
// packet 01_0001_0001_00000_00001110_00000101_00001000
//        38 36   32   28    23       15       7       0   
  always begin
    R.Receive(packet);
    x = packet [36:33];
    y = packet [32:29];
    #FL;
    //if (y == 4'b0000 && Y_LOCAL == Y_MAX) toDown.Send(packet);
    if (x == X_LOCAL && y == Y_LOCAL) toLocal.Send(packet);
    else if (y > Y_LOCAL) begin
      if (y-Y_LOCAL < 3) toDown.Send(packet);
      else toUp.Send(packet);
    end
    else if (y < Y_LOCAL) begin
      if (Y_LOCAL-y < 3) toUp.Send(packet);
      else toDown.Send(packet);
    end
    else if (x > X_LOCAL) toRight.Send(packet);
    #BL;
  end
endmodule

module right_switch (interface R, interface toDown, interface toLeft, interface toUp, interface toLocal);
  parameter WIDTH = 39;
  parameter FL = 2;
  parameter BL = 1;
  parameter [3:0] X_LOCAL = 4'b0000;
  parameter [3:0] Y_LOCAL = 4'b0001;
  parameter [3:0] Y_MAX = 4'b0100;
  logic [WIDTH-1:0] packet;
  logic [3:0] x;
  logic [3:0] y;
// packet 01_0001_0001_00000_00001110_00000101_00001000
//        38 36   32   28    23       15       7       0   
  always begin
    R.Receive(packet);
    x = packet [36:33];
    y = packet [32:29];
    #FL;
    //if (y == 4'b0000 && Y_LOCAL == Y_MAX) toDown.Send(packet);
    if (x == X_LOCAL && y == Y_LOCAL) toLocal.Send(packet);
    else if (y > Y_LOCAL) begin
      if (y-Y_LOCAL < 3) toDown.Send(packet);
      else toUp.Send(packet);
    end
    else if (y < Y_LOCAL) begin
      if (Y_LOCAL-y < 3) toUp.Send(packet);
      else toDown.Send(packet);
    end
    else if (x < X_LOCAL) toLeft.Send(packet);
    #BL;
  end
endmodule

module local_switch (interface R, interface toDown, interface toLeft, interface toRight, interface toUp);
  parameter WIDTH = 39;
  parameter FL = 2;
  parameter BL = 1;
  parameter [3:0] X_LOCAL = 4'b0000;
  parameter [3:0] Y_LOCAL = 4'b0001;
  parameter [3:0] Y_MAX = 4'b0100;
  logic [WIDTH-1:0] packet;
  logic [3:0] x;
  logic [3:0] y;
// packet 01_0001_0001_00000_00001110_00000101_00001000
//        38 36   32   28    23       15       7       0   
  always begin
    R.Receive(packet);
    x = packet [36:33];
    y = packet [32:29];
    #FL;
    //if (y == 4'b0000 && Y_LOCAL == Y_MAX) toDown.Send(packet);
    if (y > Y_LOCAL) begin
      if (y-Y_LOCAL < 3) toDown.Send(packet);
      else toUp.Send(packet);
    end
    else if (y < Y_LOCAL) begin
      if (Y_LOCAL-y < 3) toUp.Send(packet);
      else toDown.Send(packet);
    end
    else if (x > X_LOCAL) begin
      if (x-X_LOCAL < 2) toRight.Send(packet);
      else toLeft.Send(packet);
    end
    else if (x < X_LOCAL) begin
      if (X_LOCAL-x < 2) toLeft.Send(packet);
      else toRight.Send(packet);
    end
    #BL;
  end
endmodule