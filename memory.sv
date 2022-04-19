/* memory.sv

   Matt Conn
   connmatt@usc.edu
   
   SP22 EE-552 Final project 
   
   INSTRUCTIONS:
   1. You can add code to this file, if needed.
   
   2. Marked with TODO:
   You can change/modify if needed
   
*/

`timescale 1ns/1ps
import SystemVerilogCSP::*;
// memory
// TODO you can add more interfaces if needed (DO NOT remove tb_ interfaces without consultation)
// TODO you can add more system ports if needed
// TODO you can add $display or $fwrite commands if needed
// if you modify how the memory works(ex. something besides $display() statements ), 
//  please check with Matt or Prof. Beerel first, and clearly identify what you changed
//	why you made the change, and submit the file at the end
																												
module memory(interface read, write, T, x, y, data_out, data_in); 
  parameter timesteps = 10;
  
  parameter F_ROWS = 3; 
  parameter F_COLS = 3; 
  parameter F_WIDTH = 8; 
  logic [F_WIDTH-1:0] mem_pot_val;
  logic spike_val;
  logic [F_WIDTH-1:0] filter_mem[F_ROWS-1:0][F_COLS-1:0];
  
  parameter IF_ROWS = 5; 
  parameter IF_COLS = 5; 
  logic if_mem[timesteps-1:0][IF_ROWS-1:0][IF_COLS-1:0];
  
  parameter OF_ROWS = 3; 
  parameter OF_COLS = 3; 
  logic of_mem[timesteps-1:0][OF_ROWS-1:0][OF_COLS-1:0];
  logic golden_of_mem[OF_ROWS-1:0][OF_COLS-1:0];
  
  parameter V_POT_WIDTH = 8; // just binary 
  logic [V_POT_WIDTH-1:0] V_pot_mem[OF_ROWS-1:0][OF_COLS-1:0];

  integer index, fi, fj, ifi,ifj, ift,ofi,ofj;
  int rtype,wtype, row, col,t,t_dummy;

  logic [F_WIDTH-1:0] pre_golden_memory [0:OF_ROWS*OF_COLS-1];	
  logic [F_WIDTH-1:0] pre_filt_memory [0:F_ROWS*F_COLS-1];
  logic pre_ifmaps_mem [0:IF_COLS*IF_ROWS*timesteps-1];
	

  initial begin 

	// Load golden mem 			  
	  $readmemb("base_output_bin.mem", pre_golden_memory);	 	  
	  for (ofi = 0; ofi < OF_ROWS; ofi++) begin
		for (ofj = 0; ofj < OF_COLS; ofj++) begin
			index = OF_COLS * ofi + ofj;		
			golden_of_mem[ofi][ofj] = pre_golden_memory[index];
//			$display("%m pre_golden_mem[%h] = %b",index, pre_golden_memory[index]);
//			$display("%m golden_mem[%h][%h] = %b\n", ofi, ofj, golden_of_mem[ofi][ofj]);				
		end // fj fors
	  end // fi for	 

	
	// Load filters 			  
	  $readmemh("base_kernel_hex.mem", pre_filt_memory);	 
	  
	  for (fi = 0; fi < F_ROWS; fi++) begin
		for (fj = 0; fj < F_COLS; fj++) begin
			index = F_COLS * fi + fj;		
			filter_mem[fi][fj] = pre_filt_memory[index];
//			$display("%m pre_filt_mem[%h] = %d",index, pre_filt_memory[index]);
//			$display("%m filter_mem[%h][%h] = %d\n", fi, fj, filter_mem[fi][fj]);				
		end // fj fors
	  end // fi for	 
	  
	  // Load spikes 
	  $readmemb("base_ifmaps_bin.mem", pre_ifmaps_mem);
	  
	  for (ift = 0; ift < timesteps;++ift) begin 
		  for (ifi = 0; ifi < IF_ROWS;++ifi) begin 
			  for (ifj = 0; ifj < IF_COLS;++ifj) begin 
					index = (IF_ROWS*IF_COLS)*ift + IF_COLS*ifi + ifj;
					if_mem[ift][ifi][ifj] = pre_ifmaps_mem[index];
//					$display("%m pre_ifmaps_mem[%d] = %b",index, pre_ifmaps_mem[index]);
//					$display("%m if_mem[%d][%d][%d] = %b\n", ift,ifi,ifj, if_mem[ift][ifi][ifj]);
			  end // col-wise loop
//				$display("%m End of row %d",ifi);
		  end // row-wise loop	  
//		  $display("%m End of timestep");
	  end // timesteps loop	 

	t = 0;
	#1;
	$display("%m has loaded all filters, ifmaps and golden output");	
	for (int i=0;i<timesteps;i++) begin
		for (int j=0;j<OF_ROWS;j++) begin
			for (int k=0;k<OF_COLS;k++) begin
				of_mem[i][j][k] = 1'b0; //initialize all of_mem 
			end	
		end
	end
// When you enter this loop, all filters & input spikes are loaded into memory, along with golden output at t = 10

	while (t < timesteps) begin

		fork
			
			begin // ******************************************************** begin child process 1
				// Request to read value
				read.Receive(rtype);
				fork
					x.Receive(row);
					y.Receive(col);
				join
				if (rtype == 0) begin // user wants membrane potential
					if (row >= OF_ROWS | col >= OF_COLS) begin
						$display("%m reading beyond edge of membrane potential memory");
					end
					data_out.Send(V_pot_mem[row][col]);
				end
				else if (rtype == 1) begin // user wants input spikes
					if (row >= IF_ROWS | col >= IF_COLS) begin
						$display("%m reading beyond the edge of input spike array");
					end
					//if(if_mem[t][row][col]==1) begin //memory->wrapper send only 1 for input spike
						data_out.Send(if_mem[t][row][col]);	
					//end
				end
				else if (rtype == 2) begin // user wants filters
					if (row >= F_ROWS | col >= F_COLS) begin
						$display("reading beyond the edge of filter array");
					end
					data_out.Send(filter_mem[row][col]);					
				end
				else begin
					$display("%m request to read from an unknown memory");
				end
			end   // ******************************************************** end child process 1
			
			begin // \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ begin child process 2
				// request to write value
				write.Receive(wtype);	
				fork
					x.Receive(row);
					y.Receive(col);
				join
				if (wtype == 0) begin // user to write membrane potentials
					if (row >= OF_ROWS | col >= OF_COLS) begin
						$display("%m writing beyond the edge of memV array");
					end
					data_in.Receive(mem_pot_val);
					V_pot_mem[row][col] = mem_pot_val;
				end
				else if (wtype == 1) begin // user wants to write output spikes
					if (row == 2'b11 & col == 2'b11) begin
						$display("%m  Done received");
					end
					else if (row >= OF_ROWS | col >= OF_COLS) begin
						$display("%m writing beyond the edge of output spike array");
					end
					else begin 
					//data_in.Receive(spike_val);					
					of_mem[t][row][col] = 1;//adder -> wrapper send only 1 for output spike
					end
				end
				else begin
					$display("%m request to write from an unknown memory");
				end
			end // \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ end child process 2
			
			begin // &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& begin child process 3
				// Advance timestep;
				// don't put $display() statements here - it will execute whenever any 
				//	process completes, and the always block (parent thread) is 'issued'
				T.Receive(t);//_dummy);
				//t = t + 1;
			end // &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& end child process 3
		join_any
	
	end // while (more timesteps to go)	
	$display("%m done");
	for (integer golden_i = 0; golden_i < OF_ROWS; golden_i++) begin
		for (integer golden_j = 0; golden_j < OF_COLS; golden_j++) begin
			$display("%m Golden[%d][%d} = %b",golden_i,golden_j,golden_of_mem[golden_i][golden_j]);
			$display("%m Your mem val = %b", of_mem[timesteps-1][golden_i][golden_j]);
		end // golden_i
	end // golden_i
	#5;
	$display("%m User reports completion");
	$stop;


  end // initial block
endmodule