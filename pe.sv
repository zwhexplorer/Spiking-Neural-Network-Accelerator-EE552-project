`timescale 1ns/100ps
import SystemVerilogCSP::*;

module depacketizer_PE(interface packet, out_filter, out_ifmap, addr_out);
	parameter WIDTH=34;
	parameter WIDTH_addr=4;
	parameter WIDTH_ifmap=5;
	parameter WIDTH_filter=24;
	parameter input_type=2'b00;
	parameter kernel_type=2'b01;
	parameter FL=2;
	parameter BL=1;
	logic [WIDTH-1:0] value;
	logic [WIDTH_filter-1:0]filvalue;
	logic [WIDTH_ifmap-1:0] mapvalue;
	logic [WIDTH_addr-1:0] addr_value;
	
	always begin
		packet.Receive(value);
		$display("%m receive value=%b, Simulation time =%t",value, $time);
		#FL;
		if(value[WIDTH-9:WIDTH-10]==input_type)//send one row of input spikes to ifmap_mem;
			begin
				mapvalue = value[WIDTH-30:0];
				out_ifmap.Send(mapvalue);
//				$display("send mapvalue=%b, Simulation time =%t",mapvalue, $time);
			end
			else if(value[WIDTH-9:WIDTH-10]==kernel_type)
			begin
				filvalue = value[WIDTH-11:0];//send one row of kernel to filter_mem;
				out_filter.Send(filvalue);
//				$display("send filvalue=%b, Simulation time =%t",filvalue, $time);
			end
		#BL;
		addr_value=value[WIDTH-5:WIDTH-8];//send PE address to packetizer;
		addr_out.Send(addr_value);
//		$display("send addr_value=%b, Simulation time =%t",addr_value, $time);
		#BL;
	end
endmodule

module ifmap_mem (interface ifmap_in, ifmap_out, to_packet, ifmap_count);
parameter WIDTH=5;
parameter range=2;
parameter FL=2;
parameter BL=1;
logic sendvalue;
logic [range:0] i=0, j=0;
logic [WIDTH-1:0] ifmap_value; 
logic [WIDTH-1:0] ifmap_value_old; 
int flag=0;

always begin
	ifmap_in.Receive(ifmap_value);
//	$display("receive ifmap_value=%b",ifmap_value);
	flag+=1;//mark how many times ifmap_mem receive ifmap_value;
	#FL;
	if(flag>=2) begin // if ifmap_mem receive more than 1 value, then send old value to packetizer;
		to_packet.Send(ifmap_value_old);
		if(flag==3) begin//when mark 3 times, it have sent 2 row to each other PE, which means it complete 1 timestep;
			flag=0;//reset flag;
		end
	end	
	for(j=0;j<=range;j++)
	begin
		for(i=j;i<=j+range;i++)
		begin
		sendvalue=ifmap_value[i];
		ifmap_out.Send(sendvalue);//send each ifmap_value to multiplier;	
//		$display("send ifmap_value=%b, Simulation time =%t",sendvalue, $time);
		#BL;
		end
		ifmap_count.Send(j);//send times of calculation to packetizer;
		#BL;
	end
	ifmap_value_old=ifmap_value;
end
endmodule


module filter_mem (interface filter_in, count_out, filter_out);
parameter WIDTH=24;
parameter WIDTH_UNIT=8;
parameter True=1;
parameter range=2;
parameter FL=2;
parameter BL=1;
logic [WIDTH_UNIT-1:0] sendvalue;
logic [WIDTH-1:0] filter_value;
logic [range:0] i=0, j=0;

always begin
	filter_in.Receive(filter_value);
//	$display("receive filter_value=%b",filter_value);	
	#FL;
	while(True) begin//continue send filter value to match several ifmap value;
		for(j=0;j<=range;j++) begin
			for(i=0;i<=range;i++) begin
				if(i==0)
					sendvalue=filter_value[WIDTH_UNIT-1:0];//send first value [7:0];
				else if(i==1)
					sendvalue=filter_value[WIDTH_UNIT+7:WIDTH_UNIT];//send second value [15:8];
				else
					sendvalue=filter_value[WIDTH_UNIT+15:WIDTH_UNIT+8];//send third value [23:16];
				count_out.Send(i);//send times of loop;
				filter_out.Send(sendvalue);
//				$display("filter_send value %b, Simulation time =%t",sendvalue,$time);
				#BL;
			end
		end
	end
end
endmodule

module Multiplier (interface filter_in, ifmap_in, multi_out);
parameter WIDTH=8;
parameter FL=2;
parameter BL=1;
logic [WIDTH-1:0] filter_value;
logic ifmap_value;
logic [WIDTH-1:0] multi_out_value;

always begin
	fork
	filter_in.Receive(filter_value);//receive value from filter;
	ifmap_in.Receive(ifmap_value);//receive value from ifmap;
	join
	#FL;
	multi_out_value=filter_value*ifmap_value;
//	$display("multi_out_value = %b ", multi_out_value);
	multi_out.Send(multi_out_value);
	#BL;
	end
endmodule

module adder(interface a0, b0, sum);
	parameter WIDTH = 8;
	parameter FL = 2;
	parameter BL = 1;
	logic [WIDTH-1:0] a=0,b=0,s=0;
	
	always begin
		b0.Receive(b);//receive accumulator result;
		#FL;
	end
	always begin
		a0.Receive(a);//receive multiplier result;
		#FL;	
		s=a+b;
//		$display("SumValue_S =%d. time is %t", s, $time);
		sum.Send(s);
		#BL;										
	end
endmodule

module split (interface inPort,count_sel, acc_out, pkt_out);
	parameter WIDTH = 8;
	parameter range=2;
	parameter FL=2;
	parameter BL=1;
	logic [WIDTH-1:0]A;
	logic [range:0] count;
	
	always begin
		count_sel.Receive(count);
		if(count!=range)
		begin
			inPort.Receive(A);//receive value from adder;
			#FL;		
			acc_out.Send(A);//send value to accumulator;
			#BL;
		end
		else//when count equal to 2, ono convoluted caculation is completed;
		begin
			inPort.Receive(A);//receive value from adder;
			#FL;
			pkt_out.Send(A);//send result to packetizer;
//			$display("sum_out%d at %t",A, $time);
			acc_out.Send(0);//reset accumulator;
			#BL;
		end
	end
endmodule

module accumulator(interface I, O);
  parameter WIDTH = 8;
  parameter FL = 2;
  parameter BL = 1;
  logic [WIDTH-1:0] token=0;
  
  initial begin
  	O.Send(0);//send 0 at first;
	$display("send accumulated value 0 at %t", $time);
	#BL;
  end
  always begin
	I.Receive(token);//receive value from split;
	#FL;
	O.Send(token);//send value to adder;
//	$display("send accumulated value = %d", token);
	#BL;
  end
endmodule

module packetizer_PE(interface result, ifmap_in, ifmap_count, addr_in, packet);
	parameter WIDTH=34, WIDTH_addr=4, WIDTH_ifmap=5, WIDTH_mem=8;
	parameter PE1_addr=4'b0010, PE2_addr=4'b0110, PE3_addr=4'b1010;
	parameter adder1_addr=4'b0001, adder2_addr=4'b0101, adder3_addr=4'b1001;
	parameter input_type=2'b00, mem_type=2'b10;
	parameter long_range_zeros={{6{3'b000}}, 1'b0};
	parameter short_range_zeros={4{4'b0000}};
	parameter FL=2;
	parameter BL=1;
	parameter range=2;
	logic [range:0] i=0;
	logic [WIDTH-1:0] packet_value;
	logic [WIDTH_mem-1:0] result_value;
	logic [WIDTH_ifmap-1:0] mapvalue;
	logic [WIDTH_addr-1:0] addr_value;

	always	addr_in.Receive(addr_value);//receive PE address from depacketizer;
	always begin
		$display("Start module %m and time is %t", $time);	
		fork
		result.Receive(result_value);//receive result from split;
		ifmap_count.Receive(i);//receive times of calculation from ifmap_mem;
		join
		#FL;
		case(i)
		0:packet_value={addr_value,adder1_addr,mem_type,short_range_zeros,result_value};
		1:packet_value={addr_value,adder2_addr,mem_type,short_range_zeros,result_value};
		2:packet_value={addr_value,adder3_addr,mem_type,short_range_zeros,result_value};
		endcase
		packet.Send(packet_value);
		$display("In module %m, packet_value is %b", packet_value);
		#BL;
	end
	always begin
	ifmap_in.Receive(mapvalue);//receive old ifmap value;
	#FL;
	if(addr_value==PE2_addr)
		begin
			packet_value={addr_value,PE1_addr,input_type,long_range_zeros,mapvalue};
			packet.Send(packet_value);
			#BL;
		end
		else if(addr_value==PE3_addr)
		begin
			packet_value={addr_value,PE2_addr,input_type,long_range_zeros,mapvalue};
			packet.Send(packet_value);
			#BL;
		end
	$display("In module %m, local shared packet_value is %b", packet_value);
	end
endmodule

module pe(interface packet_in, packet_out);
	 Channel #(.hsProtocol(P4PhaseBD), .WIDTH(34)) intf  [13:1] (); 
	 
	 depacketizer_PE #(.FL(2), .BL(1)) dpkt(.packet(packet_in), .out_filter(intf[1]), .out_ifmap(intf[2]), .addr_out(intf[3]));
	 filter_mem #(.FL(2),.BL(1)) FM (.filter_in(intf[1]),.count_out(intf[4]),.filter_out(intf[5]));
	 ifmap_mem #(.FL(2),.BL(1)) IM (.ifmap_in(intf[2]), .ifmap_out(intf[6]), .to_packet(intf[7]), .ifmap_count(intf[13]));
	 Multiplier #(.FL(2), .BL(1)) mul(.filter_in(intf[5]), .ifmap_in(intf[6]), .multi_out(intf[8]));
	 adder 	    #(.FL(2), .BL(1)) add(.a0(intf[8]), .b0(intf[9]), .sum(intf[10]));
	 split      #(.FL(2), .BL(1)) spl(.inPort(intf[10]), .count_sel(intf[4]), .acc_out(intf[11]), .pkt_out(intf[12]));
	 accumulator #(.FL(2),.BL(1)) acc (.I(intf[11]), .O(intf[9]));
	 packetizer_PE #(.FL(2), .BL(1)) pkt(.result(intf[12]), .ifmap_in(intf[7]), .ifmap_count(intf[13]), .addr_in(intf[3]), .packet(packet_out));
	 
endmodule
