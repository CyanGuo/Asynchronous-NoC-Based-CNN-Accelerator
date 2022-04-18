`timescale 1ns/100ps

import SystemVerilogCSP::*;

module up_switch (interface R, interface toDown, interface toLeft, interface toRight, interface toLocal);
  parameter WIDTH = 39;
  parameter FL = 1;
  parameter BL = 1;
  parameter [3:0] X_LOCAL = 4'b0000;
  parameter [3:0] Y_LOCAL = 4'b0001;
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
    
    if (x == X_LOCAL && y == Y_LOCAL) toLocal.Send(packet);
    else if (y > Y_LOCAL) toDown.Send(packet);
    else if (x > X_LOCAL) toRight.Send(packet);
    else if (x < X_LOCAL) toLeft.Send(packet);
    #BL;
  end
endmodule

module down_switch (interface R, interface toUp, interface toLeft, interface toRight, interface toLocal);
  parameter WIDTH = 39;
  parameter FL = 1;
  parameter BL = 1;
  parameter [3:0] X_LOCAL = 4'b0000;
  parameter [3:0] Y_LOCAL = 4'b0001;
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
    
    if (x == X_LOCAL && y == Y_LOCAL) toLocal.Send(packet);
    else if (y < Y_LOCAL) toUp.Send(packet);
    else if (x > X_LOCAL) toRight.Send(packet);
    else if (x < X_LOCAL) toLeft.Send(packet);
    #BL;
  end
endmodule

module left_switch (interface R, interface toDown, interface toUp, interface toRight, interface toLocal);
  parameter WIDTH = 39;
  parameter FL = 1;
  parameter BL = 1;
  parameter [3:0] X_LOCAL = 4'b0000;
  parameter [3:0] Y_LOCAL = 4'b0001;
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
    
    if (x == X_LOCAL && y == Y_LOCAL) toLocal.Send(packet);
    else if (y > Y_LOCAL) toDown.Send(packet);
    else if (y < Y_LOCAL) toUp.Send(packet);
    else if (x > X_LOCAL) toRight.Send(packet);
    #BL;
  end
endmodule

module right_switch (interface R, interface toDown, interface toLeft, interface toUp, interface toLocal);
  parameter WIDTH = 39;
  parameter FL = 1;
  parameter BL = 1;
  parameter [3:0] X_LOCAL = 4'b0000;
  parameter [3:0] Y_LOCAL = 4'b0001;
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
    
    if (x == X_LOCAL && y == Y_LOCAL) toLocal.Send(packet);
    else if (y > Y_LOCAL) toDown.Send(packet);
    else if (y < Y_LOCAL) toUp.Send(packet);
    else if (x < X_LOCAL) toLeft.Send(packet);
    #BL;
  end
endmodule

module local_switch (interface R, interface toDown, interface toLeft, interface toRight, interface toUp);
  parameter WIDTH = 39;
  parameter FL = 1;
  parameter BL = 1;
  parameter [3:0] X_LOCAL = 4'b0000;
  parameter [3:0] Y_LOCAL = 4'b0001;
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
    
    if (y < Y_LOCAL) toUp.Send(packet);
    else if (y > Y_LOCAL) toDown.Send(packet);
    else if (x > X_LOCAL) toRight.Send(packet);
    else if (x < X_LOCAL) toLeft.Send(packet);
    #BL;
  end
endmodule