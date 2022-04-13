`timescale 1ns/1ps
import SystemVerilogCSP::*;

module memory_wrapper(interface toMemRead, toMemWrite, toMemT, toMemX, toMemY, toMemSendData, fromMemGetData, toNOC, fromNOC); 

parameter mem_delay = 15;
parameter simulating_processing_delay = 30;
parameter timesteps = 10;
parameter WIDTH = 8;
parameter WIDTH_NOC=34;
parameter WIDTH_ifmap=5, WIDTH_filter=24;
parameter PE1_addr=4'b0100, PE2_addr=4'b0101, PE3_addr=4'b0110;
parameter wrapper_addr=4'b0001, adder1_addr=4'b1000, adder2_addr=4'b1001, adder3_addr=4'b1010;
parameter input_type=2'b00, kernel_type=2'b01, mem_type=2'b10;
parameter long_range_zeros={6{4'b0000}}, short_range_zeros={4{4'b0000}};
parameter DONE=4'b1111;

  //Channel #(.hsProtocol(P4PhaseBD)) intf[9:0] (); 
  int num_filts_x = 3;
  int num_filts_y = 3;
  int ofx = 3;
  int ofy = 3;
  int ifx = 5;
  int ify = 5;
  int ift = 10;
  int i,j,k,t;
  int read_filts = 2;
  int read_ifmaps = 1; // write_ofmaps = 1 as well...
  int read_mempots = 0;
  int write_ofmaps = 1;
  int write_mempots = 0;
  logic [WIDTH-1:0] byteval;
  logic [WIDTH_NOC-1:0] nocval;
  logic [WIDTH_ifmap-1:0] ifmapvalue;
  logic [WIDTH_filter-1:0] filterval;
  logic spikeval;
  
// Weight stationary design
// TO DO: modify for your dataflow - can read an entire row (or write one) before #mem_delay
// TO DO: decide whether each Send(*)/Receive(*) is correct, or just a placeholder
  initial begin
	for (int i = 0; i < num_filts_x; i++) begin
		for (int j = 0; j < num_filts_y; ++j) begin
			$display("%m Requesting filter [%d][%d] at time %d",i,j,$time);
			toMemRead.Send(read_filts);
			toMemX.Send(i);
			toMemY.Send(j);
			fromMemGetData.Receive(byteval);
			case(j)
			0:filterval[WIDTH_filter-17:0]=byteval;
			1:filterval[WIDTH_filter-9:WIDTH-16]=byteval;
			2:filterval[WIDTH_filter-1:WIDTH_filter-8]=byteval;
			endcase
			$display("%m Received filter[%d][%d] = %d at time %d",i,j,byteval,$time);
		end
		#mem_delay;
		case(i)
			0: nocval={wrapper_addr, PE1_addr, kernel_type, filterval};
			1: nocval={wrapper_addr, PE2_addr, kernel_type, filterval};
			2: nocval={wrapper_addr, PE3_addr, kernel_type, filterval};
		endcase
		toNOC.Send(nocval);
	end
   $display("%m Received all filters at time %d", $time);
    for (int t = 1; t <= timesteps; t++) begin
	$display("%m beginning timestep t = %d at time = %d",t,$time);
		// get the new ifmaps
		for (int i = 0; i < ifx-2; i++) begin
			for (int j = 0; j < ify; ++j) begin
				// TO DO: read old membrane potential (hint: you can't do it here...)
				$display("%m requesting ifm[%d][%d]",i,j);
				// request the input spikes
				toMemRead.Send(read_ifmaps);
				toMemX.Send(i);
				toMemY.Send(j);
				//fromMemGetData.Receive(spikeval);
				if(fromMemGetData.status != idle) begin
					fromMemGetData.Receive(spikeval);
					ifmapvalue[j]=spikeval;//memory->wrapper send only 1 for input spikes
				end
				else begin
					ifmapvalue[j]=0;
				end
				$display("%m received ifm[%d][%d] = %b",i,j,spikeval);				
				//#simulating_processing_delay;
			end // ify
			#mem_delay; // wait for them to arrive
			case(i)
				0: nocval={wrapper_addr, PE1_addr, input_type, long_range_zeros, ifmapvalue};
				1: nocval={wrapper_addr, PE2_addr, input_type, long_range_zeros, ifmapvalue};
				2: nocval={wrapper_addr, PE3_addr, input_type, long_range_zeros, ifmapvalue};
				/*default: 
				begin
					fromNOC.Receive(nocval);
					if(nocval[WIDTH_NOC-31:0]==DONE) begin
					nocval={wrapper_addr, PE3_addr, input_type, ifmapvalue};
				end*/
			endcase
			toNOC.Send(nocval);
		end // ifx
	$display("%m received all ifmaps for timestep t = %d at time = %d",t,$time);
		//read old membrane potential
		/*if(t>=2) begin
			for(int i = 0; i < ofx; i++) begin
				for (int j = 0; j < ofy; j++) begin
					toMemRead.Send(read_mempots)
					toMemX.Send(i);
					toMemY.Send(j);
					fromMemGetData.Receive(byteval);
					case(j)
						0: nocval={wrapper_addr, adder1_addr,mem_type, short_range_zeros, byteval};
						1: nocval={wrapper_addr, adder2_addr,mem_type, short_range_zeros, byteval};
						2: nocval={wrapper_addr, adder3_addr,mem_type, short_range_zeros, byteval};
					endcase
					toNOC.Send(nocval);
				end
			end
		end*/
		// write back membrane potentials & spikes
		// TO DO: you need to get them from the NoC first!
		
		for (int i = 0; i < ofx; i++) begin
			for (int j = 0; j < ofy; j++) begin
				//read old membrane potential
				if(t>=2) begin
					toMemRead.Send(read_mempots);
					toMemX.Send(i);
					toMemY.Send(j);
					fromMemGetData.Receive(byteval);
					case(j)
						0: nocval={wrapper_addr, adder1_addr,mem_type, short_range_zeros, byteval};
						1: nocval={wrapper_addr, adder2_addr,mem_type, short_range_zeros, byteval};
						2: nocval={wrapper_addr, adder3_addr,mem_type, short_range_zeros, byteval};
					endcase
					toNOC.Send(nocval);
				end
				fromNOC.Receive(nocval);
				//send membrane potential and output spikes
				if(nocval[WIDTH_NOC-31:0]!=DONE) begin
					if(nocval[WIDTH_NOC-9:WIDTH_NOC-10]==10) begin
						toMemWrite.Send(write_mempots);
						toMemX.Send(i);
						toMemY.Send(j);
						toMemSendData.Send(nocval[WIDTH_NOC-27:0]);
					end
					else if(nocval[WIDTH_NOC-9:WIDTH_NOC-10]==11) begin
						toMemWrite.Send(write_ofmaps);
						//adder -> wrapper send only 1 for output spikes
						toMemX.Send(nocval[WIDTH_NOC-31:WIDTH_NOC-32]);
						toMemY.Send(nocval[WIDTH_NOC-33:0]);				
						//toMemSendData.Send(1);
					end
				end
				else begin
					if(i<2) begin
						for(int k=0; k< ify; k++) begin
							toMemRead.Send(read_ifmaps);
							toMemX.Send(i+3);
							toMemY.Send(k);
							fromMemGetData.Receive(spikeval);
							ifmapvalue[j]=spikeval;
							$display("%m received ifm[%d][%d] = %b",i,j,spikeval);	
						end
						#mem_delay; // wait for them to arrive
						nocval={wrapper_addr, PE3_addr, input_type, long_range_zeros, ifmapvalue};
						toNOC.Send(nocval);
					end
					break;
				end
			end // ofy
		end // ofx
		$display("%m sent all output spikes and stored membrane potentials for timestep t = %d at time = %d",t,$time);
		toMemT.Send(t);
		$display("%m send request to advance to next timestep at time t = %d",$time);
	end // t = timesteps
	$display("%m done");
	#mem_delay; // let memory display comparison of golden vs your outputs
	$stop;
  end
  
  always begin
	#200;
	$display("%m working still...");
  end
  
endmodule