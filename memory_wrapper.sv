`timescale 1ns/1ps
import SystemVerilogCSP::*;

module memory_wrapper(interface toMemRead, toMemWrite, toMemT, toMemX, toMemY, toMemSendData, fromMemGetData, toNOC, fromNOC); 

parameter mem_delay = 15;
parameter simulating_processing_delay = 30;
parameter timesteps = 10;
parameter WIDTH = 8;
parameter WIDTH_NOC=34;
parameter WIDTH_ifmap=5, WIDTH_filter=24;
parameter PE1_addr=4'b0010, PE2_addr=4'b0110, PE3_addr=4'b1010;
parameter wrapper_addr=4'b0000, adder1_addr=4'b0001, adder2_addr=4'b0101, adder3_addr=4'b1001;
parameter input_type=2'b00, kernel_type=2'b01, mem_type=2'b10, out_type=2'b11;
parameter long_range_zeros={{6{3'b000}}, 1'b0}, short_range_zeros={4{4'b0000}};
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
  int flag=0;
  logic [WIDTH-1:0] byteval;
  logic [WIDTH-1:0] by1, by2, by3;
  logic [WIDTH_NOC-1:0] nocval;
  logic [WIDTH_ifmap-1:0] ifmapvalue;
  logic [WIDTH_filter-1:0] filterval;
  logic spikeval;
  
// Weight stationary design
// TO DO: modify for your dataflow - can read an entire row (or write one) before #mem_delay
// TO DO: decide whether each Send(*)/Receive(*) is correct, or just a placeholder
  initial begin
	for (int i = 0; i < num_filts_x; i++) begin
		for (int j = 0; j < num_filts_y; j++) begin
			$display("%m Requesting filter [%d][%d] at time %d",i,j,$time);
			toMemRead.Send(read_filts);
			toMemX.Send(i);
			toMemY.Send(j);
			fromMemGetData.Receive(byteval);
			case(j)
			0:by1=byteval;
			1:by2=byteval;
			2:by3=byteval;
			endcase
			$display("%m Received filter[%d][%d] = %d at time %d",i,j,byteval,$time);
		end
		#mem_delay;
		filterval={by3, by2, by1};
		case(i)
			0: nocval={wrapper_addr, PE1_addr, kernel_type, filterval};
			1: nocval={wrapper_addr, PE2_addr, kernel_type, filterval};
			2: nocval={wrapper_addr, PE3_addr, kernel_type, filterval};
		endcase
		toNOC.Send(nocval);
		$display("%m toNOC send is %b in %t", nocval, $time);
	end
   $display("%m Received all filters at time %d", $time);
    for (int t = 1; t <= timesteps; t++) begin
	$display("%m beginning timestep t = %d at time = %d",t,$time);
		// get the new ifmaps
		for (int i = 0; i < ifx-2; i++) begin
			for (int j = 0; j < ify; j++) begin
				// TO DO: read old membrane potential (hint: you can't do it here...)
				$display("%m requesting ifm[%d][%d]",i,j);
				// request the input spikes
				toMemRead.Send(read_ifmaps);
				toMemX.Send(i);
				toMemY.Send(j);
				//fromMemGetData.Receive(spikeval);
				//if(fromMemGetData.status != idle) begin
				fromMemGetData.Receive(spikeval);
				ifmapvalue[j]=spikeval;//memory->wrapper send only 1 for input spikes
				//end
				//else begin
				//	ifmapvalue[j]=0;
				//end
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
			$display("%m toNOC send is %b in %t", nocval, $time);
		end // ifx
	$display("%m received all ifmaps for timestep t = %d at time = %d",t,$time);
	
		
		for (int i = 0; i < ofx; i++) begin
			//read old membrane potential
				if(t>=2 & i==0) begin
					for(int k=0; k< ofy; k++) begin
						toMemRead.Send(read_mempots);
						toMemX.Send(i);
						toMemY.Send(k);
						fromMemGetData.Receive(byteval);
						case(k)
							0: nocval={wrapper_addr, adder1_addr,mem_type, short_range_zeros, byteval};
							1: nocval={wrapper_addr, adder2_addr,mem_type, short_range_zeros, byteval};
							2: nocval={wrapper_addr, adder3_addr,mem_type, short_range_zeros, byteval};
						endcase
						toNOC.Send(nocval);
						$display("%m toNOC send oldmem_p is %b in %t", nocval, $time);
					end
				end
			for (int j = 0; j < ofy; j++) begin	
			//send membrane potential and output spikes
				fromNOC.Receive(nocval);						
				$display("%m receive value is %b in %t", nocval, $time);
				if((nocval[WIDTH_NOC-9:WIDTH_NOC-10]==out_type) & (nocval[WIDTH_NOC-31:0]==DONE)) begin	
					if(t>=2 & i>=1) begin
						for(int k=0; k< ofy; k++) begin
							toMemRead.Send(read_mempots);
							toMemX.Send(i);
							toMemY.Send(k);
							fromMemGetData.Receive(byteval);
							case(k)
								0: nocval={wrapper_addr, adder1_addr,mem_type, short_range_zeros, byteval};
								1: nocval={wrapper_addr, adder2_addr,mem_type, short_range_zeros, byteval};
								2: nocval={wrapper_addr, adder3_addr,mem_type, short_range_zeros, byteval};
							endcase
							toNOC.Send(nocval);
							$display("%m toNOC send oldmem_p is %b in %t", nocval, $time);
						end
					end
					flag+=1;
					$display("%m  Done received");
					if(flag<=2) begin
						for(int k=0; k< ify; k++) begin
							toMemRead.Send(read_ifmaps);
							toMemX.Send(flag+2);
							toMemY.Send(k);
							fromMemGetData.Receive(spikeval);
							ifmapvalue[k]=spikeval;
							$display("%m received ifm[%d][%d] = %b",flag+2,k,spikeval);	
						end
							#mem_delay; // wait for them to arrive
							nocval={wrapper_addr, PE3_addr, input_type, long_range_zeros, ifmapvalue};
							toNOC.Send(nocval);
							$display("%m toNOC send is %b in %t", nocval, $time);
					end
					if(flag==3) begin
						flag=0;
					end
					j=j-1;
				end
				else begin
					if(nocval[WIDTH_NOC-9:WIDTH_NOC-10]==mem_type) begin
						toMemWrite.Send(write_mempots);
						toMemX.Send(i);
						toMemY.Send(j);
						toMemSendData.Send(nocval[WIDTH_NOC-27:0]);
						$display("%m i=%d,j=%d,mem_p=%d,current timestep=%d",i,j,nocval[WIDTH_NOC-27:0],t);
					end
					else if(nocval[WIDTH_NOC-9:WIDTH_NOC-10]==out_type) begin
						toMemWrite.Send(write_ofmaps);
						//adder -> wrapper send only 1 for output spikes
						toMemX.Send(nocval[WIDTH_NOC-31:WIDTH_NOC-32]);
						toMemY.Send(nocval[WIDTH_NOC-33:0]);	
						$display("%m addr1=%b,addr0=%b,current timestep=%d",nocval[WIDTH_NOC-31:WIDTH_NOC-32],nocval[WIDTH_NOC-33:0],t);
						//toMemSendData.Send(1);
						j=j-1;
					end
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