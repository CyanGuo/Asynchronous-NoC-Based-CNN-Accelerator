//Copyright @ Yuqing Guo 2022
`timescale 1ns/1ns
import SystemVerilogCSP::*;

module NoC (interface IN, interface OUT);

//CHANNEL
  Channel #(.WIDTH(39), .hsProtocol(P4PhaseBD)) row01 [5:0] (); 
  Channel #(.WIDTH(39), .hsProtocol(P4PhaseBD)) row12 [5:0] ();
  Channel #(.WIDTH(39), .hsProtocol(P4PhaseBD)) row23 [5:0] ();
  Channel #(.WIDTH(39), .hsProtocol(P4PhaseBD)) row34 [5:0] ();
  Channel #(.WIDTH(39), .hsProtocol(P4PhaseBD)) row40 [5:0] ();

  Channel #(.WIDTH(39), .hsProtocol(P4PhaseBD)) col01 [9:0] (); 
  Channel #(.WIDTH(39), .hsProtocol(P4PhaseBD)) col12 [9:0] ();
  Channel #(.WIDTH(39), .hsProtocol(P4PhaseBD)) col20 [9:0] ();
  Channel #(.WIDTH(39), .hsProtocol(P4PhaseBD)) locali [15:0] ();
  Channel #(.WIDTH(39), .hsProtocol(P4PhaseBD)) localo [15:0] ();

  Channel #(.WIDTH(39), .hsProtocol(P4PhaseBD)) inact [30:0] (); 
  Channel #(.WIDTH(39), .hsProtocol(P4PhaseBD)) edges [30:0] (); 
//------------------------------ 0th ROW -------------------------------//

  router #(.WIDTH(39), .X_LOCAL(4'b0000), .Y_LOCAL(4'b0000))
  rt00 (.up_in (row40[0]), .down_in (row01[1]), .left_in (edges[1]), .right_in (col01[1]), .local_in (IN), 
        .up_out(row40[1]), .down_out(row01[0]), .left_out(edges[0]), .right_out(col01[0]), .local_out(OUT));

  router #(.WIDTH(39), .X_LOCAL(4'b0001), .Y_LOCAL(4'b0000))
  rt01 (.up_in (row40[2]), .down_in (row01[3]), .left_in (col01[0]), .right_in (col12[1]), .local_in (locali[1]), 
        .up_out(row40[3]), .down_out(row01[2]), .left_out(col01[1]), .right_out(col12[0]), .local_out(localo[1]));

  router #(.WIDTH(39), .X_LOCAL(4'b0010), .Y_LOCAL(4'b0000))
  rt02 (.up_in (row40[4]), .down_in (row01[5]), .left_in (col12[0]), .right_in (edges[0]), .local_in (locali[2]), 
        .up_out(row40[5]), .down_out(row01[4]), .left_out(col12[1]), .right_out(edges[1]), .local_out(localo[2]));

//------------------------------ 0th ROW -------------------------------//

//------------------------------ 1st ROW -------------------------------//

  router #(.WIDTH(39), .X_LOCAL(4'b0000), .Y_LOCAL(4'b0001))
  rt10 (.up_in (row01[0]), .down_in (row12[1]), .left_in (edges[3]), .right_in (col01[3]), .local_in (locali[3]), 
        .up_out(row01[1]), .down_out(row12[0]), .left_out(edges[2]), .right_out(col01[2]), .local_out(localo[3]));

  router #(.WIDTH(39), .X_LOCAL(4'b0001), .Y_LOCAL(4'b0001))
  rt11 (.up_in (row01[2]), .down_in (row12[3]), .left_in (col01[2]), .right_in (col12[3]), .local_in (locali[4]), 
        .up_out(row01[3]), .down_out(row12[2]), .left_out(col01[3]), .right_out(col12[2]), .local_out(localo[4]));

  router #(.WIDTH(39), .X_LOCAL(4'b0010), .Y_LOCAL(4'b0001))
  rt12 (.up_in (row01[4]), .down_in (row12[5]), .left_in (col12[2]), .right_in (edges[2]), .local_in (locali[5]), 
        .up_out(row01[5]), .down_out(row12[4]), .left_out(col12[3]), .right_out(edges[3]), .local_out(localo[5]));

//------------------------------ 1st ROW -------------------------------//

//------------------------------ 2nd ROW -------------------------------//

  router #(.WIDTH(39), .X_LOCAL(4'b0000), .Y_LOCAL(4'b0010))
  rt20 (.up_in (row12[0]), .down_in (row23[1]), .left_in (edges[4]), .right_in (col01[5]), .local_in (locali[6]), 
        .up_out(row12[1]), .down_out(row23[0]), .left_out(edges[5]), .right_out(col01[4]), .local_out(localo[6]));

  router #(.WIDTH(39), .X_LOCAL(4'b0001), .Y_LOCAL(4'b0010))
  rt21 (.up_in (row12[2]), .down_in (row23[3]), .left_in (col01[4]), .right_in (col12[5]), .local_in (locali[7]), 
        .up_out(row12[3]), .down_out(row23[2]), .left_out(col01[5]), .right_out(col12[4]), .local_out(localo[7]));

  router #(.WIDTH(39), .X_LOCAL(4'b0010), .Y_LOCAL(4'b0010))
  rt22 (.up_in (row12[4]), .down_in (row23[5]), .left_in (col12[4]), .right_in (edges[5]), .local_in (locali[8]), 
        .up_out(row12[5]), .down_out(row23[4]), .left_out(col12[5]), .right_out(edges[4]), .local_out(localo[8]));

//------------------------------ 2nd ROW -------------------------------//

//------------------------------ 3rd ROW -------------------------------//

  router #(.WIDTH(39), .X_LOCAL(4'b0000), .Y_LOCAL(4'b0011))
  rt30 (.up_in (row23[0]), .down_in (row34[1]), .left_in (edges[6]), .right_in (col01[7]), .local_in (locali[9]), 
        .up_out(row23[1]), .down_out(row34[0]), .left_out(edges[7]), .right_out(col01[6]), .local_out(localo[9]));

  router #(.WIDTH(39), .X_LOCAL(4'b0001), .Y_LOCAL(4'b0011))
  rt31 (.up_in (row23[2]), .down_in (row34[3]), .left_in (col01[6]), .right_in (col12[7]), .local_in (locali[10]), 
        .up_out(row23[3]), .down_out(row34[2]), .left_out(col01[7]), .right_out(col12[6]), .local_out(localo[10]));

  router #(.WIDTH(39), .X_LOCAL(4'b0010), .Y_LOCAL(4'b0011))
  rt32 (.up_in (row23[4]), .down_in (row34[5]), .left_in (col12[6]), .right_in (edges[7]), .local_in (locali[11]), 
        .up_out(row23[5]), .down_out(row34[4]), .left_out(col12[7]), .right_out(edges[6]), .local_out(localo[11]));

//------------------------------ 3rd ROW -------------------------------//

//------------------------------ 4th ROW -------------------------------//

  router #(.WIDTH(39), .X_LOCAL(4'b0000), .Y_LOCAL(4'b0100))
  rt40 (.up_in (row34[0]), .down_in (row40[1]), .left_in (edges[8]), .right_in (col01[9]), .local_in (locali[12]), 
        .up_out(row34[1]), .down_out(row40[0]), .left_out(edges[9]), .right_out(col01[8]), .local_out(localo[12]));

  router #(.WIDTH(39), .X_LOCAL(4'b0001), .Y_LOCAL(4'b0100))
  rt41 (.up_in (row34[2]), .down_in (row40[3]), .left_in (col01[8]), .right_in (col12[9]), .local_in (locali[13]), 
        .up_out(row34[3]), .down_out(row40[2]), .left_out(col01[9]), .right_out(col12[8]), .local_out(localo[13]));

  router #(.WIDTH(39), .X_LOCAL(4'b0010), .Y_LOCAL(4'b0100))
  rt42 (.up_in (row34[4]), .down_in (row40[5]), .left_in (col12[8]), .right_in (edges[9]), .local_in (locali[14]), 
        .up_out(row34[5]), .down_out(row40[4]), .left_out(col12[9]), .right_out(edges[8]), .local_out(localo[14]));

//------------------------------ 4th ROW -------------------------------//




//------------------------------ 1st COL PE -------------------------------//
  pe_top #(.OUT_ROW(2'b01), .TARGET_ADDR(8'b0000_0100))
  pe1 (.pkt_in(localo[3]), .pkt_out(locali[3]));
  pe_top #(.OUT_ROW(2'b01), .TARGET_ADDR(8'b0000_0100))
  pe2 (.pkt_in(localo[6]), .pkt_out(locali[6]));
  pe_top #(.OUT_ROW(2'b01), .TARGET_ADDR(8'b0000_0100))
  pe3 (.pkt_in(localo[9]), .pkt_out(locali[9]));
//------------------------------ 1st COL PE -------------------------------//

//------------------------------ 2nd COL PE -------------------------------//
  pe_top #(.OUT_ROW(2'b10), .TARGET_ADDR(8'b0001_0100))
  pe4 (.pkt_in(localo[4]), .pkt_out(locali[4]));
  pe_top #(.OUT_ROW(2'b10), .TARGET_ADDR(8'b0001_0100))
  pe5 (.pkt_in(localo[7]), .pkt_out(locali[7]));
  pe_top #(.OUT_ROW(2'b10), .TARGET_ADDR(8'b0001_0100))
  pe6 (.pkt_in(localo[10]), .pkt_out(locali[10]));
//------------------------------ 2nd COL PE -------------------------------//

//------------------------------ 3rd COL PE -------------------------------//
  pe_top #(.OUT_ROW(2'b11), .TARGET_ADDR(8'b0010_0100))
  pe7 (.pkt_in(localo[5]), .pkt_out(locali[5]));
  pe_top #(.OUT_ROW(2'b11), .TARGET_ADDR(8'b0010_0100))
  pe8 (.pkt_in(localo[8]), .pkt_out(locali[8]));
  pe_top #(.OUT_ROW(2'b11), .TARGET_ADDR(8'b0010_0100))
  pe9 (.pkt_in(localo[11]), .pkt_out(locali[11]));
//------------------------------ 3rd COL PE -------------------------------//




//------------------------------ ROW ADDER -------------------------------//
row_adder #(.ROW(2'b01)) ra1 (.r(localo[12]), .pkt_out(locali[12]));
row_adder #(.ROW(2'b10)) ra2 (.r(localo[13]), .pkt_out(locali[13]));
row_adder #(.ROW(2'b11)) ra3 (.r(localo[14]), .pkt_out(locali[14]));
//------------------------------ ROW ADDER -------------------------------//


endmodule
