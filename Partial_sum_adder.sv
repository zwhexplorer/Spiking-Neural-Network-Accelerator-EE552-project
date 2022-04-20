//unfinished
`timescale 1ns/100ps
import SystemVerilogCSP::*;
module Partial_sum_adder (interface in,out);
parameter adder_number=2'b00; //00--adder1,01--adder2,10--adder3
parameter adder3_num=2'b10;
parameter WIDTH=34;
parameter memb_p_WIDTH=8;
parameter threshold=64;
parameter PE1_addr=4'b0010;
parameter PE2_addr=4'b0110;
parameter PE3_addr=4'b1010;
parameter Adder_addr=4'b0110;
parameter Mem_addr=4'b0000;
parameter WR_addr=4'b0000;
parameter Out_to_Mem_zeros={20{1'b0}};
parameter MP_to_Mem_zeros={16{1'b0}};
parameter count_number=2'b10;
parameter done_singal=4'b1111;
parameter mem_p_type=2'b10;
parameter output_spike_type=2'b11;
logic [WIDTH-1:0] value;
reg [memb_p_WIDTH-1:0] partial_PE1,partial_PE2,partial_PE3,membrane_potential;
logic output_spike;
logic [WIDTH-1:0] out_packet;
logic [3:0]output_spike_addr;
//logic [7:0] partial_2;
//logic [7:0] partial_3;
int flag_PE1_received=0,flag_PE2_received=0,flag_PE3_received=0;
logic [1:0] count=0;
logic  first_time=1'b0;
/***
always
begin
in.Receive(value);
if (value[WIDTH-1:WIDTH-4]==PE1_addr) //src_addr=PE1_addr
	begin
	partial_PE1=value[7:0];
	flag_PE1_received=1;
	//count=count+1;
	end
	
if (value[WIDTH-1:WIDTH-4]==PE2_addr) //PE2
	begin
	partial_PE2=value[7:0];
	flag_PE2_received=1
	//count=count+1;
	end
if (value[WIDTH-1:WIDTH-4]==PE3_addr) //PE3
	begin
	partial_PE3=value[7:0];
	flag_PE3_received=1;
	//count=count+1;
	end

end
***/

//----------------------------------------------------------------------------------------------
always
begin
	//first receive
	in.Receive(value);//PE1
	if (value[WIDTH-1:WIDTH-4]==PE1_addr) //src_addr=PE1_addr
		begin
			partial_PE1=value[7:0];
			//flag_PE1_received=1;//count=count+1;
		end
	
	if (value[WIDTH-1:WIDTH-4]==PE2_addr) //src_addr=PE2
		begin
			partial_PE2=value[7:0];
			//flag_PE2_received=1//count=count+1;
		end
	if (value[WIDTH-1:WIDTH-4]==PE3_addr) //src_addr=PE3
		begin
			partial_PE3=value[7:0];
			//flag_PE3_received=1;//count=count+1;
		end
	if(value[WIDTH-1:WIDTH-4]==WR_addr)//src addr=WR_addr
		if(value[WIDTH-9:WIDTH-10]==mem_p_type)//type=mem_p_type
			begin
				membrane_potential=value[WIDTH-27:WIDTH-34];
			end
	$display("%m first receive----packet:%b",value);
	
		
	//second receive
	in.Receive(value);//PE2
	if (value[WIDTH-1:WIDTH-4]==PE1_addr) //src_addr=PE1_addr
		begin
			partial_PE1=value[7:0];
			//flag_PE1_received=1;//count=count+1;
		end
	
	if (value[WIDTH-1:WIDTH-4]==PE2_addr) //PE2
		begin
			partial_PE2=value[7:0];
			//flag_PE2_received=1//count=count+1;
		end
	if (value[WIDTH-1:WIDTH-4]==PE3_addr) //PE3
		begin
			partial_PE3=value[7:0];
			//flag_PE3_received=1;//count=count+1;
		end
	if(value[WIDTH-1:WIDTH-4]==WR_addr)//src addr=WR_addr
		if(value[WIDTH-9:WIDTH-10]==mem_p_type)//type=mem_p_type
			begin
				membrane_potential=value[WIDTH-27:WIDTH-34];
			end
	$display("%m second receive----packet:%b",value);
	
	//third receive
	in.Receive(value);//PE3
	if (value[WIDTH-1:WIDTH-4]==PE1_addr) //src_addr=PE1_addr
		begin
			partial_PE1=value[7:0];
			//flag_PE1_received=1;//count=count+1;
		end
	
	if (value[WIDTH-1:WIDTH-4]==PE2_addr) //PE2
		begin
			partial_PE2=value[7:0];
			//flag_PE2_received=1//count=count+1;
		end
		
	if (value[WIDTH-1:WIDTH-4]==PE3_addr) //PE3
		begin
			partial_PE3=value[7:0];
			//flag_PE3_received=1;//count=count+1;
		end
	if(value[WIDTH-1:WIDTH-4]==WR_addr)//src addr=WR_addr
		if(value[WIDTH-9:WIDTH-10]==mem_p_type)//type=mem_p_type
			begin
				membrane_potential=value[WIDTH-27:WIDTH-34];
			end
	$display("%m third receive----packet:%b",value);
//-----------------------------------------------------------------------------------------------

				
				//begin
				//generate membrane potential 8-bit
				if (first_time==1) //not caculating first input map
					begin
					in.Receive(value);//forth receive
						if (value[WIDTH-1:WIDTH-4]==PE1_addr) //src_addr=PE1_addr
							begin
								partial_PE1=value[7:0];
								//flag_PE1_received=1;//count=count+1;
							end
	
						if (value[WIDTH-1:WIDTH-4]==PE2_addr) //PE2
							begin
								partial_PE2=value[7:0];
								//flag_PE2_received=1//count=count+1;
							end
		
						if (value[WIDTH-1:WIDTH-4]==PE3_addr) //PE3
							begin
								partial_PE3=value[7:0];
								//flag_PE3_received=1;//count=count+1;
							end
						if(value[WIDTH-1:WIDTH-4]==WR_addr)//src addr=WR_addr
							if(value[WIDTH-9:WIDTH-10]==mem_p_type)//type=mem_p_type
								begin
									membrane_potential=value[WIDTH-27:WIDTH-34];
								end
					membrane_potential=partial_PE1+partial_PE2+partial_PE3+membrane_potential;
					$display("%m forth receive----packet:%b",value);
					end	
					
						
				else //first input map
					begin
						membrane_potential=partial_PE1+partial_PE2+partial_PE3;
					end
					
						//generate output_spike 1-bit
				if (membrane_potential>threshold)
					begin
						output_spike=1;
						membrane_potential=membrane_potential-threshold;
					end
				else
					begin
						output_spike=0;
					end
			
				$display("partial_PE1:%b---partial_PE2:%b---partial_PE3:%b---",partial_PE1,partial_PE2,partial_PE3);
				out_packet={Adder_addr,Mem_addr,mem_p_type,MP_to_Mem_zeros,membrane_potential};
				$display("add_num:%m---Membrane_P after compare%b",out_packet);
				//4+4+2+16*zeros+8bits
				//mem_p_type=10
				out.Send(out_packet);	
				if (output_spike==1)
					begin
						output_spike_addr={adder_number,count};//row-col
						out_packet={Adder_addr,Mem_addr,output_spike_type,Out_to_Mem_zeros,output_spike_addr};//4+4+22+4
						//output_spike_type=10
						$display("add_num:%m---output_spike no_zero_send:%b",out_packet);
						out.Send(out_packet);
					end
				if (adder_number==adder3_num)//every time when adder3 finish calculating, send done_singal
					begin
						//output_spike_addr=done_singal;
						//out_packet={Adder_addr,Mem_addr,output_spike_type,Out_to_Mem_zeros,output_spike_addr};
						out_packet={Adder_addr,Mem_addr,output_spike_type,Out_to_Mem_zeros,done_singal};
						out.Send(out_packet);//send done_singal
						$display("add_num:%m---Done signal Sent!!!");
					end
				/***if (count==count_number)//count=2'b10
					begin
						output_spike_addr=done_singal;
						out_packet={Adder_addr,Mem_addr,output_spike_type,Out_to_Mem_zeros,output_spike_addr};
					end
					***/
					//if (adder_number==adder3_num)
						//begin
						//output_spike_addr=done_singal;
						//out_packet={Adder_addr,Mem_addr,output_spike_type,Out_to_Mem_zeros,output_spike_addr};
						//out.Send(out_packet);						
						//end
				count=count+1;
				if (count>count_number)//count=3;
					begin
						count=0;
						first_time=1;
					end
					#10;
				
	/***
	out_packet={Adder_addr,PE1_addr,to_PE_zeros,count};//feedback to PE1
	out.Send(out_packet);
	out_packet={Adder_addr,PE2_addr,to_PE_zeros,count};//feedback to PE2
	out.Send(out_packet);
	out_packet={Adder_addr,PE3_addr,to_PE_zeros,count};//feedback to PE3
	out.Send(out_packet);
	***/						
	//flag1=0;flag2=0;flag3=0;
				//end		

end
endmodule