`timescale 1ns/1ps
import SystemVerilogCSP::*;

module sample_memory_wrapper(Channel toMemRead, Channel toMemWrite, Channel toMemT,
			Channel toMemX, Channel toMemY, Channel toMemSendData, Channel fromMemGetData, 
			interface toNOC, interface fromNOC
			); 

parameter mem_delay = 15;
parameter simulating_processing_delay = 30;
parameter timesteps = 10;
parameter WIDTH = 8;
  Channel #(.hsProtocol(P4PhaseBD)) intf[9:0] (); 
  Channel #(.hsProtocol(P4PhaseBD)) toPacker ();
  Channel #(.hsProtocol(P4PhaseBD)) toSpike ();
  Channel #(.hsProtocol(P4PhaseBD)) fromRECV ();
  int num_filts_x = 3;
  int num_filts_y = 3;
  int ofx = 3;
  int ofy = 3;
  int ifx = 5;
  int ify = 5;
  int ift = 10;
  int i,j,t;
  int k = 0;
  int read_filts = 2;
  int read_ifmaps = 1; // write_ofmaps = 1 as well...
  int read_mempots = 0;
  int write_ofmaps = 1;
  int write_mempots = 0;
  logic [WIDTH-1:0] byteval;
  logic spikeval;
  logic [WIDTH-1:0] mem_pot_val;
  logic out_spike;

// Weight stationary design
// TO DO: modify for your dataflow - can read an entire row (or write one) before #mem_delay
// TO DO: decide whether each Send(*)/Receive(*) is correct, or just a placeholder
  initial begin
	for (int i = 0; i < num_filts_x; i++) begin
		for (int j = 0; j < num_filts_y; ++j) begin
			k = k + 1;
			$display("%m Requesting filter [%d][%d] at time %d",i,j,$time);
			toMemRead.Send(read_filts);
			toMemX.Send(i);
			toMemY.Send(j);
			fromMemGetData.Receive(byteval);
			$display("%m Received filter[%d][%d] = %d at time %d",i,j,byteval,$time);
			toPacker.Send(byteval);
		end
		#mem_delay;
	end
   $display("%m Received all filters at time %d", $time);


    for (int t = 1; t <= timesteps; t++) begin
	$display("%m beginning timestep t = %d at time = %d",t,$time);

		// get the new ifmaps
		for (int i = 0; i < ifx; i++) begin
			
			for (int j = 0; j < ify; ++j) begin

				$display("%m requesting ifm[%d][%d]",i,j);
				// request the input spikes
				toMemRead.Send(read_ifmaps);
				toMemX.Send(i);
				toMemY.Send(j);
				fromMemGetData.Receive(spikeval);
				$display("%m received ifm[%d][%d] = %b",i,j,spikeval);				
				toSpike.Send(spikeval);
				//#simulating_processing_delay;
			end // ify
			#mem_delay; // wait for them to arrive
		end // ifx
	$display("%m received all ifmaps for timestep t = %d at time = %d",t,$time);
		
		// write back membrane potentials & spikes
		// TO DO: you need to get them from the NoC first!
		for (int i = 0; i < ofx; i++) begin
			for (int j = 0; j < ofy; ++j) begin		
				//fromRECV.Receive(mem_pot_val);
				//toMemWrite.Send(write_mempots);
				//toMemX.Send(i);
				//toMemY.Send(j);
				//toMemSendData.Send(mem_pot_val);

				fromRECV.Receive(out_spike);
				toMemWrite.Send(write_ofmaps);
				toMemX.Send(i);
				toMemY.Send(j);				
				toMemSendData.Send(out_spike);
			end // ofy
			//#mem_delay;
		end // ofx
		$display("%m sent all output spikes and stored membrane potentials for timestep t = %d at time = %d",t,$time);
		#1;
		toMemT.Send(t);
		$display("%m send request to advance to next timestep at time t = %d",$time);
	end // t = timesteps
	$display("%m done");
	#mem_delay; // let memory display comparison of golden vs your outputs
	$stop;
  end
  /*
  always begin
	#200;
	$display("%m working still...");
  end
  */
  sender sdr (.Memin(toSpike), .Meminkernel(toPacker), .toNOC(toNOC));
  receiver recv (.Memout(fromRECV), .fromNOC(fromNOC));
endmodule


module sender (interface Memin, interface Meminkernel, interface toNOC);
parameter FL = 1;
parameter BL = 1;
logic [7:0] filter [8:0];
logic [23:0] kernelrow1, kernelrow2, kernelrow3;
logic [4:0] ifmap;
logic spike;
int i, j;
logic [2:0] k = 0;
logic [38:0] packet;

initial 
begin
	for (i = 0; i < 9; i++)	begin
		Meminkernel.Receive(filter[i]);
	end
	kernelrow1 = {filter[0], filter[1], filter[2]};
	kernelrow2 = {filter[3], filter[4], filter[5]};
	kernelrow3 = {filter[6], filter[7], filter[8]};
	$display("PACKER Received kernelrow = %b", kernelrow1);
	$display("PACKER Received kernelrow = %b", kernelrow2);
	$display("PACKER Received kernelrow = %b", kernelrow3);
end

always 
begin

	for (i = 0; i < 5; i++) begin

		Memin.Receive(spike);
		ifmap[4] = spike;
		Memin.Receive(spike);
		ifmap[3] = spike;
		Memin.Receive(spike);
		ifmap[2] = spike;
		Memin.Receive(spike);
		ifmap[1] = spike;
		Memin.Receive(spike);
		ifmap[0] = spike;
		#FL;

		k = k + 1;
		case (k)
			1: begin
				toNOC.Send({2'b01, 8'b0000_0001, ifmap, kernelrow1});
				#BL;
			end
			2: begin
				toNOC.Send({2'b01, 8'b0000_0010, ifmap, kernelrow2});
				#BL;
				toNOC.Send({2'b01, 8'b0001_0001, ifmap, kernelrow1});
				#BL;
			end
			3: begin
				toNOC.Send({2'b01, 8'b0000_0011, ifmap, kernelrow3});
				#BL;
				toNOC.Send({2'b01, 8'b0001_0010, ifmap, kernelrow2});
				#BL;
				toNOC.Send({2'b01, 8'b0010_0001, ifmap, kernelrow1});
				#BL;				
			end
			4: begin
				toNOC.Send({2'b01, 8'b0001_0011, ifmap, kernelrow3});
				#BL;
				toNOC.Send({2'b01, 8'b0010_0010, ifmap, kernelrow2});
				#BL;
			end
			5: begin
				toNOC.Send({2'b01, 8'b0010_0011, ifmap, kernelrow3});
				#BL;
				k = 0;
			end
			default: begin
				
			end
		endcase

	end
    $display("*****************************SEND FINISHED*****************************");
end

endmodule

module receiver(interface Memout, interface fromNOC);
parameter FL = 1;
parameter BL = 1;
logic [38:0] packet;

always
begin
	fromNOC.Receive(packet);
	#FL;
	$display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX RECEIVE A PACKET FROM NOC XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ");
	//Memout.Send(packet[23:16]);
	Memout.Send(packet[26]);
	//Memout.Send(packet[15:8]);
	Memout.Send(packet[25]);
	//Memout.Send(packet[7:0]);
	Memout.Send(packet[24]);
	#BL;
end

endmodule
